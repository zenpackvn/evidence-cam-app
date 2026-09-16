#!/usr/bin/env node
// Đồng bộ 6 gói TỰ ĐỘNG GIA HẠN trên App Store Connect với bảng gốc ở
// specs/…/monetization-setup/00-danh-muc-san-pham.md.
//
//   node tool/asc_subs.mjs            # dry-run: in ra sẽ đổi gì, KHÔNG ghi
//   node tool/asc_subs.mjs --apply    # ghi thật
//   node tool/asc_subs.mjs --rate 26500 --apply
//
// Đây là script cho /v1/subscriptions — KHÁC HẲN asc_iap.mjs, cái đó gọi
// /v2/inAppPurchases (consumable) và đã tự chặn --apply.
//
// Làm bốn việc, mỗi việc idempotent, chạy lại bao nhiêu lần cũng được:
//   1. groupLevel  — Doanh nghiệp 1, Chuyên nghiệp 2, Cơ bản 3. Ở ASC Level 1 là
//      mức CAO NHẤT, và hai thời hạn của cùng một gói phải CÙNG level, nếu không
//      Apple coi đổi tháng↔năm là nâng/hạ gói.
//   2. localization vi + en-US theo ec_plans.mjs (PATCH cái đang có).
//   3. giá VNM theo bảng gốc (từ Bản 5, 2026-09-16 — trước đó chỉ đọc đối chiếu),
//      và giá USA = giá VND quy đổi; cả hai chọn điểm giá gần nhất Apple có.
//      Lệch quá ±1% so với bảng thì BÁO và KHÔNG ghi — cam kết "giá app = giá
//      web" là của người quyết, không phải của script.
//   4. availability — vùng được bán. GIÁ KHÁC VÙNG BÁN: từ đợt Apple đổi mô hình
//      giá 2023 chúng là hai resource riêng, và có giá đủ 175 vùng vẫn không có
//      nghĩa là bán ở vùng nào. Thiếu nó thì subscription kẹt MISSING_METADATA
//      dù localization, giá và screenshot đều đủ — đo được ngày 2026-08-10:
//      đặt availability xong là state nhảy sang READY_TO_SUBMIT ngay.
//
// Giá VNM là giá gốc. Bản 4 script chỉ đọc nó, vì lúc ấy nó đã khớp bảng và
// sửa nhầm là hỏng cam kết "giá app = giá web". Bản 5 HẠ giá cả 6 mã, nên giữ
// nguyên VNM mới là thứ phá cam kết đó — script đặt VNM theo bảng, nhưng vẫn
// dừng lại hỏi nếu Apple không có điểm giá trong ±1%. Hạ giá tự động áp cho cả
// người đang thuê bao (Apple không đòi họ đồng ý khi giá GIẢM), đúng ý bảng gói.
//
// Kèm theo, mỗi lần chạy script ghi `tool/gia-store.json`: điểm giá USA đã
// chọn cho từng mã. `play_subs.mjs` đọc file đó để ép giá US bên Google bằng
// đúng giá Apple — hai cửa hàng cùng giá là cam kết sản phẩm, không phải tình cờ.
//
// Cần trong ios/fastlane/.env (hoặc môi trường):
//   APP_STORE_CONNECT_API_KEY_ID · APP_STORE_CONNECT_API_ISSUER_ID
//   APP_STORE_CONNECT_API_KEY_CONTENT (base64 của .p8) · IOS_BUNDLE_ID_BASE

import { createSign } from 'node:crypto';
import { readFileSync, writeFileSync } from 'node:fs';
import { products } from './ec_plans.mjs';

const APPLY = process.argv.includes('--apply');
const RATE = Number(process.argv[process.argv.indexOf('--rate') + 1]) || 26_300;
const ENV_FILE = 'ios/fastlane/.env';

// Level 1 = mức dịch vụ CAO NHẤT ở App Store Connect. Ngược trực giác, và đảo
// nhầm thì khách mua LÊN gói bị Apple xử như hạ gói: không hiệu lực ngay, phải
// chờ hết kỳ, không hoàn phần dư.
const LEVEL = { enterprise: 1, pro: 2, basic: 3 };

