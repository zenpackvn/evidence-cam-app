#!/usr/bin/env node
// Đồng bộ 3 subscription × 2 base plan trên Google Play với bảng gốc ở
// specs/…/monetization-setup/00-danh-muc-san-pham.md. Song sinh của asc_subs.mjs.
//
//   node tool/play_subs.mjs            # dry-run: in ra sẽ đổi gì, KHÔNG ghi
//   node tool/play_subs.mjs --apply    # ghi thật
//
// Làm ba việc, idempotent:
//   1. giá VN theo bảng gốc.
//   2. giá 172 vùng còn lại — để Google tự quy bằng `pricing:convertRegionPrices`,
//      RIÊNG US ép bằng đúng giá đã đặt bên Apple. Google quy ra mức đuôi .99
//      lệch Apple tới 1,1%, mà cam kết sản phẩm là hai cửa hàng cùng giá.
//      Giá US đọc từ `tool/gia-store.json` do asc_subs.mjs ghi ra — chạy
//      asc_subs TRƯỚC (dry-run cũng được), không gõ tay con số Apple vào đây.
//   3. listing vi + en-US: title, ĐỦ 4 benefit, description.
//
// Cần `PLAY_STORE_JSON_KEY_PATH` (trong môi trường hoặc android/fastlane/.env)
// trỏ tới service account JSON đã được mời vào Play Console với quyền
// "Manage orders and subscriptions".
//
// KHÔNG đụng: basePlanId, billing period, grace period, proration — tạo rồi là
// khoá. Script đọc chúng lên rồi ghi lại y nguyên, chỉ thay giá và vùng.
//
// LƯU Ý vùng bán: script này đặt giá cho các vùng, KHÔNG mở bán app ở vùng đó.
// Nước app được phát hành nằm ở Release → Countries/regions, không có trong API
// này. Đặt giá đủ 173 vùng mà app chỉ phát hành ở VN thì vẫn chỉ bán được ở VN.

import { readFileSync } from 'node:fs';
import { createSign } from 'node:crypto';

const APPLY = process.argv.includes('--apply');
const PKG = 'com.aktechvn.zenpack';
// Bản danh mục vùng của Google — bắt buộc khi ghi regionalConfigs. KHÔNG gõ cứng:
// tài liệu ghi "2022/02" nhưng bản đó đã hết hạn (Bulgaria sang euro ⇒ Google trả
// 400 "Expected BGN but got EUR"). `pricing:convertRegionPrices` trả kèm
// `regionVersion` của chính bộ giá nó vừa quy — dùng đúng cái đó thì hai bên
// không bao giờ lệch nhau.
let regionsVersion = null;

// Vùng phải bỏ vì giá vượt TRẦN của Google. Trần là theo vùng và Google không
// công bố bảng; đây là thứ học được từ lỗi 400 thật, giữ lại để lần chạy sau
// không đề nghị thêm vào rồi lại bị đá ra (dry-run phải sạch mới đáng tin).
// Bản 4: Doanh nghiệp 12 tháng = 11.9tr₫ ≈ ₩710.000 vượt trần Hàn Quốc
// ₩600.000 nên bỏ KR. Bản 5 hạ còn 1,49tr₫ ≈ ₩85.000, dưới trần xa — mở lại.
// Gặp 400 vì trần ở vùng nào thì thêm vùng đó vào đây, đừng sửa giá.
const CAP_SKIP = {};

// VND = bảng gốc §2. USD = đúng giá đã đặt bên App Store (00 §2 "Giá USD").
// VND = bảng gốc Bản 5 (= WEB_PRICES backend, production 2026-09-16). USD =
// điểm giá Apple đã chọn, đọc từ gia-store.json (khoá là productId bên Apple).
const usdFile = (() => {
  try {
    return JSON.parse(readFileSync('tool/gia-store.json', 'utf8'));
  } catch {
    throw new Error('Thiếu tool/gia-store.json — chạy `node tool/asc_subs.mjs` (dry-run là đủ) trước để lấy giá USA Apple đã chọn.');
  }
})();
const usdOf = (appleId) => {
  const v = usdFile.usd?.[appleId];
  if (typeof v !== 'number') throw new Error(`gia-store.json không có giá USA cho ${appleId} — asc_subs.mjs chưa chạy tới mã này?`);
  return v;
};
const PLANS = {
  zenpack_sub_basic: {
    p1m: { vnd: 49_000, usd: usdOf('zenpack_sub_basic_1m') },
    p1y: { vnd: 490_000, usd: usdOf('zenpack_sub_basic_12m') },
  },
  zenpack_sub_pro: {
    p1m: { vnd: 99_000, usd: usdOf('zenpack_sub_pro_1m') },
    p1y: { vnd: 990_000, usd: usdOf('zenpack_sub_pro_12m') },
  },
  zenpack_sub_enterprise: {
    p1m: { vnd: 149_000, usd: usdOf('zenpack_sub_enterprise_1m') },
    p1y: { vnd: 1_490_000, usd: usdOf('zenpack_sub_enterprise_12m') },
  },
};

