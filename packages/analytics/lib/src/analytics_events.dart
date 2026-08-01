/// The event vocabulary EvidenceCam reports to Firebase Analytics.
///
/// Names are Vietnamese snake_case without diacritics — the people who read
/// these reports run the packing tables, not an English-speaking data team.
/// Firebase's rules still apply: at most 40 characters, `[A-Za-z0-9_]` only,
/// must start with a letter, no `firebase_` / `google_` / `ga_` prefix.
///
/// Two things stay in Firebase's own English vocabulary on purpose:
///
/// * `login` / `sign_up` / `purchase` are *reserved* events — Firebase builds
///   its funnel, revenue and audience reports on those exact names, so they go
///   through `AnalyticsService.logLogin` and friends instead of being renamed.
/// * `screen_view` is logged automatically; only its `screen_name` **value**
///   is ours, which is what [EcScreens] supplies.
library;

/// Route path to the screen name reported in `screen_view`.
///
/// Keyed by the GoRoute path so a screen is named in exactly one place and the
/// route table stays English, matching the URLs and the code.
abstract final class EcScreens {
  static const byRoute = <String, String>{
    '/': 'man_khoi_dong',
    '/login': 'man_dang_nhap',
    '/register': 'man_dang_ky',
    '/phone-setup': 'man_them_so_dien_thoai',
    '/forgot': 'man_quen_mat_khau',
    '/shops': 'man_chon_cua_hang',
    '/no-shop': 'man_chua_co_cua_hang',
    '/create-shop': 'man_tao_cua_hang',
    '/shop-mgmt': 'man_quan_ly_cua_hang',
    '/shop-detail': 'man_chi_tiet_cua_hang',
    '/invite-member': 'man_moi_thanh_vien',
    '/member-actions': 'man_thao_tac_thanh_vien',
    '/home': 'man_van_don',
    '/record': 'man_ghi_hinh',
    '/account': 'man_tai_khoan',
    '/order': 'man_chi_tiet_don',
    '/video': 'man_chi_tiet_video',
    '/photo': 'man_xem_anh',
    '/video-player': 'man_phat_video',
    '/queue': 'man_hang_doi_tai_len',
    '/type-sheet': 'man_chon_loai_video',
    '/create-type': 'man_tao_loai_video',
    '/manual': 'man_nhap_ma_thu_cong',
    '/scan': 'man_quet_ma',
    '/stop-code': 'man_ma_dung_quay',
    '/confirm-delete': 'man_xac_nhan_xoa',
    '/resolution': 'man_do_phan_giai',
    '/clip-duration': 'man_thoi_luong_clip',
    '/upload-size': 'man_dung_luong_tai_len',
    '/quota': 'man_goi_cuoc',
    '/language': 'man_ngon_ngu',
    '/login-methods': 'man_phuong_thuc_dang_nhap',
    '/change-password': 'man_doi_mat_khau',
    '/edit-profile': 'man_sua_ho_so',
    '/delete-account': 'man_xoa_tai_khoan',
  };

  /// The reported name for [routePath], or `null` when the route is not one we
  /// name. An unmapped route is dropped rather than reported as a raw path, so
  /// a stray English name can never quietly land in the reports.
  static String? of(String? routePath) =>
      routePath == null ? null : byRoute[routePath];
}

/// Custom events. Reserved Firebase events are deliberately absent — see the
/// library doc above.
abstract final class AnalyticsEvents {
  // Tài khoản
  static const loginFailed = 'dang_nhap_loi';
  static const signOut = 'dang_xuat';
  static const emailVerificationSent = 'gui_xac_minh_email';
  static const accountDeleted = 'xoa_tai_khoan';

  // Cửa hàng
  static const shopCreated = 'tao_cua_hang';
  static const shopSelected = 'chon_cua_hang';
  static const memberInvited = 'moi_thanh_vien';
  static const memberRemoved = 'xoa_thanh_vien';

  // Ghi hình
  static const scanSucceeded = 'quet_ma_thanh_cong';
  static const scanFailed = 'quet_ma_that_bai';
  static const codeEnteredManually = 'nhap_ma_thu_cong';
  static const recordingStarted = 'bat_dau_quay';
  static const clipRecorded = 'dung_quay';
  static const orderCutover = 'chuyen_don';
  static const nearClipLimit = 'sap_cham_tran_thoi_luong';
  static const videoTypePicked = 'chon_loai_video';
  static const videoTypeCreated = 'tao_loai_video';

  // Tải lên
  static const uploadCompleted = 'tai_len_xong';
  static const uploadFailed = 'tai_len_loi';
  static const uploadRetried = 'tai_len_thu_lai';

  // Vận đơn & bằng chứng
  static const orderOpened = 'xem_chi_tiet_don';
  static const videoOpened = 'xem_video';
  static const videoShared = 'chia_se_video';
  static const videoDeleted = 'xoa_video';
  static const ordersFiltered = 'loc_van_don';

  // Gói cước
  static const paywallViewed = 'xem_bang_gia';
  static const purchaseStarted = 'bat_dau_mua';

  // Khác
  static const notificationOpened = 'mo_thong_bao';
}

/// Event parameters, same naming rules as the events.
abstract final class AnalyticsParams {
  static const errorType = 'loai_loi';
  static const source = 'nguon';
  static const method = 'phuong_thuc';
  static const platform = 'san';
  static const videoType = 'loai_video';
  static const planCode = 'ma_goi';
  static const durationSeconds = 'thoi_luong_giay';
  static const filter = 'bo_loc';
  static const resultCount = 'so_ket_qua';
  static const attempt = 'lan_thu';
  static const payloadKeyCount = 'so_truong_payload';
}

/// Where an action was triggered from, for [AnalyticsParams.source].
abstract final class AnalyticsSources {
  static const list = 'danh_sach';
  static const detail = 'chi_tiet';
  static const account = 'tai_khoan';
  static const record = 'ghi_hinh';
  static const queue = 'hang_doi';
}
