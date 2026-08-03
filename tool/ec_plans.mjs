// Nguồn duy nhất cho 9 sản phẩm mua-trong-app, dùng chung bởi asc_iap.mjs
// (tạo bên Apple) và rc_products.mjs (tạo bên RevenueCat). Hai script tự giữ
// bảng riêng thì sớm muộn cũng lệch mã hoặc lệch giá.
//
// Đối chiếu: specs/projects/evidencecam/product-spec/002-pricing-plans/bang-gia.md §4

export const PLANS = [
  { code: 'basic',   gb: 60,  vi: 'Cơ bản',    en: 'Basic'   },
  { code: 'saver',   gb: 120, vi: 'Tiết kiệm', en: 'Saver'   },
  { code: 'premium', gb: 200, vi: 'Cao cấp',   en: 'Premium' },
];

export const TERMS = [
  { key: '1m',  days: 30,  viUnit: '1 tháng',  enUnit: '1 month'   },
  { key: '6m',  days: 180, viUnit: '6 tháng',  enUnit: '6 months'  },
  { key: '12m', days: 365, viUnit: '12 tháng', enUnit: '12 months' },
];

// Điểm giá THẬT của Apple ở VN (đối chiếu 2026-08-03). Bốn mức lệch nhẹ so với ý
// định "+15% chẵn" vì Apple chỉ nhận điểm giá có sẵn, không nhận giá tùy ý.
const PRICES = {
  basic:   { '1m': 169_000, '6m': 939_000,   '12m': 1_799_000 },
  saver:   { '1m': 319_000, '6m': 1_749_000, '12m': 3_390_000 },
  premium: { '1m': 459_000, '6m': 2_549_000, '12m': 4_849_000 },
};

// Apple: displayName ≤30 ký tự, description ≤45.
export const products = PLANS.flatMap((p) =>
  TERMS.map((t) => ({
    productId: `zenpack_${p.code}_${t.key}`,
    planCode: p.code,
    days: t.days,
    referenceName: `ZenPack ${p.en} ${t.enUnit}`,
    priceVnd: PRICES[p.code][t.key],
    localizations: [
      { locale: 'vi',    name: `${p.vi} ${t.viUnit}`, description: `${p.gb}GB lưu trữ, dùng trong ${t.viUnit}` },
      { locale: 'en-US', name: `${p.en} ${t.enUnit}`, description: `${p.gb}GB of storage for ${t.enUnit}` },
    ],
  })),
);