// Bốn benefit = đúng bốn gạch đầu dòng của website, cùng thứ tự (01 §1.3).
// Bốn benefit = bốn cột của bảng gói Bản 5: kho kèm sẵn (≈ video), người dùng +
// cửa hàng, thời gian giữ, tính năng bậc cao. Google giới hạn mỗi benefit 40 ký tự.
const LISTINGS = {
  zenpack_sub_basic: [
    {
      languageCode: 'vi',
      title: 'ZenPack Cơ bản',
      benefits: ['Kho 10 GB, ≈450 video/tháng', '5 người dùng/shop, 3 cửa hàng', 'Giữ video 30 ngày', 'Mua thêm kho khi cần'],
      description:
        'Gói Cơ bản cho shop nhỏ: kho kèm sẵn 10 GB (≈450 video mỗi tháng), 5 người dùng mỗi shop, 3 cửa hàng, giữ video 30 ngày, mua thêm kho khi cần.',
    },
    {
      languageCode: 'en-US',
      title: 'ZenPack Basic',
      benefits: ['10 GB storage, ≈450 videos/month', '5 users/shop, 3 stores', 'Videos kept 30 days', 'Add storage anytime'],
      description:
        'Basic plan for small shops: 10 GB included (≈450 videos per month), 5 users per shop, 3 stores, videos kept 30 days, add storage anytime.',
    },
  ],
  zenpack_sub_pro: [
    {
      languageCode: 'vi',
      title: 'ZenPack Chuyên nghiệp',
      benefits: ['Kho 30 GB, ≈1.350 video/tháng', '15 người dùng/shop, 10 cửa hàng', 'Giữ video 30/60/90 ngày', 'Bản máy tính, camera IP, kho riêng'],
      description:
        'Gói Chuyên nghiệp cho shop lớn: kho kèm sẵn 30 GB (≈1.350 video mỗi tháng), 15 người dùng mỗi shop, 10 cửa hàng, giữ video 30/60/90 ngày, bản cài máy tính + camera IP, kho riêng.',
    },
    {
      languageCode: 'en-US',
      title: 'ZenPack Pro',
      benefits: ['30 GB storage, ≈1,350 videos/month', '15 users/shop, 10 stores', 'Videos kept 30/60/90 days', 'Desktop app, IP camera, own storage'],
      description:
        'Pro plan for larger shops: 30 GB included (≈1,350 videos per month), 15 users per shop, 10 stores, videos kept 30/60/90 days, desktop app with IP cameras, bring your own storage.',
    },
  ],
  zenpack_sub_enterprise: [
    {
      languageCode: 'vi',
      title: 'ZenPack Doanh nghiệp',
      benefits: ['Kho 80 GB, ≈3.600 video/tháng', 'Không giới hạn người dùng, cửa hàng', 'Giữ video 30 → 180 ngày', 'Bản máy tính, camera IP, kho riêng'],
      description:
        'Gói Doanh nghiệp cho kho vận: kho kèm sẵn 80 GB (≈3.600 video mỗi tháng), không giới hạn người dùng lẫn cửa hàng, giữ video 30 → 180 ngày, bản cài máy tính + camera IP, kho riêng.',
    },
    {
      languageCode: 'en-US',
      title: 'ZenPack Enterprise',
      benefits: ['80 GB storage, ≈3,600 videos/month', 'Unlimited users and stores', 'Videos kept 30 to 180 days', 'Desktop app, IP camera, own storage'],
      description:
        'Enterprise plan for warehouses: 80 GB included (≈3,600 videos per month), unlimited users and stores, videos kept 30 to 180 days, desktop app with IP cameras, bring your own storage.',
    },
  ],
};
// Hàng rào: benefit ≤ 40, description ≤ 200 ký tự (runbook 01 §1.3) — Google
// chặn lúc ghi, mà lúc ấy đã đi nửa đường.
for (const [id, ls] of Object.entries(LISTINGS)) {
  for (const l of ls) {
    for (const b of l.benefits) {
      if (b.normalize('NFC').length > 40) throw new Error(`${id} (${l.languageCode}): benefit "${b}" dài ${b.length}/40`);
    }
    if (l.description.normalize('NFC').length > 200) throw new Error(`${id} (${l.languageCode}): description dài ${l.description.length}/200`);
  }
}

