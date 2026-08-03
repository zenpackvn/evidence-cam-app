#!/usr/bin/env node
// Tạo 9 sản phẩm + 9 package trong RevenueCat, khớp đúng 9 IAP đã tạo bên Apple
// (tool/asc_iap.mjs). Bảng gói dùng chung ở tool/ec_plans.mjs.
//
//   node tool/rc_products.mjs            # dry-run
//   node tool/rc_products.mjs --apply
//
// Cần: RC_V2_KEY (Project Settings → API keys → V2) · RC_PROJECT_ID
//
// KHÔNG tạo entitlement. Sản phẩm là consumable: gắn entitlement vào thì RC báo
// "mở khóa vĩnh viễn", sai hẳn với mô hình mua đứt cộng ngày. Nguồn sự thật về
// hạn dùng là backend; RC chỉ là biên nhận đã thanh toán.

import { products } from './ec_plans.mjs';

const API = 'https://api.revenuecat.com/v2';
const OFFERING = 'default'; // lookup_key của offering app sẽ đọc

const req = (n) => {
  const v = process.env[n];
  if (!v) throw new Error(`Thiếu biến môi trường ${n}`);
  return v;
};
const KEY = req('RC_V2_KEY');
const PROJECT = req('RC_PROJECT_ID');

async function call(method, path, body) {
  const res = await fetch(`${API}/projects/${PROJECT}${path}`, {
    method,
    headers: {
      Authorization: `Bearer ${KEY}`,
      ...(body ? { 'Content-Type': 'application/json' } : {}),
    },
    ...(body ? { body: JSON.stringify(body) } : {}),
  });
  const json = res.status === 204 ? null : await res.json();
  if (!res.ok) throw new Error(`${method} ${path} → ${res.status} ${JSON.stringify(json)}`);
  return json;
}
const get = (p) => call('GET', p);
const post = (p, b) => call('POST', p, b);

/// RC phân trang bằng `next_page` (đường dẫn tương đối), không phải link tuyệt đối.
async function getAll(path) {
  const out = [];
  let next = path;
  while (next) {
    const page = await get(next);
    out.push(...(page.items ?? []));
    next = page.next_page ? page.next_page.replace(`/v2/projects/${PROJECT}`, '') : null;
  }
  return out;
}

async function main() {
  const apply = process.argv.includes('--apply');

  const apps = await getAll('/apps');
  const store = apps.find((a) => a.type === 'app_store');
  if (!store) throw new Error('Project chưa có app loại app_store');
  console.log(`App: ${store.name} (${store.id})`);

  const offering = (await getAll('/offerings')).find((o) => o.lookup_key === OFFERING);
  if (!offering) throw new Error(`Không tìm thấy offering '${OFFERING}'`);
  console.log(`Offering: ${offering.lookup_key} (${offering.id})\n`);

  const byStoreId = new Map(
    (await getAll('/products')).map((p) => [p.store_identifier, p]),
  );
  const byPackage = new Map(
    (await getAll(`/offerings/${offering.id}/packages`)).map((p) => [p.lookup_key, p]),
  );

  for (const p of products) {
    const lookup = `${p.planCode}_${p.days === 30 ? '1m' : p.days === 180 ? '6m' : '12m'}`;
    const haveProduct = byStoreId.get(p.productId);
    const havePackage = byPackage.get(lookup);

    if (!apply) {
      const todo = [!haveProduct && 'product', !havePackage && 'package'].filter(Boolean);
      console.log(
        `${todo.length ? '＋' : '✓'} ${p.productId.padEnd(22)} ` +
        (todo.length ? `cần tạo: ${todo.join(' + ')}` : 'đã đủ'),
      );
      continue;
    }

    let product = haveProduct;
    if (!product) {
      product = await post('/products', {
        store_identifier: p.productId,
        app_id: store.id,
        type: 'consumable',
        display_name: p.localizations[0].name,
      });
    }

    let pkg = havePackage;
    if (!pkg) {
      // Tạo package RỖNG rồi attach — RC từ chối `products` trong request tạo
      // ("Additional properties are not allowed"), phải gọi action riêng.
      pkg = await post(`/offerings/${offering.id}/packages`, {
        lookup_key: lookup,
        display_name: p.localizations[0].name,
      });
    }

    const attached = (await getAll(`/packages/${pkg.id}/products`))
      .some((x) => (x.product?.id ?? x.id) === product.id);
    if (!attached) {
      await post(`/packages/${pkg.id}/actions/attach_products`, {
        products: [{ product_id: product.id, eligibility_criteria: 'all' }],
      });
    }
    console.log(`✅ ${p.productId.padEnd(22)} product=${product.id} package=${pkg.id}`);
  }

  if (!apply) console.log('\n(dry-run — thêm --apply để tạo thật)');
}

main().catch((e) => {
  console.error(`\n❌ ${e.message}`);
  process.exit(1);
});
