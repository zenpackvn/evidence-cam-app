// Nguồn duy nhất cho các sản phẩm mua-trong-app, dùng chung bởi asc_iap.mjs
// (tạo bên Apple) và rc_products.mjs (tạo bên RevenueCat). Hai script tự giữ
// bảng riêng thì sớm muộn cũng lệch mã hoặc lệch giá.
//
// Bản 4 (2026-08-10): 3 gói × 2 thời hạn = 6 sản phẩm. Trục tính tiền là SỐ
// VIDEO mỗi tháng chứ không phải GB, và kỳ 6 tháng đã ngừng bán.
//
// 9 SKU của Bản 3 (`zenpack_{basic,saver,premium}_{1m,6m,12m}`) vẫn tồn tại
// trên App Store — mã store không xoá được. Chúng chỉ cần gỡ khỏi bán; backend
// vẫn tra được chúng (`PRODUCT_GRANTS` giữ cả mã cũ) để khách đã mua không mất
// tiền oan.
//
// Vì thế thế hệ này phải đổi tiền tố sang `zenpack_sub_`: `zenpack_basic_1m` và
// `zenpack_basic_12m` đã bị 9 SKU kia chiếm, đăng ký lại không được.
//
// Runbook đăng ký tay: specs/projects/evidencecam/technical-spec/
// monetization-setup/00-danh-muc-san-pham.md

// `seats` là chữ, không phải số: gói Doanh nghiệp không giới hạn người dùng nên
// không có số để định dạng. Đây là trục phân gói thứ hai sau số video, và là
// thứ duy nhất ngoài số video nhét vừa 45 ký tự mô tả của Apple.
export const PLANS = [
  { code: 'basic', videos: 1_000, vi: 'Cơ bản', en: 'Basic', seatsVi: '5 người dùng/shop', seatsEn: '5 users/shop' },
  { code: 'pro', videos: 3_000, vi: 'Chuyên nghiệp', en: 'Pro', seatsVi: '15 người dùng/shop', seatsEn: '15 users/shop' },
  { code: 'enterprise', videos: 8_000, vi: 'Doanh nghiệp', en: 'Enterprise', seatsVi: 'không giới hạn người dùng', seatsEn: 'unlimited users' },
];

// `google` = base plan ID bên Play. Hai cửa hàng mô hình hoá khác nhau nên mã
// sản phẩm khác nhau, và ánh xạ đó phải nằm ở BẢNG NÀY chứ không nằm trong
// script: backend `services/subscriptions.ts` (CURRENT_TERMS) giữ đúng cặp
// apple/google này, hai bên lệch nhau nghĩa là khách trả tiền mà webhook về
// không tra được gói — im lặng, không báo lỗi.
export const TERMS = [
  { key: '1m', google: 'p1m', days: 30, viUnit: '1 tháng', enUnit: '1 month' },
  { key: '12m', google: 'p1y', days: 365, viUnit: '12 tháng', enUnit: '12 months' },
];

// Giá trong app = ĐÚNG BẰNG giá web (chốt 2026-08-10) — chép từ backend
// `services/pricing.ts` WEB_PRICES. Mức +15% bù hoa hồng của bản trước đã bỏ:
// khách so giá hai kênh phải thấy cùng một con số, hoa hồng cửa hàng trừ vào
// biên chứ không cộng vào giá bán.
//
// Đây là giá MUỐN, không phải điểm giá đã xác minh — Apple/Google chỉ nhận các
// price point có sẵn. Chọn điểm gần nhất, lệch quá ±1% thì dừng lại hỏi chứ
// đừng tự nắn: cam kết là "hai kênh cùng giá".
const PRICES = {
  basic: { '1m': 249_000, '12m': 2_490_000 },
  pro: { '1m': 549_000, '12m': 5_490_000 },
  enterprise: { '1m': 1_190_000, '12m': 11_900_000 },
};

// Apple: displayName ≤30 ký tự, description ≤45.
//
// Mô tả KHÔNG nhắc lại thời hạn ("dùng 1 tháng") nữa: đó là lời của gói mua đứt,
// còn sản phẩm bây giờ tự gia hạn — store đã hiện chu kỳ cạnh giá, và name đã
// nói. 45 ký tự đó để dành cho trục phân gói thật: video/tháng + người dùng/shop.
// Bốn gạch đầu dòng của website không nhét vừa; chúng nằm ở paywall.
export const products = PLANS.flatMap((p) =>
  TERMS.map((t) => ({
    productId: `zenpack_sub_${p.code}_${t.key}`,
    planCode: p.code,
    days: t.days,
    referenceName: `ZenPack ${p.en} ${t.enUnit}`,
    priceVnd: PRICES[p.code][t.key],
    localizations: [
      {
        locale: 'vi',
        name: `${p.vi} ${t.viUnit}`,
        description: `${p.videos.toLocaleString('vi')} video/tháng, ${p.seatsVi}`,
      },
      {
        locale: 'en-US',
        name: `${p.en} ${t.enUnit}`,
        description: `${p.videos.toLocaleString('en')} videos/month, ${p.seatsEn}`,
      },
    ],
  })),
);

/// Mã Play của cùng 6 sản phẩm đó. Google gộp `3 subscription × 2 base plan`
/// nên mã có dấu hai chấm; `packageLookup` là khoá package trong RevenueCat,
/// dùng CHUNG với bản iOS — một package phục vụ cả hai nền tảng.
export const playProducts = PLANS.flatMap((p) =>
  TERMS.map((t) => ({
    storeId: `zenpack_sub_${p.code}:${t.google}`,
    packageLookup: `${p.code}_${t.key}`,
    displayName: `ZenPack ${p.en} ${t.enUnit}`,
  })),
);

// Hàng rào: chuỗi Doanh nghiệp tiếng Việt dài 44/45. Thêm một chữ hay dán nhầm
// dạng NFD (dấu tách rời, cùng câu đếm thành 54) là store chặn — mà lỗi đó chỉ
// lộ ra lúc đang ngồi trong console dán tay. Bắt ngay ở đây thay vì ở đó.
for (const prod of products) {
  for (const l of prod.localizations) {
    const nfc = l.name.normalize('NFC');
    const desc = l.description.normalize('NFC');
    if (nfc.length > 30 || desc.length > 45) {
      throw new Error(
        `${prod.productId} (${l.locale}): name ${nfc.length}/30, description ${desc.length}/45`,
      );
    }
  }
}