// Giá VND lấy thẳng từ `products[].priceVnd` (ec_plans.mjs) — một bảng, không
// chép lại ở đây nữa: bản trước có hai bảng và Bản 5 phải sửa cả hai.
const usdPicked = {};

// ---- auth ------------------------------------------------------------------

function env(name) {
  if (process.env[name]) return process.env[name];
  const file = readFileSync(ENV_FILE, 'utf8');
  for (const line of file.split('\n')) {
    if (line.trim().startsWith('#') || !line.includes('=')) continue;
    const k = line.slice(0, line.indexOf('=')).trim();
    if (k === name) return line.slice(line.indexOf('=') + 1).trim();
  }
  throw new Error(`Thiếu ${name} (môi trường hoặc ${ENV_FILE})`);
}

function token() {
  const key = Buffer.from(env('APP_STORE_CONNECT_API_KEY_CONTENT'), 'base64').toString('utf8');
  const now = Math.floor(Date.now() / 1000);
  const b64 = (o) => Buffer.from(JSON.stringify(o)).toString('base64url');
  const head = b64({ alg: 'ES256', kid: env('APP_STORE_CONNECT_API_KEY_ID'), typ: 'JWT' });
  const body = b64({
    iss: env('APP_STORE_CONNECT_API_ISSUER_ID'),
    iat: now,
    exp: now + 1200,
    aud: 'appstoreconnect-v1',
  });
  // ieee-p1363 = chữ ký r||s mà JOSE đòi; mặc định của Node là DER và Apple từ chối.
  const sig = createSign('sha256')
    .update(`${head}.${body}`)
    .sign({ key, dsaEncoding: 'ieee-p1363' })
    .toString('base64url');
  return `${head}.${body}.${sig}`;
}

const API = 'https://api.appstoreconnect.apple.com/v1';
const JWT = token();

async function call(method, path, body) {
  const res = await fetch(path.startsWith('http') ? path : API + path, {
    method,
    headers: {
      Authorization: `Bearer ${JWT}`,
      ...(body ? { 'Content-Type': 'application/json' } : {}),
    },
    ...(body ? { body: JSON.stringify(body) } : {}),
  });
  const text = await res.text();
  if (!res.ok) throw new Error(`${res.status} ${method} ${path}\n${text.slice(0, 500)}`);
  return text ? JSON.parse(text) : {};
}

const get = (p) => call('GET', p);

async function getAll(path) {
  let out = [];
  let url = path;
  while (url) {
    const page = await get(url);
    out = out.concat(page.data);
    url = page.links?.next ?? null;
  }
  return out;
}

// ---- plan ------------------------------------------------------------------

const changes = [];
const note = (kind, productId, what) => changes.push({ kind, productId, what });

const territories = (await getAll('/territories?limit=200')).map((t) => t.id);

const app = (await get(`/apps?filter[bundleId]=${env('IOS_BUNDLE_ID_BASE')}`)).data[0];
if (!app) throw new Error('Không tìm thấy app theo bundle id');
const group = (await get(`/apps/${app.id}/subscriptionGroups?limit=50`)).data[0];
if (!group) throw new Error('Chưa có Subscription Group nào — tạo bằng GUI trước (runbook §2.1)');
const remote = await getAll(`/subscriptionGroups/${group.id}/subscriptions?limit=200`);

console.log(`App ${app.attributes.bundleId} · group "${group.attributes.referenceName}" · ${remote.length} subscription`);
console.log(`Tỷ giá quy đổi USD: ${RATE.toLocaleString('vi')}đ/$  ${APPLY ? '· CHẾ ĐỘ GHI' : '· dry-run'}\n`);