// ---- auth ------------------------------------------------------------------

function envVar(name) {
  if (process.env[name]) return process.env[name];
  try {
    for (const line of readFileSync('android/fastlane/.env', 'utf8').split('\n')) {
      if (line.trim().startsWith('#') || !line.includes('=')) continue;
      if (line.slice(0, line.indexOf('=')).trim() === name) return line.slice(line.indexOf('=') + 1).trim();
    }
  } catch {
    /* .env không bắt buộc */
  }
  throw new Error(`Thiếu ${name} (môi trường hoặc android/fastlane/.env)`);
}

const key = JSON.parse(readFileSync(envVar('PLAY_STORE_JSON_KEY_PATH'), 'utf8'));
const b64u = (o) => Buffer.from(typeof o === 'string' ? o : JSON.stringify(o)).toString('base64url');
const iat = Math.floor(Date.now() / 1000);
const head = b64u({ alg: 'RS256', typ: 'JWT' });
const claim = b64u({
  iss: key.client_email,
  scope: 'https://www.googleapis.com/auth/androidpublisher',
  aud: 'https://oauth2.googleapis.com/token',
  iat,
  exp: iat + 3600,
});
const assertion = `${head}.${claim}.${createSign('RSA-SHA256').update(`${head}.${claim}`).sign(key.private_key, 'base64url')}`;
const tokenRes = await (
  await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({ grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer', assertion }),
  })
).json();
if (!tokenRes.access_token) throw new Error(`Không lấy được token: ${JSON.stringify(tokenRes).slice(0, 200)}`);
const TOKEN = tokenRes.access_token;

const BASE = `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${PKG}`;
async function call(method, path, body) {
  const res = await fetch(BASE + path, {
    method,
    headers: { Authorization: `Bearer ${TOKEN}`, ...(body ? { 'Content-Type': 'application/json' } : {}) },
    ...(body ? { body: JSON.stringify(body) } : {}),
  });
  const text = await res.text();
  if (!res.ok) throw new Error(`${res.status} ${method} ${path}\n${text.slice(0, 600)}`);
  return text ? JSON.parse(text) : {};
}

// ---- helpers ---------------------------------------------------------------

// VND không có phần thập phân: tiền nằm hết ở `units`. Ghi units:"249" là bán rẻ
// đi 1000 lần — nanos chỉ dùng cho tiền có phần lẻ như USD.
const toMoney = (currencyCode, amount) => {
  const units = Math.floor(amount);
  const nanos = Math.round((amount - units) * 1e9);
  return { currencyCode, units: String(units), ...(nanos ? { nanos } : {}) };
};
const fromMoney = (m) => (m ? Number(m.units ?? 0) + Number(m.nanos ?? 0) / 1e9 : null);
const sameMoney = (a, b) => a && b && a.currencyCode === b.currencyCode && Math.abs(fromMoney(a) - fromMoney(b)) < 1e-6;

const convertCache = new Map();
async function convert(vnd) {
  if (!convertCache.has(vnd)) {
    const res = await call('POST', '/pricing:convertRegionPrices', { price: toMoney('VND', vnd) });
    regionsVersion = res.regionVersion?.version ?? res.regionVersion ?? regionsVersion;
    convertCache.set(vnd, res);
  }
  return convertCache.get(vnd);
}

// ---- plan ------------------------------------------------------------------

const changes = [];
console.log(`SA: ${key.client_email}\n${APPLY ? 'CHẾ ĐỘ GHI' : 'dry-run'}\n`);

const remote = (await call('GET', '/subscriptions')).subscriptions ?? [];

