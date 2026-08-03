#!/usr/bin/env node
// Tạo 9 sản phẩm mua-trong-app (consumable) trên App Store Connect từ bảng giá
// ở specs/projects/evidencecam/product-spec/002-pricing-plans/bang-gia.md.
//
//   node tool/asc_iap.mjs            # dry-run: in ra sẽ làm gì, KHÔNG gọi API ghi
//   node tool/asc_iap.mjs --apply    # thật sự tạo
//
// Cần trong môi trường (hoặc ios/fastlane/.env):
//   ASC_KEY_ID · ASC_ISSUER_ID · ASC_KEY_PATH (file .p8) · ASC_BUNDLE_ID
//
// productId KHÔNG XÓA ĐƯỢC sau khi tạo — dry-run là mặc định vì lý do đó.
// Script idempotent: productId đã tồn tại thì bỏ qua, chạy lại bao nhiêu lần cũng được.
//
// ponytail: KHÔNG upload review screenshot. Apple đòi 1 ảnh/sản phẩm trước khi
// nộp duyệt; luồng đó là 3 call nữa (reserve → PUT upload → PATCH uploaded).
// Làm tay 9 lần trong ASC nhanh hơn viết, thêm vào đây khi số sản phẩm tăng.

import { createSign } from 'node:crypto';
import { readFileSync } from 'node:fs';

// Hầu hết endpoint nằm ở /v1, riêng TẠO in-app purchase là /v2 — /v1/inAppPurchases
// là API đời cũ đã ngừng, gọi nhầm sẽ 404/410.
const HOST = 'https://api.appstoreconnect.apple.com';
const API = `${HOST}/v1`;
const TERRITORY = 'VNM'; // chỉ bán ở VN — sản phẩm là công cụ cho seller sàn TMĐT Việt

import { products } from './ec_plans.mjs';

// ---- App Store Connect API ------------------------------------------------

function token() {
  const kid = req('ASC_KEY_ID');
  const iss = req('ASC_ISSUER_ID');
  const key = readFileSync(req('ASC_KEY_PATH'), 'utf8');
  const now = Math.floor(Date.now() / 1000);
  const b64 = (o) => Buffer.from(JSON.stringify(o)).toString('base64url');
  const head = b64({ alg: 'ES256', kid, typ: 'JWT' });
  const body = b64({ iss, iat: now, exp: now + 1200, aud: 'appstoreconnect-v1' });
  // dsaEncoding ieee-p1363 = chữ ký r||s mà JOSE đòi; mặc định của Node là DER và Apple từ chối.
  const sig = createSign('sha256')
    .update(`${head}.${body}`)
    .sign({ key, dsaEncoding: 'ieee-p1363' })
    .toString('base64url');
  return `${head}.${body}.${sig}`;
}

const req = (name) => {
  const v = process.env[name];
  if (!v) throw new Error(`Thiếu biến môi trường ${name}`);
  return v;
};

const JWT = process.env.ASC_SKIP_AUTH ? 'test' : token();

async function call(method, path, body) {
  const res = await fetch(path.startsWith('http') ? path : `${API}${path}`, {
    method,
    headers: {
      Authorization: `Bearer ${JWT}`,
      ...(body ? { 'Content-Type': 'application/json' } : {}),
    },
    ...(body ? { body: JSON.stringify(body) } : {}),
  });
  if (!res.ok) throw new Error(`${method} ${path} → ${res.status} ${await res.text()}`);
  return res.status === 204 ? null : res.json();
}

const get = (p) => call('GET', p);
const post = (p, b) => call('POST', p, b);

/// GET cho quan hệ to-one có thể chưa tồn tại: 404 nghĩa là "chưa có", không phải lỗi.
const getOrNull = (p) => get(p).catch(() => null);