for (const want of products) {
  const sub = remote.find((s) => s.attributes.productId === want.productId);
  if (!sub) {
    note('THIẾU', want.productId, 'không có trên ASC — tạo bằng GUI theo runbook §2.2');
    continue;
  }

  // 1. groupLevel
  const wantLevel = LEVEL[want.planCode];
  if (sub.attributes.groupLevel !== wantLevel) {
    note('level', want.productId, `${sub.attributes.groupLevel} → ${wantLevel}`);
    if (APPLY) {
      await call('PATCH', `/subscriptions/${sub.id}`, {
        data: { type: 'subscriptions', id: sub.id, attributes: { groupLevel: wantLevel } },
      });
    }
  }

  // 2. localization
  const locs = await getAll(`/subscriptions/${sub.id}/subscriptionLocalizations?limit=50`);
  for (const l of want.localizations) {
    const cur = locs.find((x) => x.attributes.locale === l.locale);
    if (!cur) {
      note('loc+', want.productId, `${l.locale}: tạo "${l.name}" / "${l.description}"`);
      if (APPLY) {
        await call('POST', '/subscriptionLocalizations', {
          data: {
            type: 'subscriptionLocalizations',
            attributes: { locale: l.locale, name: l.name, description: l.description },
            relationships: { subscription: { data: { type: 'subscriptions', id: sub.id } } },
          },
        });
      }
    } else if (cur.attributes.name !== l.name || cur.attributes.description !== l.description) {
      note('loc~', want.productId, `${l.locale}: "${cur.attributes.description}" → "${l.description}"`);
      if (APPLY) {
        await call('PATCH', `/subscriptionLocalizations/${cur.id}`, {
          data: {
            type: 'subscriptionLocalizations',
            id: cur.id,
            attributes: { name: l.name, description: l.description },
          },
        });
      }
    }
  }

  // 3. availability — không có resource này thì kẹt MISSING_METADATA mãi.
  // API không cho PATCH danh sách vùng qua đây, nên chỉ tạo khi chưa có; sửa vùng
  // thì làm trong GUI. Ở đây chỉ cần "đã bật bán ở mọi nơi app bán".
  let hasAvailability = true;
  try {
    await get(`/subscriptions/${sub.id}/subscriptionAvailability`);
  } catch {
    hasAvailability = false;
  }
  if (!hasAvailability) {
    note('avail', want.productId, `bật bán ở ${territories.length} vùng (đang thiếu ⇒ MISSING_METADATA)`);
    if (APPLY) {
      await call('POST', '/subscriptionAvailabilities', {
        data: {
          type: 'subscriptionAvailabilities',
          attributes: { availableInNewTerritories: true },
          relationships: {
            subscription: { data: { type: 'subscriptions', id: sub.id } },
            availableTerritories: { data: territories.map((id) => ({ type: 'territories', id })) },
          },
        },
      });
    }
  }

  // 4. giá — VNM theo bảng, USA theo quy đổi; mỗi bên chọn điểm giá gần nhất.
  const prices = await getAll(
    `/subscriptions/${sub.id}/prices?include=subscriptionPricePoint,territory&limit=200`,
  );
  const byTerritory = {};
  for (const p of prices) {
    const t = p.relationships?.territory?.data?.id;
    if (t === 'VNM' || t === 'USA') byTerritory[t] = p;
  }
  const pointOf = (p) => {
    const id = p?.relationships?.subscriptionPricePoint?.data?.id;
    // /prices?include=… trả price point trong `included` của TỪNG trang; getAll bỏ
    // included đi, nên tra lại giá qua endpoint điểm giá thay vì đoán.
    return id ?? null;
  };
  const nearestPoint = async (territory, target) => {
    const pts = (await getAll(`/subscriptions/${sub.id}/pricePoints?filter[territory]=${territory}&limit=200`))
      .map((p) => ({ id: p.id, price: Number(p.attributes.customerPrice) }))
      .sort((a, b) => Math.abs(a.price - target) - Math.abs(b.price - target) || a.price - b.price);
    return pts[0];
  };
  const setPrice = async (pointId) => {
    await call('POST', '/subscriptionPrices', {
      data: {
        type: 'subscriptionPrices',
        attributes: { startDate: null, preserveCurrentPrice: false },
        relationships: {
          subscription: { data: { type: 'subscriptions', id: sub.id } },
          subscriptionPricePoint: { data: { type: 'subscriptionPricePoints', id: pointId } },
        },
      },
    });
  };
  const fmtVnd = (n) => `${Number(n).toLocaleString('vi')}đ`;

  // 4a. VNM — giá gốc.
  const vndWant = want.priceVnd;
  const vndNow = byTerritory.VNM ? Number(await pricePointPrice(pointOf(byTerritory.VNM))) : null;
  const vndPick = await nearestPoint('VNM', vndWant);
  const vndOff = Math.abs(vndPick.price - vndWant) / vndWant;
  if (vndOff > 0.01) {
    note(
      'VND-LỆCH',
      want.productId,
      `bảng ghi ${fmtVnd(vndWant)}, điểm giá gần nhất Apple có là ${fmtVnd(vndPick.price)} (lệch ${(vndOff * 100).toFixed(2)}%) — VƯỢT ±1%, KHÔNG ghi, dừng lại hỏi`,
    );
  } else if (vndNow !== vndPick.price) {
    note(
      'vnd',
      want.productId,
      `${vndNow == null ? '—' : fmtVnd(vndNow)} → ${fmtVnd(vndPick.price)}${vndPick.price !== vndWant ? ` (bảng ${fmtVnd(vndWant)}, lệch ${(vndOff * 100).toFixed(2)}%)` : ''}`,
    );
    if (APPLY) await setPrice(vndPick.id);
  }
  // Giá VNM sắp có hiệu lực (đã chọn) — USD quy từ nó, không quy từ giá cũ.
  const vndEffective = vndOff > 0.01 ? (vndNow ?? vndWant) : vndPick.price;

  // 4b. USA — quy đổi từ VND.
  const usdTarget = vndEffective / RATE;
  const pick = await nearestPoint('USA', usdTarget);
  const usdNow = byTerritory.USA ? Number(await pricePointPrice(pointOf(byTerritory.USA))) : null;
  usdPicked[want.productId] = pick.price;

  if (usdNow !== pick.price) {
    note(
      'usd',
      want.productId,
      `$${usdNow ?? '—'} → $${pick.price}  (quy đổi ${fmtVnd(vndEffective)} = $${usdTarget.toFixed(2)}, lệch ${(
        (Math.abs(pick.price - usdTarget) / usdTarget) * 100
      ).toFixed(2)}%)`,
    );
    if (APPLY) await setPrice(pick.id);
  }
}

