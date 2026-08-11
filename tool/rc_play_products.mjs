#!/usr/bin/env node
// Gắn nhánh ANDROID vào RevenueCat: 6 product Play → 6 package đã có sẵn của
// offering `default` → entitlement `paid`. Song sinh của rc_products.mjs, vốn
// chỉ dựng nhánh App Store.
//
//   node tool/rc_play_products.mjs            # dry-run: in ra sẽ làm gì, KHÔNG ghi
//   node tool/rc_play_products.mjs --apply    # ghi thật
//
// Cần: RC_V2_KEY · RC_PROJECT_ID (xem tool/rc_api.mjs)
//
// KHÔNG tạo package mới. Một package phục vụ CẢ HAI nền tảng — `basic_1m` đã
// tồn tại và đang giữ product iOS; việc ở đây là gắn thêm product Android vào
// đúng package đó. Tạo `basic_1m_android` là chẻ đôi offering, và paywall sẽ
// hiện gói trùng nhau trên máy nào đọc được cả hai.
//
// VÌ SAO CẦN SCRIPT cho một việc 12 cú click: mã Play có dấu hai chấm
// (`zenpack_sub_basic:p1m`) khác hẳn mã Apple, và gõ sai một ký tự thì webhook
// về backend không tra được `PRODUCT_GRANTS` ⇒ khách trả tiền mà không lên gói,
// KHÔNG có thông báo lỗi ở bất kỳ đâu. Bảng mã lấy từ tool/ec_plans.mjs, cùng
// nguồn với bản Apple.

import { playProducts } from './ec_plans.mjs';
import { rcClient } from './rc_api.mjs';

const OFFERING = 'default';
const ENTITLEMENT = 'paid';

const APPLY = process.argv.includes('--apply');

async function main() {
  const { getAll, post } = rcClient();

  const play = (await getAll('/apps')).find((a) => a.type === 'play_store');
  if (!play) {
    throw new Error(
      'Project chưa có app loại play_store. Tạo ở RC → Project settings → Apps → + New.',
    );
  }
  console.log(`App:  ${play.name} (${play.id})`);

  const offering = (await getAll('/offerings')).find((o) => o.lookup_key === OFFERING);
  if (!offering) throw new Error(`Không tìm thấy offering '${OFFERING}'`);

  const entitlement = (await getAll('/entitlements')).find(
    (e) => e.lookup_key === ENTITLEMENT,
  );
  if (!entitlement) throw new Error(`Không tìm thấy entitlement '${ENTITLEMENT}'`);
  console.log(`Offering: ${offering.lookup_key}  ·  Entitlement: ${entitlement.lookup_key}\n`);

  const productByStoreId = new Map(
    (await getAll('/products')).map((p) => [p.store_identifier, p]),
  );
  const packageByLookup = new Map(
    (await getAll(`/offerings/${offering.id}/packages`)).map((p) => [p.lookup_key, p]),
  );
  const entitlementProductIds = new Set(
    (await getAll(`/entitlements/${entitlement.id}/products`)).map((p) => p.id),
  );

  let missingPackages = 0;

  for (const item of playProducts) {
    const existingProduct = productByStoreId.get(item.storeId);
    const pkg = packageByLookup.get(item.packageLookup);

    // Package thiếu = nhánh iOS chưa dựng xong. Dừng lại chứ không tự tạo:
    // package rỗng lọt vào offering thì paywall hiện một ô không mua được.
    if (!pkg) {
      missingPackages += 1;
      console.log(
        `✕ ${item.storeId.padEnd(32)} thiếu package '${item.packageLookup}' — chạy rc_products.mjs trước`,
      );
      continue;
    }

    const attachedToPackage =
      existingProduct != null &&
      (await getAll(`/packages/${pkg.id}/products`)).some(
        (x) => (x.product?.id ?? x.id) === existingProduct.id,
      );
    const attachedToEntitlement =
      existingProduct != null && entitlementProductIds.has(existingProduct.id);

    if (!APPLY) {
      const todo = [
        !existingProduct && 'tạo product',
        !attachedToPackage && `gắn vào package ${item.packageLookup}`,
        !attachedToEntitlement && `gắn vào entitlement ${ENTITLEMENT}`,
      ].filter(Boolean);
      console.log(
        `${todo.length ? '＋' : '✓'} ${item.storeId.padEnd(32)} ` +
          (todo.length ? todo.join(' · ') : 'đã đủ'),
      );
      continue;
    }

    const product =
      existingProduct ??
      (await post('/products', {
        store_identifier: item.storeId,
        app_id: play.id,
        type: 'subscription',
        display_name: item.displayName,
      }));

    if (!attachedToPackage) {
      await post(`/packages/${pkg.id}/actions/attach_products`, {
        products: [{ product_id: product.id, eligibility_criteria: 'all' }],
      });
    }
    if (!attachedToEntitlement) {
      await post(`/entitlements/${entitlement.id}/actions/attach_products`, {
        product_ids: [product.id],
      });
    }
    console.log(`✅ ${item.storeId.padEnd(32)} product=${product.id} package=${pkg.id}`);
  }

  if (missingPackages) {
    throw new Error(
      `${missingPackages}/6 package chưa tồn tại — nhánh iOS phải dựng xong trước.`,
    );
  }
  if (!APPLY) console.log('\n(dry-run — thêm --apply để ghi thật)');
  else {
    console.log(
      '\nXác nhận lại bằng khoá công khai Android (phải trả về 6 package, không phải 0):\n' +
        "  curl -s \"https://api.revenuecat.com/v1/subscribers/probe/offerings\" \\\n" +
        '    -H "Authorization: Bearer $REVENUECAT_ANDROID_KEY" -H "X-Platform: android"',
    );
  }
}

main().catch((e) => {
  console.error(`\n❌ ${e.message}`);
  process.exit(1);
});