/// Tên quan hệ trỏ ngược về IAP KHÔNG thống nhất giữa các resource con — đây là
/// tên của riêng `inAppPurchaseLocalizations`. Price schedule và availability
/// dùng `inAppPurchase` (tên cũ) và sẽ 409 nếu đưa tên này vào. Không có quy luật
/// nào suy ra được, chỉ có việc gửi quan hệ rỗng rồi đọc lỗi API trả về.
const parent = (id) => ({ inAppPurchaseV2: { data: { type: 'inAppPurchases', id } } });

/// ĐỌC quan hệ con của một IAP phải qua /v2 (v1 trả 404 PATH_ERROR), trong khi
/// TẠO các resource con đó lại nằm ở /v1. Hai đời API đan vào nhau, không nhất quán.
const rel = (id, name) => `${HOST}/v2/inAppPurchases/${id}/${name}`;

/// Lấy hết các trang của một collection endpoint.
async function getAll(path) {
  const out = [];
  let next = path;
  while (next) {
    const page = await get(next);
    out.push(...page.data);
    next = page.links?.next ?? null;
  }
  return out;
}

// ---- Ghép giá VND vào price point của Apple --------------------------------

/// Apple không nhận giá tùy ý, chỉ nhận "price point" có sẵn. Chọn điểm giá gần
/// nhất; nếu lệch quá ngưỡng thì dừng chứ không âm thầm bán sai giá.
const MAX_DRIFT = 0.05; // 5%

export function pickPricePoint(pricePoints, targetVnd) {
  if (!pricePoints.length) throw new Error('Không có price point nào cho lãnh thổ này');
  const best = pricePoints.reduce((a, b) =>
    Math.abs(Number(b.attributes.customerPrice) - targetVnd) <
    Math.abs(Number(a.attributes.customerPrice) - targetVnd) ? b : a,
  );
  const actual = Number(best.attributes.customerPrice);
  const drift = Math.abs(actual - targetVnd) / targetVnd;
  if (drift > MAX_DRIFT) {
    throw new Error(
      `Điểm giá gần nhất cho ${targetVnd.toLocaleString('vi')}đ là ` +
      `${actual.toLocaleString('vi')}đ (lệch ${(drift * 100).toFixed(1)}%) — vượt ngưỡng ${MAX_DRIFT * 100}%. ` +
      `Sửa giá trong bang-gia.md cho khớp điểm giá Apple rồi chạy lại.`,
    );
  }
  return { pricePoint: best, actual, drift };
}

// ---- Luồng chính -----------------------------------------------------------

