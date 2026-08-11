// Client REST v2 của RevenueCat. Dùng chung bởi `rc_products.mjs` (App Store)
// và `rc_play_products.mjs` (Play Store).
//
// Tách ra vì chỗ phân trang có một cái bẫy: `next_page` mà RC trả về là ĐƯỜNG
// DẪN TƯƠNG ĐỐI đã gồm sẵn `/v2/projects/<id>`, nên nối thẳng vào base URL là
// hỏng. Hai bản chép của đoạn đó sớm muộn cũng có một bản chép sai, và triệu
// chứng là "chỉ thấy trang đầu" — trông y hệt như dữ liệu thật chỉ có bấy nhiêu.
//
// Cần: `RC_V2_KEY` (Project settings → API keys → Secret API keys, bản V2) và
// `RC_PROJECT_ID`. Cả hai đọc lúc GỌI chứ không lúc import, để một script lỡ
// import module này vẫn còn cơ hội in hướng dẫn thay vì chết ngay dòng đầu.

const API = 'https://api.revenuecat.com/v2';

const req = (name) => {
  const value = process.env[name];
  if (!value) throw new Error(`Thiếu biến môi trường ${name}`);
  return value;
};

export function rcClient() {
  const key = req('RC_V2_KEY');
  const project = req('RC_PROJECT_ID');

  async function call(method, path, body) {
    const res = await fetch(`${API}/projects/${project}${path}`, {
      method,
      headers: {
        Authorization: `Bearer ${key}`,
        ...(body ? { 'Content-Type': 'application/json' } : {}),
      },
      ...(body ? { body: JSON.stringify(body) } : {}),
    });
    const json = res.status === 204 ? null : await res.json();
    if (!res.ok) {
      throw new Error(`${method} ${path} → ${res.status} ${JSON.stringify(json)}`);
    }
    return json;
  }

  async function getAll(path) {
    const out = [];
    let next = path;
    while (next) {
      const page = await call('GET', next);
      out.push(...(page.items ?? []));
      next = page.next_page
        ? page.next_page.replace(`/v2/projects/${project}`, '')
        : null;
    }
    return out;
  }

  return {
    get: (p) => call('GET', p),
    post: (p, b) => call('POST', p, b),
    getAll,
  };
}