for (const [productId, terms] of Object.entries(PLANS)) {
  const sub = remote.find((s) => s.productId === productId);
  if (!sub) {
    changes.push(`[THIẾU] ${productId} — không có trên Play, tạo bằng GUI theo runbook §1.2`);
    continue;
  }

  const basePlans = [];
  let touched = false;

  for (const bp of sub.basePlans) {
    const want = terms[bp.basePlanId];
    if (!want) {
      basePlans.push(bp);
      continue;
    }
    const conv = await convert(want.vnd);
    const skip = CAP_SKIP[productId]?.[bp.basePlanId] ?? [];
    // VN và US phải ÉP đúng số của bảng, không lấy số Google quy ra. Google làm
    // tròn về mức "đẹp" của từng nước — đưa nó 2.490.000₫ thì nó trả lại VN
    // 2.500.000₫. Đó chính là lý do ba giá VND trên Play đang sai lệch bảng:
    // ai đó trước đây đã nhận nguyên số Google gợi ý.
    const regional = Object.values(conv.convertedRegionPrices)
      .filter((r) => !skip.includes(r.regionCode))
      .map((r) => ({
        regionCode: r.regionCode,
        newSubscriberAvailability: true,
        price:
          r.regionCode === 'VN'
            ? toMoney('VND', want.vnd)
            : r.regionCode === 'US'
              ? toMoney('USD', want.usd)
              : r.price,
      }));
    if (!regional.some((r) => r.regionCode === 'VN')) {
      regional.unshift({ regionCode: 'VN', newSubscriberAvailability: true, price: toMoney('VND', want.vnd) });
    }

    const before = bp.regionalConfigs ?? [];
    const vndBefore = fromMoney(before.find((r) => r.regionCode === 'VN')?.price);
    const usdBefore = fromMoney(before.find((r) => r.regionCode === 'US')?.price);
    const changed =
      before.length !== regional.length ||
      regional.some((r) => !sameMoney(r.price, before.find((b) => b.regionCode === r.regionCode)?.price));

    if (changed) {
      touched = true;
      changes.push(
        `[giá] ${productId}:${bp.basePlanId}  VN ${vndBefore?.toLocaleString('vi') ?? '—'} → ${want.vnd.toLocaleString('vi')}` +
          `  ·  US $${usdBefore ?? '—'} → $${want.usd}` +
          `  ·  vùng ${before.length} → ${regional.length}`,
      );
    }
    basePlans.push({ ...bp, regionalConfigs: regional, otherRegionsConfig: { ...conv.convertedOtherRegionsPrice, newSubscriberAvailability: true } });
  }

  const wantListings = LISTINGS[productId];
  for (const l of wantListings) {
    const cur = sub.listings?.find((x) => x.languageCode === l.languageCode);
    if (!cur) {
      touched = true;
      changes.push(`[listing+] ${productId}  ${l.languageCode}: thêm mới (${l.benefits.length} benefit)`);
    } else if (
      cur.title !== l.title ||
      cur.description !== l.description ||
      JSON.stringify(cur.benefits ?? []) !== JSON.stringify(l.benefits)
    ) {
      touched = true;
      changes.push(
        `[listing~] ${productId}  ${l.languageCode}: benefit ${cur.benefits?.length ?? 0} → ${l.benefits.length}` +
          (cur.description !== l.description ? ', description đổi' : ''),
      );
    }
  }

  if (touched && APPLY) {
    if (!regionsVersion) throw new Error('Chưa biết regionsVersion — convertRegionPrices phải chạy trước');
    // Mỗi vùng có trần/sàn giá riêng và Google không công bố bảng đó; gói đắt
    // vượt trần ở vài nước (Hàn Quốc tối đa ₩600.000). API chỉ báo MỘT vùng mỗi
    // lần, nên bỏ vùng đó ra rồi thử lại cho tới khi lọt. Vùng bị bỏ được in ra
    // — không bán được ở đâu thì phải nói, đừng để lặng lẽ.
    const dropped = [];
    for (let attempt = 0; ; attempt++) {
      try {
        await call(
          'PATCH',
          `/subscriptions/${productId}?updateMask=basePlans,listings&regionsVersion.version=${encodeURIComponent(regionsVersion)}`,
          { ...sub, basePlans, listings: wantListings },
        );
        break;
      } catch (err) {
        const m = /(\w+): Price for ([A-Z]{2}) must be between (.+?), found/.exec(err.message);
        if (!m || attempt > 40) throw err;
        const [, planId, region, range] = m;
        dropped.push(`${planId}/${region} (trần ${range})`);
        // Chỉ bỏ ở base plan bị từ chối. Gói tháng rẻ hơn gói năm 10 lần nên
        // thường vẫn lọt trần — bỏ cả hai là mất một thị trường không cần mất.
        const bp = basePlans.find((x) => x.basePlanId === planId);
        if (!bp) throw err;
        bp.regionalConfigs = bp.regionalConfigs.filter((r) => r.regionCode !== region);
      }
    }
    if (dropped.length) {
      changes.push(`[bỏ vùng] ${productId}: ${dropped.length} vùng vượt trần giá của Google — ${dropped.join(', ')}`);
    }
  }
}

// ---- report ----------------------------------------------------------------

for (const c of changes) console.log('  ' + c);
console.log(
  changes.length
    ? `\n${changes.length} thay đổi. ${APPLY ? 'ĐÃ GHI.' : 'Chưa ghi gì — thêm --apply để ghi thật.'}`
    : 'Không có gì phải đổi — Play đã khớp bảng gốc.',
);
console.log(
  '\nNhắc: script đặt GIÁ cho các vùng, không mở bán app ở vùng đó. Nước phát hành\n' +
    'nằm ở Play Console → Release → Countries/regions, ngoài tầm API này.',
);