async function main() {
  const apply = process.argv.includes('--apply');
  const bundleId = req('ASC_BUNDLE_ID');

  const apps = await get(`/apps?filter[bundleId]=${encodeURIComponent(bundleId)}`);
  const app = apps.data[0];
  if (!app) throw new Error(`Không tìm thấy app có bundle id ${bundleId}`);
  console.log(`App: ${app.attributes.name} (${app.id})\n`);

  // productId → id. Sản phẩm tạo dở (có IAP nhưng thiếu giá/localization) phải
  // được chạy tiếp chứ không bỏ qua — nên nhớ id thay vì chỉ nhớ "đã tồn tại".
  const existing = new Map(
    (await getAll(`/apps/${app.id}/inAppPurchasesV2?limit=200`))
      .map((p) => [p.attributes.productId, p.id]),
  );

  for (const p of products) {
    let iapId = existing.get(p.productId);

    if (!apply) {
      const mark = iapId ? '↻' : '＋';
      console.log(`${mark} ${p.productId.padEnd(24)} ${p.priceVnd.toLocaleString('vi')}đ  "${p.localizations[0].name}"`);
      continue;
    }

    if (iapId) {
      console.log(`↻  ${p.productId} — đã có, chạy tiếp phần còn thiếu`);
    } else {
    const created = await post(`${HOST}/v2/inAppPurchases`, {
      data: {
        type: 'inAppPurchases',
        attributes: {
          name: p.referenceName,
          productId: p.productId,
          inAppPurchaseType: 'CONSUMABLE',
          reviewNote: 'Mua thêm thời gian sử dụng dịch vụ lưu trữ video bằng chứng đóng hàng.',
          familySharable: false,
        },
        relationships: { app: { data: { type: 'apps', id: app.id } } },
      },
    });
      iapId = created.data.id;
    }

    const haveLocales = new Set(
      (await getAll(rel(iapId, 'inAppPurchaseLocalizations')))
        .map((l) => l.attributes.locale),
    );
    for (const l of p.localizations.filter((l) => !haveLocales.has(l.locale))) {
      await post('/inAppPurchaseLocalizations', {
        data: {
          type: 'inAppPurchaseLocalizations',
          attributes: { locale: l.locale, name: l.name, description: l.description },
          relationships: parent(iapId),
        },
      });
    }

    let note = '';
    if (!(await getOrNull(rel(iapId, 'iapPriceSchedule')))?.data) {
      const points = await getAll(
        `${rel(iapId, 'pricePoints')}?filter[territory]=${TERRITORY}&limit=200`,
      );
      const { pricePoint, actual, drift } = pickPricePoint(points, p.priceVnd);
      if (drift > 0) note = ` (điểm giá Apple: ${actual.toLocaleString('vi')}đ)`;

      await post('/inAppPurchasePriceSchedules', {
        data: {
          type: 'inAppPurchasePriceSchedules',
          relationships: {
            // Riêng price schedule dùng tên CŨ `inAppPurchase`, không phải
            // `inAppPurchaseV2` như localization/availability. Không có quy luật,
            // chỉ có việc thử và đọc lỗi API trả về.
            inAppPurchase: { data: { type: 'inAppPurchases', id: iapId } },
            baseTerritory: { data: { type: 'territories', id: TERRITORY } },
            manualPrices: { data: [{ type: 'inAppPurchasePrices', id: '${price}' }] },
          },
        },
        included: [{
          type: 'inAppPurchasePrices',
          id: '${price}',
          attributes: { startDate: null },
          relationships: {
            inAppPurchasePricePoint: { data: { type: 'inAppPurchasePricePoints', id: pricePoint.id } },
          },
        }],
      });
    }

    if (!(await getOrNull(rel(iapId, 'inAppPurchaseAvailability')))?.data) {
      await post('/inAppPurchaseAvailabilities', {
        data: {
          type: 'inAppPurchaseAvailabilities',
          attributes: { availableInNewTerritories: false },
          relationships: {
            inAppPurchase: { data: { type: 'inAppPurchases', id: iapId } },
            availableTerritories: { data: [{ type: 'territories', id: TERRITORY }] },
          },
        },
      });
    }

    console.log(`✅ ${p.productId} — ${p.priceVnd.toLocaleString('vi')}đ${note}`);
  }

  if (!apply) console.log('\n(dry-run — thêm --apply để tạo thật)');
  else console.log('\n⚠️  Còn phải làm tay: upload 1 review screenshot cho MỖI sản phẩm trong ASC trước khi nộp duyệt.');
}

// Tự kiểm phần logic duy nhất có thể sai âm thầm: ghép giá.
function selfTest() {
  const pp = (id, price) => ({ id, attributes: { customerPrice: String(price) } });
  const points = [pp('a', 149000), pp('b', 169000), pp('c', 179000), pp('d', 199000)];
  console.assert(pickPricePoint(points, 169000).pricePoint.id === 'b', 'khớp chính xác');
  console.assert(pickPricePoint(points, 172000).pricePoint.id === 'b', 'chọn điểm gần nhất');
  let threw = false;
  try { pickPricePoint(points, 300000); } catch { threw = true; }
  console.assert(threw, 'lệch quá 5% phải ném lỗi chứ không bán sai giá');
  console.log('self-test ok');
}

if (process.argv.includes('--self-test')) selfTest();
else main().catch((e) => { console.error(`\n❌ ${e.message}`); process.exit(1); });