async function pricePointPrice(id) {
  if (!id) return null;
  const r = await get(`/subscriptionPricePoints/${id}`);
  return r.data.attributes.customerPrice;
}

// ---- report ----------------------------------------------------------------

// Điểm giá USA đã chọn — đầu vào cho play_subs.mjs. Ghi cả ở dry-run: hai script
// chạy nối nhau trong cùng một lượt, và dry-run của Play cũng phải in đúng số.
writeFileSync(
  'tool/gia-store.json',
  JSON.stringify({ rate: RATE, at: new Date().toISOString(), usd: usdPicked }, null, 2) + '\n',
);

// `vnd-ok` là dòng báo cáo, không phải việc phải làm — đếm nó vào số thay đổi
// thì lần chạy nào cũng "còn 1 thay đổi" và người đọc sẽ thôi tin con số đó.
const todo = changes.filter((c) => c.kind !== 'vnd-ok');
for (const c of changes) console.log(`  [${c.kind}] ${c.productId}  ${c.what}`);
console.log(
  todo.length
    ? `\n${todo.length} thay đổi. ${APPLY ? 'ĐÃ GHI.' : 'Chưa ghi gì — thêm --apply để ghi thật.'}`
    : '\nKhông có gì phải đổi — ASC đã khớp bảng gốc.',
);

// state được đọc TRƯỚC khi script ghi, nên sau một lần --apply nó là số cũ. Đọc
// lại từ đầu thay vì báo lại con số đã lạc hậu.
const after = await getAll(`/subscriptionGroups/${group.id}/subscriptions?limit=200`);
const stuck = after.filter((s) => s.attributes.state === 'MISSING_METADATA');
console.log(
  `\nTrạng thái: ${after.filter((s) => s.attributes.state === 'READY_TO_SUBMIT').length}/${after.length} READY_TO_SUBMIT` +
    (stuck.length ? `, ${stuck.length} còn MISSING_METADATA` : ''),
);
if (stuck.length) {
  console.log(
    `  Còn kẹt: ${stuck.map((s) => s.attributes.productId).join(', ')}\n` +
      '  Kiểm theo thứ tự: availability → localization → giá → screenshot review.\n' +
      '  Screenshot là thứ duy nhất script không nạp được (phải GUI, runbook §2.4).',
  );
}
