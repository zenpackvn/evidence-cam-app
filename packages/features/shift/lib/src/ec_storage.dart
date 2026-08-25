/// Kho lưu trữ video của shop — màn xem tình trạng và màn cắm kho riêng.
///
/// Vì sao app cần màn này khi web admin đã có: kho hỏng là chuyện xảy ra GIỮA
/// CA ĐÓNG HÀNG, và người đầu tiên chịu hậu quả là người đang cầm điện thoại
/// quay. Bắt họ mở laptop để biết clip của mình đang nằm ở vùng chờ tạm là bắt
/// họ phát hiện ra sự cố muộn nhất có thể.
///
/// Phần XEM mở cho mọi vai trò; phần ĐỔI chỉ chủ shop — máy chủ chặn bằng
/// `owner_only`, ở đây chỉ là không chào cái nút chắc chắn 403.
library;

import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:ec_ui/ec_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localization/localization.dart';

/// Kho shop đang dùng. Không cấu hình gì = [system].
enum EcStorageKind { system, s3, gdrive }

/// Bảng tình trạng kho — bốn con số và một mốc thời gian.
class EcStorageHealth {
  const EcStorageHealth({
    this.total = 0,
    this.intact = 0,
    this.unreachable = 0,
    this.mismatched = 0,
    this.pendingRelay = 0,
    this.lastCheckedAt,
  });

  final int total;
  final int intact;

  /// Không mở được ở kho của shop. Với người bán thì bằng chứng coi như đã mất
  /// cho tới khi họ sửa quyền bên phía nhà cung cấp.
  final int unreachable;

  /// Sai lệch so với hồ sơ niêm phong — tệp đã bị sửa sau khi hệ thống nhận.
  final int mismatched;

  /// Còn ở vùng chờ tạm vì kho đang có sự cố. Chưa mất, nhưng chưa về nhà.
  final int pendingRelay;

  /// Lượt rà gần nhất. `null` = chưa rà lần nào — nói thẳng ra, vì một bảng
  /// toàn số 0 không có mốc thời gian đọc y hệt một kho hoàn hảo.
  final int? lastCheckedAt;

  bool get hasProblems => unreachable > 0 || mismatched > 0 || pendingRelay > 0;
}

/// Trạng thái kho đủ để dựng màn hình.
class EcStorageState {
  const EcStorageState({
    this.kind = EcStorageKind.system,
    this.configuredKind,
    this.configuredKinds = const {},
    this.label = '',
    this.ok = true,
    this.lastError,
    this.health = const EcStorageHealth(),
    this.byosAllowed = false,
    this.canManage = false,
    this.presignedDownload = true,
    this.objectLock = false,
    this.driveEmail,
    this.s3Endpoint = '',
    this.s3Region = '',
    this.s3Bucket = '',
    this.s3Prefix = '',
    this.s3KeyMasked = '',
  });

  final EcStorageKind kind;

  /// Kho ĐÃ CẮM, kể cả khi shop đang dùng kho hệ thống.
  ///
  /// Khác [kind]: kia là nơi video đang được cất, đây là cấu hình còn giữ trên
  /// máy chủ. Bằng nhau trong phần lớn trường hợp; lệch nhau đúng lúc người bán
  /// chọn kho khác mà chưa đăng xuất — và lúc ấy chọn lại kho cũ chỉ là bật lại,
  /// không phải cấp quyền từ đầu.
  final EcStorageKind? configuredKind;

  /// MỌI loại kho shop đang giữ tài khoản, kể cả loại đang tắt.
  ///
  /// Một shop giữ được cấu hình của cả S3 lẫn Drive cùng lúc, nên câu hỏi "thẻ
  /// này đã có tài khoản chưa" phải hỏi tập hợp này chứ không hỏi
  /// [configuredKind] — cái đó chỉ là loại đang dùng (hoặc dùng gần nhất).
  ///
  /// Rỗng với bản máy chủ cũ; lúc đó rơi về [configuredKind] một mình.
  final Set<EcStorageKind> configuredKinds;

  /// Loại kho [k] đã có tài khoản trên máy chủ chưa.
  bool hasAccountFor(EcStorageKind k) => configuredKinds.isEmpty
      ? configuredKind == k
      : configuredKinds.contains(k);

  /// Có tài khoản kho riêng nào không.
  bool get hasAnyAccount => configuredKinds.isEmpty
      ? configuredKind != null
      : configuredKinds.isNotEmpty;

  /// Kho riêng đã cắm nhưng đang KHÔNG dùng.
  bool get parked => configuredKind != null && configuredKind != kind;

  /// Dòng nhận diện kho: `bucket/prefix`, hoặc tên thư mục Drive.
  final String label;
  final bool ok;
  final String? lastError;
  final EcStorageHealth health;

  /// Gói có mở kho riêng không. Đọc từ máy chủ, KHÔNG suy từ mã gói ở client.
  final bool byosAllowed;

  /// Actor có phải chủ shop không.
  final bool canManage;

  /// False (Google Drive) = video đi vòng qua máy chủ, phát chậm hơn hẳn.
  final bool presignedDownload;

  /// Cơ sở duy nhất để hứa "bằng chứng không thể xoá".
  final bool objectLock;

  /// Tài khoản Google đang giữ kho. Chỉ để người dùng nhận ra mình đã cắm
  /// nhầm tài khoản nào — đổi tài khoản là cắm lại từ đầu.
  final String? driveEmail;

  /// Cấu hình S3 đang lưu, để điền sẵn lại vào form lúc sửa.
  ///
  /// Khoá KHÔNG có ở đây theo đúng nghĩa đen: máy chủ chỉ trả bốn ký tự cuối
  /// của access key và không bao giờ trả secret. [s3KeyMasked] chỉ để làm chữ
  /// mờ trong ô, giúp khách nhận ra mình đã dán khoá nào.
  final String s3Endpoint;
  final String s3Region;
  final String s3Bucket;
  final String s3Prefix;
  final String s3KeyMasked;
}

/// Màn "Kho lưu trữ": chọn một trong ba nơi cất video của shop.
class EcStorageScreen extends StatefulWidget {
  const EcStorageScreen({
    required this.state,
    this.onBack,
    this.onConnectS3,
    this.onConnectDrive,
    this.onSwitchDriveAccount,
    this.onSaveS3,
    this.s3ErrorText,
    this.onTestS3,
    this.s3TestPassed = false,
    this.onCancel,
    this.onDisconnect,
    this.onUseSystem,
    this.onResumeStorage,
    this.onPick,
    this.busy = false,
    super.key,
  });

  final EcStorageState state;
  final VoidCallback? onBack;

  /// Sửa cấu hình của kho S3 ĐANG dùng — mở màn riêng.
  ///
  /// Lúc cắm mới thì không đi đường này nữa: form nằm thẳng trong thẻ, xem
  /// [onSaveS3].
  final VoidCallback? onConnectS3;

  /// Mở hộp thoại Google. `true` = đã cắm xong, `false` = người dùng huỷ hoặc
  /// hỏng.
  ///
  /// Trả về kết quả chứ không phải `void`: chạm vào thẻ Drive là hộp thoại bật
  /// lên NGAY, nên màn này phải biết lúc nào người dùng bấm Huỷ để trả dấu tích
  /// về kho cũ. Không có tín hiệu đó thì dấu tích nằm lại ở Drive và màn hình
  /// nói dối về nơi video đang được cất.
  final Future<bool> Function()? onConnectDrive;

  /// Đổi sang tài khoản Google khác cho kho Drive ĐANG dùng.
  ///
  /// Tách khỏi [onConnectDrive] vì đường kia tự chặn khi kho hiện tại đã là
  /// Drive — mà đó đúng là lúc người ta muốn đổi tài khoản.
  final VoidCallback? onSwitchDriveAccount;

  /// Gỡ tài khoản của MỘT loại kho. Nhận loại vì shop giữ được tài khoản của
  /// cả hai — không nói rõ thì lượt gỡ rơi vào kho đang dùng, tức bấm "Đăng
  /// xuất Drive" lúc S3 đang bật sẽ xoá mất S3.
  final ValueChanged<EcStorageKind>? onDisconnect;

  /// Về kho hệ thống, GIỮ nguyên cấu hình đã cắm. Đây là việc của nút Lưu khi
  /// người dùng chọn thẻ Cloud Zenpack — LƯU LÀ LƯU, không hỏi lại, không đăng
  /// xuất. Muốn cắt đứt tài khoản thì có nút đăng xuất riêng.
  final VoidCallback? onUseSystem;

  /// Dùng lại kho đã cắm mà chưa đăng xuất. Không mở màn cấp quyền nào.
  /// Dùng lại kho ĐÃ CẮM: chỉ bật công tắc, không mở màn cấp quyền nào. Nhận
  /// loại kho vì shop có thể đang giữ tài khoản của cả hai.
  final ValueChanged<EcStorageKind>? onResumeStorage;

  /// Bấm Lưu khi đang chọn S3: gửi sáu ô của form trong thẻ đi.
  ///
  /// `null` = màn này không cắm S3 được (test dựng màn tối giản); thẻ vẫn chọn
  /// được nhưng không mở form.
  final void Function({
    required String endpoint,
    required String bucket,
    required String accessKeyId,
    required String secretAccessKey,
    required String region,
    required String prefix,
  })?
  onSaveS3;

  /// Câu `hint` nguyên văn từ máy chủ sau một lượt lưu hỏng, vẽ dưới form.
  final String? s3ErrorText;

  /// Bấm Kiểm tra: thử sáu ô hiện tại mà KHÔNG lưu.
  ///
  /// Tách khỏi [onSaveS3] vì hai việc khác nhau: dò quyền bên nhà cung cấp
  /// thường mất vài lượt, và mỗi lượt thử không được thay cái kho đang chạy.
  final void Function({
    required String endpoint,
    required String bucket,
    required String accessKeyId,
    required String secretAccessKey,
    required String region,
    required String prefix,
  })?
  onTestS3;

  /// Lượt Kiểm tra gần nhất có xanh không. Bên gọi giữ, vì chỉ nó thấy kết quả
  /// máy chủ trả về.
  ///
  /// Nút Lưu của form S3 đợi cờ này: lưu là THAY cái kho đang giữ bằng chứng,
  /// và một cấu hình sai được lưu thì clip quay sau đó không có chỗ nào nhận —
  /// người bán chỉ biết khi mở đơn ra tìm video.
  final bool s3TestPassed;

  /// Bấm Huỷ — bên gọi dọn [s3ErrorText] của lượt lưu trước.
  ///
  /// Màn này tự trả dấu tích và sáu ô về chỗ cũ; riêng câu lỗi thì nó không
  /// giữ, nên phải nhờ bên gọi.
  final VoidCallback? onCancel;

  /// Người dùng vừa bấm chọn một kho — bắn ở MỌI lượt bấm, kể cả khi luồng
  /// cắm kho phía sau không chạy được.
  ///
  /// Bên gọi dùng nó để nhớ lựa chọn ngay trên máy. Tách khỏi
  /// `onConnectS3`/`onConnectDrive` vì hai thứ khác nhau: kia là "hãy cắm kho
  /// này", còn đây chỉ là "người dùng đã chỉ vào kho này".
  final void Function(EcStorageKind kind)? onPick;

  /// Đang chạy một thao tác mạng — khoá nút để không bấm hai lần.
  final bool busy;

  @override
  State<EcStorageScreen> createState() => _EcStorageScreenState();
}

class _EcStorageScreenState extends State<EcStorageScreen> {
  /// Kho người dùng vừa bấm. Dấu tích nhảy sang ngay lúc chạm, không đợi máy
  /// chủ trả lời — luồng cắm kho riêng còn phải qua màn nhập khoá hoặc màn cấp
  /// quyền, mà một cú chạm không thấy phản hồi thì người dùng bấm lại lần nữa.
  late EcStorageKind _picked = widget.state.kind;

  /// Sáu ô của form S3. Sống ở đây chứ không trong thẻ: nút Lưu nằm trên đầu
  /// màn và phải đọc được giá trị người dùng vừa gõ.
  final _s3 = _S3Controllers();

  /// Đang sửa cấu hình của kho S3 ĐANG dùng.
  ///
  /// Cùng cách bản web làm: "Đổi cấu hình" mở đúng cái form đó ngay trong thẻ
  /// chứ không đẩy sang màn khác. Cần một cờ riêng vì lúc này lựa chọn không
  /// đổi — kho đang dùng là S3 và người dùng vẫn chọn S3.
  bool _editingS3 = false;

  /// Có ô nào bị sửa KỂ TỪ lượt Kiểm tra gần nhất không.
  ///
  /// Thử xanh rồi đổi endpoint thì kết quả cũ không còn nói gì về bộ giá trị
  /// đang nằm trên màn — mở khoá nút Lưu bằng một lượt thử của cấu hình khác
  /// là đúng cái bẫy mà việc bắt thử trước sinh ra để tránh.
  bool _editedSinceTest = true;

  /// Sáu ô lúc vừa mở "Đổi cấu hình". `null` = đang cắm lần đầu.
  ///
  /// Dùng để trả lời "đã đổi gì chưa": chỉ khi đổi rồi thì nút Kiểm tra mới có
  /// việc để làm — thử lại y nguyên cấu hình đang chạy là một lượt gọi ra kho
  /// khách để xác nhận điều đã biết.
  List<String>? _s3Prefilled;

  /// Lượt Kiểm tra do chính màn này bắn đi và đang chờ máy chủ trả lời.
  ///
  /// [didUpdateWidget] đọc "vừa bận xong mà kho không đổi" thành "người dùng
  /// huỷ giữa chừng" và đóng form lại. Một lượt Kiểm tra XANH khớp đúng mô tả
  /// đó — nó cố ý KHÔNG đổi kho — nên không tách ra thì thử thành công là form
  /// đóng sập, mang theo sáu ô vừa gõ. Người dùng thử được đúng một lần, và
  /// muốn thử lần nữa thì phải mở lại "Đổi cấu hình" rồi gõ lại từ đầu.
  bool _testing = false;

  /// Form đang khác so với lúc mở ra.
  bool get _s3Changed {
    final before = _s3Prefilled;
    if (before == null) return true;
    final now = _s3.snapshot;
    for (var i = 0; i < before.length; i++) {
      if (before[i] != now[i]) return true;
    }
    return false;
  }

  @override
  void dispose() {
    _s3.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant EcStorageScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Máy chủ chốt xong thì bám theo nó.
    if (oldWidget.state.kind != widget.state.kind) {
      _picked = widget.state.kind;
      _editingS3 = false;
      return;
    }
    // Một lượt thao tác kết thúc mà kho vẫn như cũ = người dùng huỷ giữa chừng;
    // trả dấu tích về đúng chỗ, vì để nó nằm lại chỗ vừa bấm là nói dối về nơi
    // video đang được cất.
    //
    // TRỪ khi lượt đó trả về một câu lỗi. Lưu kho S3 hỏng cũng là "thao tác
    // xong mà kho không đổi", nên nhánh trên từng cuốn phăng cả form lẫn sáu ô
    // vừa gõ NGAY LÚC câu lỗi hiện ra — người dùng thấy thẻ đóng lại, không
    // thấy gì khác, và kết luận nút Lưu hỏng. Có lỗi thì form phải ở lại cùng
    // thứ vừa gõ và lý do hỏng.
    if (oldWidget.busy && !widget.busy) {
      // Lượt Kiểm tra không phải một thao tác bỏ dở: chạy xong thì mọi thứ phải
      // nằm y nguyên chỗ cũ để người dùng đọc kết quả rồi sửa tiếp.
      if (_testing) {
        _testing = false;
        return;
      }
      if (widget.s3ErrorText == null) {
        _picked = widget.state.kind;
        _editingS3 = false;
      }
    }
  }

  bool get _own => widget.state.kind != EcStorageKind.system;

  /// Thẻ này có chạm được không.
  ///
  /// Gói chưa mở kho riêng thì hai thẻ S3 và Drive KHÔNG chạm được, chứ không
  /// phải chạm được rồi tắc ở nút Lưu. Cho dấu tích nhảy sang một kho người
  /// dùng không dùng được là mời họ bấm vào ngõ cụt, rồi để họ tự đoán vì sao
  /// nút Lưu không sáng.
  ///
  /// TRỪ kho đang dùng hoặc đã cắm: shop hạ gói vẫn phải xem được tình trạng
  /// và gỡ kho ra. Khoá luôn cả đường đó thì họ kẹt với một cái kho không tháo
  /// được — máy chủ cũng cố ý không chặn hai việc ấy.
  bool _canPick(EcStorageKind kind) {
    final state = widget.state;
    if (kind == EcStorageKind.system) return true;
    if (state.kind == kind || state.hasAccountFor(kind)) return true;
    return state.byosAllowed;
  }

  /// Chạm vào một thẻ: CHỈ nhích dấu tích sang đó. Không chạy gì cả.
  ///
  /// Trước đây chạm là chạy thẳng luồng cắm kho — người bán quệt tay vào thẻ
  /// Drive là màn cấp quyền Google bật lên, và đổi nơi cất bằng chứng của cả
  /// cửa hàng không phải việc nên xảy ra sau một cú chạm nhầm. Giờ chọn là
  /// chọn, áp dụng nằm ở nút lưu trên đầu màn.
  ///
  /// Thẻ nào gói chưa mở thì [_canPick] đã chặn từ trước; ở đây chỉ còn những
  /// thẻ thật sự chọn được.
  void _pick(EcStorageKind kind) {
    setState(() {
      _picked = kind;
      // Chạm sang thẻ khác thì thôi sửa: để cờ bật là quay lại thẻ S3 thấy form
      // mở sẵn mà không nhớ vì sao.
      if (kind != EcStorageKind.s3) _editingS3 = false;
    });
    if (kind == EcStorageKind.gdrive) unawaited(_startDrive());
  }

  /// Chạm thẻ Drive là mở thẳng màn cấp quyền của Google.
  ///
  /// Được phép làm vậy vì thẻ này đã nói hết phần của nó TRƯỚC khi ai chạm
  /// vào: phần mô tả của Drive mở sẵn ngay lúc vào màn, không đợi dấu tích.
  /// Có lúc nó chỉ mở khi thẻ được chọn — mà chọn cũng chính là chạm, nên chữ
  /// vừa hiện được một nhịp thì màn Google đã che mất, và người dùng không kịp
  /// đọc gì.
  ///
  /// Huỷ ở hộp thoại thì dấu tích quay về kho đang thật sự dùng, và không có
  /// lựa chọn nào được ghi xuống máy.
  Future<void> _startDrive() async {
    final state = widget.state;
    if (!state.canManage ||
        !state.byosAllowed ||
        widget.busy ||
        // ĐÃ CÓ tài khoản Drive thì chạm chỉ là chọn thẻ, không mở lại màn cấp
        // quyền. Hỏi "kho đang dùng có phải Drive không" là sai kể từ khi shop
        // giữ được tài khoản của cả hai kho: đang dùng S3 mà Drive vẫn còn tài
        // khoản là chuyện thường, và lúc đó chạm vào Drive lại bị đẩy đi cấp
        // quyền lần nữa cho một tài khoản đang nằm sẵn trên máy chủ.
        state.hasAccountFor(EcStorageKind.gdrive)) {
      return;
    }
    final connect = widget.onConnectDrive;
    if (connect == null) return;
    // KHÔNG ghi lựa chọn xuống máy ở đây.
    //
    // `onPick` ghi xuống bộ nhớ máy, mà lượt cấp quyền này người dùng còn huỷ
    // được. Ghi trước rồi họ bấm Huỷ thì lựa chọn "Drive" nằm lại trong máy:
    // thoát ra vào lại, màn hình đọc lựa chọn đó và vẽ thẻ Drive như một kho
    // đang dùng — kèm cả nút "Đăng xuất khỏi Drive" cho một tài khoản chưa bao
    // giờ được cắm.
    //
    // Cắm xong thì `_reload()` bên ngoài kéo trạng thái mới về, và
    // `_syncStoragePick` tự chỉnh lựa chọn đã nhớ theo kho máy chủ báo. Không
    // cần ai ghi trước cả.
    final ok = await connect();
    if (!mounted || ok) return;
    setState(() => _picked = widget.state.kind);
  }

  /// Có gì để lưu không: đổi sang kho khác, hoặc đang sửa cấu hình S3.
  bool get _dirty => _picked != widget.state.kind || _editingS3;

  /// Form S3 có mở trong thẻ không: đang ngắm S3 mà chưa cắm, hoặc vừa bấm
  /// "Đổi cấu hình" trên kho S3 đang dùng. Đúng điều kiện `showS3Form` bên web.
  /// Đổ cấu hình đang lưu vào form, một lần mỗi lượt mở.
  ///
  /// Chỉ bốn ô không bí mật. Cặp khoá phải dán lại: máy chủ không bao giờ trả
  /// secret, và access key chỉ về bốn ký tự cuối — điền một chuỗi đã bị che vào
  /// ô rồi gửi đi là gửi rác. Chữ mờ trong ô khoá giữ lại phần đuôi đó để khách
  /// nhận ra mình đã dán khoá nào.
  void _prefillS3() {
    final state = widget.state;
    // Điền theo CẤU HÌNH ĐANG GIỮ, không theo kho đang dùng.
    //
    // Hỏi "kho đang dùng có phải S3 không" là bỏ trắng form đúng lúc cần nó
    // nhất: shop đã cắm S3 rồi tạm về Cloud Zenpack thì bấm "Đổi cấu hình" ra
    // một form rỗng, và họ phải đi tìm lại endpoint với tên bucket chỉ để sửa
    // một chữ. Cấu hình đó máy chủ vẫn giữ và vẫn trả về.
    _s3.endpoint.text = state.s3Endpoint;
    _s3.region.text = state.s3Region;
    _s3.bucket.text = state.s3Bucket;
    _s3.prefix.text = state.s3Prefix;
  }

  bool get _s3FormOpen =>
      _picked == EcStorageKind.s3 &&
      // Hỏi "S3 ĐÃ CÓ TÀI KHOẢN CHƯA", không hỏi "kho đang dùng có phải S3
      // không". Shop giữ được tài khoản của cả hai kho, nên đang dùng Drive mà
      // S3 vẫn còn tài khoản là chuyện thường — chạm vào thẻ S3 lúc đó phải là
      // "bật lại", không phải "nhập lại từ đầu".
      (!widget.state.hasAccountFor(EcStorageKind.s3) || _editingS3) &&
      widget.state.canManage &&
      widget.state.byosAllowed &&
      widget.onSaveS3 != null;

  /// Nút Lưu có bấm được không.
  ///
  /// Form S3 mở thì đủ bốn ô bắt buộc mới cho bấm: gửi một cấu hình thiếu
  /// endpoint đi chỉ để nhận về một câu lỗi mà chính app đoán được từ trước.
  bool get _canSave {
    if (!_dirty || widget.busy || !widget.state.canManage) return false;
    if (!_s3FormOpen) return true;
    // Không có nút Kiểm tra thì không có cửa nào để qua — gác lúc đó là khoá
    // nút Lưu vĩnh viễn.
    if (widget.onTestS3 == null) return _s3.readyWithStoredKeys;
    // Đủ sáu ô là CHƯA đủ. Phải có một lượt Kiểm tra xanh trên đúng bộ giá trị
    // đang nằm trên màn.
    //
    // Vì sao bắt buộc: lưu là THAY kho đang giữ bằng chứng. Một cấu hình sai
    // được lưu thì clip quay sau đó không có chỗ nào nhận, mà người bán chỉ
    // biết khi mở đơn ra tìm video. Bắt thử trước biến một hỏng-về-sau thành
    // một câu-lỗi-ngay-bây-giờ, lúc họ còn đang nhìn đúng mấy ô vừa gõ.
    return _s3.readyWithStoredKeys && widget.s3TestPassed && !_editedSinceTest;
  }

  /// Bấm huỷ: trả mọi thứ về đúng trạng thái trước khi người dùng đụng vào.
  ///
  /// Dấu tích quay lại kho đang THẬT SỰ dùng, form đóng và xoá trắng, câu lỗi
  /// của lượt lưu trước biến mất. Không có nút này thì người vừa chạm nhầm thẻ
  /// Drive chỉ còn cách thoát khỏi màn rồi vào lại — mà lúc đó họ chưa biết
  /// thoát ra có mất thứ mình vừa gõ không.
  void _cancel() {
    setState(() {
      _picked = widget.state.kind;
      _editingS3 = false;
      _editedSinceTest = true;
      _s3Prefilled = null;
      _s3.clear();
    });
    widget.onCancel?.call();
  }

  /// Bấm lưu: nhớ lựa chọn rồi chạy đúng luồng của kho vừa chọn.
  ///
  /// `onPick` bắn ở ĐÂY chứ không ở lúc chạm: nó ghi lựa chọn xuống máy, mà ghi
  /// một lựa chọn người dùng chưa xác nhận thì thoát ra vào lại sẽ thấy dấu tích
  /// nằm ở một kho chưa hề được cắm.
  void _save() {
    if (!_dirty) return;
    // S3 cắm mới: giá trị đã nằm sẵn trong form, gửi thẳng đi thay vì đẩy người
    // dùng sang một màn nữa để gõ lại đúng sáu ô vừa gõ.
    if (_s3FormOpen) {
      if (!_s3.readyWithStoredKeys) return;
      widget.onPick?.call(_picked);
      _s3.submit(widget.onSaveS3!);
      return;
    }
    final flow = _flowFor(_picked);
    widget.onPick?.call(_picked);
    flow?.call();
  }

  /// Luồng ứng với một kho, hoặc `null` khi bấm Lưu không có việc gì để làm.
  VoidCallback? _flowFor(EcStorageKind kind) {
    final state = widget.state;
    if (!state.canManage || widget.busy) return null;
    // Chọn lại đúng cái kho ĐÃ CẮM mà đang không dùng: chỉ bật lại, không mở
    // màn cấp quyền nào. Đây là điểm của cả tính năng — tài khoản vẫn nằm trên
    // máy chủ, nên "dùng lại" phải rẻ như bật một công tắc.
    if (kind != EcStorageKind.system && state.hasAccountFor(kind)) {
      // Bật đúng LOẠI vừa chọn. Không truyền loại thì máy chủ bật lại cái vừa
      // dùng gần nhất — với shop đã cắm cả hai, đó có thể là cái người dùng
      // vừa bỏ chọn.
      return () => widget.onResumeStorage?.call(kind);
    }
    return switch (kind) {
      // Về kho hệ thống mà GIỮ tài khoản đã cắm. Không phải `onDisconnect`:
      // Lưu là lưu, không hỏi lại và không cắt đứt tài khoản nào. Muốn cắt đứt
      // thì đã có nút đăng xuất riêng trong thẻ.
      EcStorageKind.system => state.hasAnyAccount ? widget.onUseSystem : null,
      EcStorageKind.s3 => state.byosAllowed ? widget.onConnectS3 : null,
      // Drive chưa cắm bao giờ thì chạm là chạy luôn (xem [_startDrive]), nên
      // tới nút Lưu không còn việc gì — bấm nữa là mở hộp thoại Google lần hai.
      EcStorageKind.gdrive =>
        state.byosAllowed ? () => unawaited(_startDrive()) : null,
    };
  }

  /// Phần chi tiết vẽ BÊN TRONG thẻ của một kho, ngăn bằng một đường kẻ.
  ///
  /// Cùng cách bản web sắp xếp: bảng tình trạng nằm trong ô của chính cái kho
  /// nó nói về, không phải một khối lơ lửng dưới cả danh sách — treo ở ngoài
  /// thì "Cloud Zenpack" trông gọn ghẽ còn Drive/S3 kéo theo một mảng số liệu
  /// không rõ của ai.
  ///
  /// Kho ĐANG dùng → bảng tình trạng. Kho vừa CHỌN mà chưa dùng → nói trước
  /// bấm Lưu sẽ xảy ra chuyện gì. Còn lại → không mở gì.
  ///
  /// Trước đây chỉ kho đang dùng mới có phần này, nên chạm vào Drive hay S3
  /// không thấy gì thêm: muốn biết chọn nó nghĩa là gì thì phải bấm Lưu rồi đi
  /// hết luồng cắm kho mới rõ. Đó là bắt người dùng cam kết trước khi đọc.
  ///
  /// Phần xem trước KHÔNG có nút áp dụng: nút Lưu trên đầu màn vẫn là chỗ duy
  /// nhất đổi kho. Hai chỗ cùng làm một việc thì người dùng học rằng chạm vào
  /// thẻ là xong — đúng thói quen đã bỏ đi.
  Widget? _detailFor(EcStorageKind kind) {
    final state = widget.state;
    final s3FormHere = kind == EcStorageKind.s3 && _s3FormOpen;
    // Cloud Zenpack không mở bảng tình trạng: bốn con số đó đếm video trong
    // kho RIÊNG của shop, và "thôi dùng kho riêng" ở đây không có gì để thôi.
    if (kind != EcStorageKind.system && !s3FormHere) {
      // Kho riêng ĐÃ CẮM luôn mở sẵn bảng của nó, không đợi ai chạm.
      //
      // Trước đây bảng chỉ mở cho kho đang dùng, hoặc cho kho vừa được chạm —
      // nên chủ shop đang ở Cloud Zenpack phải chạm một lần để đọc được tài
      // khoản Drive, rồi chạm thêm lần nữa mới ra nút. Mà "đang cắm tài khoản
      // nào" chính là câu người ta vào màn này để hỏi, nên nó phải trả lời sẵn.
      if (state.kind == kind || state.hasAccountFor(kind)) {
        return _StatusDetail(
          state: state,
          // Bảng này nằm TRONG thẻ của một loại kho, nên nó phải nói bằng chữ
          // của CHÍNH loại đó. Suy từ "kho đang dùng" là sai kể từ khi một shop
          // giữ được tài khoản của cả hai: đang dùng S3 thì thẻ Drive mất hàng
          // email, mất nút đổi tài khoản, và nút "Đăng xuất Drive" đổi thành
          // "Gỡ kho".
          kind: kind,
          busy: widget.busy,
          // Hai nút "đổi tài khoản" và "đăng xuất" của Drive chỉ hiện khi thẻ
          // Drive ĐANG ĐƯỢC CHỌN.
          //
          // Chúng đổi nơi cất bằng chứng của cả cửa hàng, nên khi người dùng
          // vừa chỉ sang Cloud Zenpack thì để chúng nằm đó là mời bấm nhầm vào
          // một kho họ đang định rời khỏi. Tài khoản thì vẫn đọc được — cái ẩn
          // đi chỉ là lối thao tác.
          //
          // Thẻ S3 giữ nguyên: nút của nó là "đổi cấu hình" và "gỡ kho", đi kèm
          // một bảng tình trạng dài — ẩn chúng đi thì thẻ mở ra chỉ toàn số
          // liệu mà không có lối đi tiếp.
          actionsOpen: kind != EcStorageKind.gdrive || _picked == kind,
          onDisconnect: widget.onDisconnect,
          onSwitchDriveAccount: widget.onSwitchDriveAccount,
          onEdit: kind == EcStorageKind.s3
              ? () => setState(() {
                  _picked = EcStorageKind.s3;
                  // Bấm nút này là đang nói "tôi muốn dùng S3 với cấu hình
                  // mới", nên dấu tích phải sang theo. Thiếu dòng này thì với
                  // shop đang ở kho khác, [_s3FormOpen] vẫn false và cái nút
                  // bấm vào không có gì xảy ra — một nút chết nằm giữa màn.
                  _editingS3 = true;
                  _editedSinceTest = true;
                  _prefillS3();
                  _s3Prefilled = _s3.snapshot;
                })
              : null,
        );
      }
    }
    if (state.kind == kind && !s3FormHere) return null;
    // Thẻ Drive nói hết phần của nó NGAY LÚC VÀO MÀN, không đợi ai chạm.
    //
    // Chạm vào Drive là màn Google bật lên ngay, nên nếu phần mô tả chỉ mở khi
    // thẻ được chọn thì nó chớp đúng một nhịp rồi bị che — người dùng chưa kịp
    // đọc đã đứng ở màn nhập tài khoản, không hiểu vì sao. Mở sẵn thì họ đọc
    // trước, rồi chạm khi đã quyết.
    if (kind != EcStorageKind.gdrive && _picked != kind) return null;
    // S3 sổ ra nguyên form, không phải một dòng mô tả: thứ người dùng cần đọc
    // khi chỉ vào S3 chính là những ô họ sắp phải điền.
    if (kind == EcStorageKind.s3 && _s3FormOpen) {
      return _S3Form(
        fields: _s3,
        errorText: widget.s3ErrorText,
        // Lượt thử xanh phải để lại một câu ĐỌC ĐƯỢC ngay cạnh mấy ô vừa gõ:
        // toast trôi mất sau vài giây, mà "bộ khoá này có kết nối được không"
        // là thứ người dùng còn phải nhìn trong lúc quyết định bấm Lưu. Sửa
        // một ký tự là câu này biến mất — nó nói về bộ giá trị ĐÃ THỬ, không
        // nói về bộ đang nằm trên màn.
        okText: widget.s3TestPassed && !_editedSinceTest
            ? context.l10n.storageValidateOk
            : null,
        keyHint: widget.state.s3KeyMasked,
        onChanged: () => setState(() => _editedSinceTest = true),
      );
    }
    final lines = _previewLines(kind);
    // Không có gì để nói thì KHÔNG mở phần này: thẻ vẽ một đường kẻ ngăn cách
    // ngay khi `detail != null`, nên một khối rỗng để lại đúng cái đường kẻ
    // treo lơ lửng dưới đáy thẻ.
    return lines.isEmpty ? null : _PickPreview(lines: lines);
  }

  /// Những câu nói trước cho kho vừa chọn, theo thứ tự đọc.
  ///
  /// Chỉ những thứ đúng mà không cần hỏi máy chủ. Drive chắc chắn không ký được
  /// link tải — đó là tính chất của Drive, không phải kết quả đo. S3 thì tuỳ
  /// nhà cung cấp nên ở đây im lặng: bảng tình trạng sau khi cắm mới nói, dựa
  /// trên thứ máy chủ đo thật.
  ///
  /// Gói chưa mở kho riêng thì không hứa gì: thẻ đã có dòng khoá của nó, và mô
  /// tả một luồng người dùng chưa đi được chỉ làm dòng khoá kia đọc như lời
  /// nói suông.
  List<String> _previewLines(EcStorageKind kind) {
    final l10n = context.l10n;
    final byos = widget.state.byosAllowed;
    return switch (kind) {
      // Chọn Cloud Zenpack trong lúc đang dùng kho riêng = sắp GỠ kho riêng.
      // Đó là câu hộp xác nhận vẫn hỏi — nói trước ở đây để không ai bấm Lưu
      // mà chưa biết video cũ sẽ ra sao.
      EcStorageKind.system => _own ? [l10n.storageSystemSaveNote] : const [],
      // S3 không có dòng mô tả nào: hoặc nguyên form sổ ra (bắt ở [_detailFor]),
      // hoặc người đang xem không cắm được kho — và mô tả một luồng họ đi không
      // tới chỉ là hứa suông.
      EcStorageKind.s3 => const [],
      EcStorageKind.gdrive =>
        byos ? [l10n.storageDriveSaveNote, l10n.storageNoPresign] : const [],
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = widget.state;
    return PenScreen(
      // `scrollable: false` vì màn này tự dựng vùng cuộn: `PenScreen` bọc con
      // trong một `SingleChildScrollView` chiều cao vô hạn, mà `Expanded` bên
      // dưới thì cần một chiều cao có thật.
      scrollable: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        // Tiêu đề nằm NGOÀI vùng cuộn. Nút Lưu và Huỷ sống ở đó, mà form S3 dài
        // hơn một màn hình: gõ tới ô cuối là nội dung bị đẩy lên, hai nút trôi
        // khỏi khung nhìn, và người dùng kết luận màn này không cho lưu. Đo
        // được lúc viết test: nút Lưu nằm ở y = -68 sau khi điền xong form.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PenHeader(
              title: l10n.storageTitle,
              onBack: widget.onBack,
              // Nút lưu chỉ SÁNG khi có thay đổi chưa áp dụng. Một nút luôn
              // sáng ở màn không có gì để lưu thì bấm vào không có chuyện gì
              // xảy ra, và lần sau người dùng không tin nó nữa.
              // Huỷ đứng TRÁI nút Lưu, cùng một chỗ cố định — như bản web.
              // Cả hai mờ đi chứ không biến mất khi không có gì để làm: nút
              // nhảy ra nhảy vào làm tiêu đề co giãn mỗi lần chạm một thẻ.
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CancelButton(
                    enabled: _dirty && !widget.busy,
                    onTap: _cancel,
                  ),
                  const SizedBox(width: 8),
                  // Kiểm tra là CỬA duy nhất dẫn tới nút Lưu, nên nó hiện
                  // suốt lúc form S3 mở — cả cắm lần đầu lẫn đổi cấu hình.
                  //
                  // Nó thử cấu hình mà KHÔNG lưu: dò quyền bên nhà cung cấp
                  // thường mất vài lượt, và mỗi lượt thử không được phép thay
                  // cái kho đang chạy.
                  // Đổi cấu hình mà chưa đổi gì thì không có gì để thử: một
                  // lượt gọi ra kho khách chỉ để xác nhận điều đã biết.
                  if (_s3FormOpen && widget.onTestS3 != null && _s3Changed) ...[
                    _TestButton(
                      enabled: _s3.readyWithStoredKeys && !widget.busy,
                      onTap: () {
                        setState(() {
                          _editedSinceTest = false;
                          _testing = true;
                        });
                        _s3.submit(widget.onTestS3!);
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                  _SaveButton(
                    enabled: _canSave,
                    busy: widget.busy,
                    onTap: _save,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Câu này đứng ngay dưới tiêu đề vì nó trả lời nỗi lo đầu tiên
                    // của người sắp đổi kho: đổi rồi bằng chứng có yếu đi không.
                    PenText(l10n.storageIntro, size: 14, color: PenColors.mut),
                    // Lý do màn này khoá đứng NGAY ĐÂY, trên đầu ba thẻ.
                    //
                    // Trước đây nó nằm dưới đáy danh sách — tức dưới ba thẻ,
                    // tức ngoài khung nhìn trên điện thoại. Người dùng thấy ba
                    // thẻ chạm được, dấu tích nhảy qua nhảy lại, mà nút Lưu
                    // không bao giờ sáng, và không có gì trên màn nói vì sao.
                    // Câu trả lời có sẵn nhưng phải cuộn xuống mới đọc được,
                    // mà không ai cuộn đi tìm một câu mình không biết là có.
                    if (!state.canManage) ...[
                      const SizedBox(height: 12),
                      _NoteBox(text: l10n.storageOwnerOnly),
                    ] else if (!state.byosAllowed) ...[
                      const SizedBox(height: 12),
                      _NoteBox(text: l10n.storageNotInPlan),
                    ],
                    const SizedBox(height: 16),
                    _StorageOption(
                      icon: LucideIcons.cloud,
                      title: l10n.storageSystemName,
                      description: l10n.storageSystemDesc,
                      selected: _picked == EcStorageKind.system,
                      inUse: state.kind == EcStorageKind.system,
                      detail: _detailFor(EcStorageKind.system),
                      onTap: _canPick(EcStorageKind.system)
                          ? () => _pick(EcStorageKind.system)
                          : null,
                    ),
                    const SizedBox(height: 10),
                    _StorageOption(
                      icon: LucideIcons.hardDrive,
                      title: l10n.storageS3Title,
                      description: l10n.storageS3Desc,
                      selected: _picked == EcStorageKind.s3,
                      inUse: state.kind == EcStorageKind.s3,
                      label: state.kind == EcStorageKind.s3
                          ? state.label
                          : null,
                      lockNote: state.byosAllowed
                          ? null
                          : l10n.storageNeedProPlan,
                      detail: _detailFor(EcStorageKind.s3),
                      onTap: _canPick(EcStorageKind.s3)
                          ? () => _pick(EcStorageKind.s3)
                          : null,
                    ),
                    const SizedBox(height: 10),
                    _StorageOption(
                      // Logo Drive thật, không dùng chung ổ cứng với thẻ S3
                      // ngay trên: hai thẻ cùng một hình thì mắt phải đọc chữ
                      // mới phân biệt được, mà chữ là thứ người ta lướt qua.
                      iconBuilder: (ink) => FaIcon(
                        FontAwesomeIcons.googleDrive,
                        size: 20,
                        color: ink,
                      ),
                      title: l10n.storageDriveTitle,
                      // Không có dòng mô tả: thẻ này mở ra là tài khoản đang
                      // cắm, và đó mới là thứ người ta vào đây để đọc.
                      description: null,
                      selected: _picked == EcStorageKind.gdrive,
                      inUse: state.kind == EcStorageKind.gdrive,
                      label: state.kind == EcStorageKind.gdrive
                          ? state.label
                          : null,
                      lockNote: state.byosAllowed
                          ? null
                          : l10n.storageNeedProPlan,
                      detail: _detailFor(EcStorageKind.gdrive),
                      onTap: _canPick(EcStorageKind.gdrive)
                          ? () => _pick(EcStorageKind.gdrive)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Một dòng chọn kho: biểu tượng, tên, mô tả, và dấu tích khi đang dùng.
///
/// Kho đang dùng viền xanh + dấu tích; kho gói chưa mở thì chữ mờ đi và có
/// thêm một dòng nói RÕ vì sao không bấm được — ẩn đi thì người dùng đọc tài
/// liệu thấy có tính năng rồi đi tìm mãi không ra.
class _StorageOption extends StatelessWidget {
  const _StorageOption({
    required this.title,
    required this.description,
    required this.selected,
    this.inUse = false,
    this.label,
    this.lockNote,
    this.detail,
    this.onTap,
    this.icon,
    this.iconBuilder,
  }) : assert(
         icon != null || iconBuilder != null,
         'thẻ kho phải có một hình để nhận ra nó',
       );

  final IconData? icon;

  /// Hình vẽ tay khi bộ icon chung không có cái cần dùng — logo Google Drive
  /// nằm ở bộ thương hiệu của Font Awesome, và bộ đó dùng widget riêng
  /// (`FaIcon`) chứ không cắm được vào `Icon`.
  ///
  /// Nhận màu chữ của thẻ để hình mờ đi cùng lúc với chữ khi thẻ bị khoá.
  final Widget Function(Color ink)? iconBuilder;
  final String title;

  /// Dòng mô tả dưới tên kho. `null` = thẻ chỉ có tên, và phần mở ra bên dưới
  /// tự nói hết phần còn lại.
  final String? description;

  /// Kho người dùng vừa CHỌN. Khác [inUse] — và phải nhìn ra được cả hai, vì
  /// gộp lại thì chọn xong người ta tưởng đã đổi kho rồi.
  final bool selected;

  /// Kho máy chủ đang THẬT SỰ dùng.
  final bool inUse;

  /// Dòng nhận diện kho (`bucket/prefix` hoặc thư mục Drive), chỉ ở thẻ [inUse].
  final String? label;
  final String? lockNote;

  /// Bảng tình trạng hoặc lối cắm, vẽ trong cùng khung viền với thẻ.
  final Widget? detail;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final locked = lockNote != null;
    final ink = locked && !selected ? PenColors.mut : PenColors.ink;
    // Chạm không ăn thì phải NHÌN RA được là không ăn. Một thẻ trông y hệt ba
    // thẻ kia mà chạm vào không có gì xảy ra đọc thành "app đơ", không đọc
    // thành "gói của tôi chưa có cái này".
    final disabled = onTap == null;
    return EcTap(
      onTap: onTap,
      child: PenBox(
        width: double.infinity,
        fill: disabled ? PenColors.bg : PenColors.card,
        stroke: selected ? PenColors.success : PenColors.line,
        strokeWidth: selected ? 2 : 1,
        radius: 14,
        axis: PenAxis.row,
        gap: 12,
        cross: CrossAxisAlignment.start,
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: iconBuilder?.call(ink) ?? Icon(icon, size: 20, color: ink),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: PenText(
                        title,
                        size: 16,
                        color: ink,
                        weight: FontWeight.w700,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (selected) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        LucideIcons.check,
                        size: 18,
                        color: PenColors.success,
                      ),
                    ],
                    // Nhãn này KHÁC dấu tích: dấu tích là "đang ngắm", nhãn là
                    // "máy chủ đang thật sự cất video ở đây". Thiếu nó thì chọn
                    // xong người dùng tưởng đã đổi kho rồi.
                    if (inUse) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: PenColors.soft,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: PenText(
                          context.l10n.storageInUse,
                          size: 11,
                          color: PenColors.mut,
                        ),
                      ),
                    ],
                  ],
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  PenText(
                    description!,
                    size: 13,
                    color: PenColors.mut,
                    lineHeight: 1.4,
                  ),
                ],
                if (label?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 4),
                  PenText(
                    label!,
                    size: 13,
                    color: PenColors.ink,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (locked) ...[
                  const SizedBox(height: 4),
                  PenText(
                    lockNote!,
                    size: 13,
                    color: PenColors.ink,
                    weight: FontWeight.w600,
                    lineHeight: 1.4,
                  ),
                ],
                if (detail != null) ...[
                  const SizedBox(height: 12),
                  Container(height: 1, color: PenColors.line),
                  detail!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Sáu ô của form S3, gom lại một chỗ.
///
/// Tách khỏi widget vì hai nơi cùng cần: form trong thẻ ở màn Kho lưu trữ, và
/// màn sửa cấu hình của kho đang dùng. Bản sao thứ hai của sáu ô này là chỗ hai
/// đường sẽ lệch nhau — một bên `trim()`, một bên không.
class _S3Controllers {
  final endpoint = TextEditingController();
  final bucket = TextEditingController();
  final keyId = TextEditingController();
  final secret = TextEditingController();
  // Để TRỐNG kèm placeholder, không điền sẵn — giống bản web. Điền sẵn thì
  // `auto`/`evidencecam` trông như thứ người dùng đã tự chọn, và họ xoá đi rồi
  // ngồi nghĩ xem phải điền gì. Giá trị mặc định áp ở [submit].
  final region = TextEditingController();
  final prefix = TextEditingController();

  /// Bốn ô bắt buộc đã có chữ. Region và prefix đều có mặc định dùng được.
  bool get ready =>
      endpoint.text.trim().isNotEmpty &&
      bucket.text.trim().isNotEmpty &&
      keyId.text.trim().isNotEmpty &&
      secret.text.trim().isNotEmpty;

  /// Đủ để GỬI ĐI khi kho này đã có khoá lưu trên máy chủ.
  ///
  /// Khoá bí mật không bao giờ rời máy chủ, nên form "đổi cấu hình" mở ra với
  /// hai ô khoá trống. Đòi gõ lại là bắt người bán đi tìm lại cặp khoá trong
  /// bảng điều khiển của nhà cung cấp chỉ để sửa một chữ trong tên bucket —
  /// máy chủ tự dùng lại khoá cũ khi hai ô này trống.
  ///
  /// Gõ MỘT trong hai thì phải gõ nốt: nửa cặp khoá không mở được kho nào.
  bool get readyWithStoredKeys {
    if (endpoint.text.trim().isEmpty || bucket.text.trim().isEmpty) {
      return false;
    }
    final hasId = keyId.text.trim().isNotEmpty;
    final hasSecret = secret.text.trim().isNotEmpty;
    return hasId == hasSecret;
  }

  /// Ảnh chụp sáu ô, để so xem người dùng đã đổi gì chưa.
  List<String> get snapshot => [
    endpoint.text,
    region.text,
    bucket.text,
    prefix.text,
    keyId.text,
    secret.text,
  ];

  /// Gọi [sink] với giá trị đã chuẩn hoá. Region để trống quay về `auto` —
  /// nhiều nhà cung cấp không có khái niệm region và bỏ trống là hợp lệ, nhưng
  /// SDK phía máy chủ vẫn cần một chuỗi.
  void submit(
    void Function({
      required String endpoint,
      required String bucket,
      required String accessKeyId,
      required String secretAccessKey,
      required String region,
      required String prefix,
    })
    sink,
  ) {
    final trimmedRegion = region.text.trim();
    // Ghi NGƯỢC lại vào ô: thứ gửi đi phải đúng bằng thứ đang hiện trên màn.
    // Chuẩn hoá ngầm rồi để ô giữ nguyên chữ cũ là lúc máy chủ từ chối, người
    // dùng soi lại ô và không hiểu vì sao cái mình đang nhìn lại sai.
    final cleanEndpoint = normalizeS3Endpoint(endpoint.text);
    if (cleanEndpoint != endpoint.text) endpoint.text = cleanEndpoint;
    sink(
      endpoint: cleanEndpoint,
      bucket: bucket.text.trim(),
      accessKeyId: keyId.text.trim(),
      secretAccessKey: secret.text.trim(),
      region: trimmedRegion.isEmpty ? 'auto' : trimmedRegion,
      prefix: prefix.text.trim(),
    );
  }

  /// Trả sáu ô về trống. Bấm Huỷ mà giữ lại khoá vừa gõ thì lần sau mở form ra
  /// thấy sẵn secret của một lượt đã bỏ.
  void clear() {
    for (final c in [endpoint, bucket, keyId, secret, region, prefix]) {
      c.clear();
    }
  }

  void dispose() {
    for (final c in [endpoint, bucket, keyId, secret, region, prefix]) {
      c.dispose();
    }
  }
}

/// Sáu ô S3 xếp dọc, kèm câu chỉ dẫn quyền và câu lỗi từ máy chủ.
///
/// Không có nút gửi: nơi dùng nó tự quyết định nút nằm ở đâu — trong thẻ thì nút
/// Lưu ở đầu màn, ở màn riêng thì nút nằm cuối form.
/// Dọn ô Endpoint về đúng dạng máy chủ đòi: một URL đầy đủ, không đuôi `/`.
///
/// Gõ thiếu `https://` là cái sai phổ biến nhất ở form này — người ta chép tên
/// miền từ bảng điều khiển của nhà cung cấp, mà bảng đó hiện tên miền trần. Máy
/// chủ từ chối ngay ở khâu kiểm dữ liệu (`invalid_request`), chưa hề chạm tới
/// kho, nên câu lỗi không nói được gì về kho cả.
///
/// KHÔNG tự nâng `http://` thành `https://`. Người gõ `http` là đang nói một
/// điều cụ thể, và máy chủ có sẵn câu giải thích vì sao không nhận — sửa lén ý
/// định của họ thì lần sau họ vẫn không biết luật đó tồn tại.
String normalizeS3Endpoint(String raw) {
  var text = raw.trim();
  if (text.isEmpty) return text;
  while (text.endsWith('/')) {
    text = text.substring(0, text.length - 1);
  }
  if (!text.contains('://')) text = 'https://$text';
  return text;
}

class _S3Form extends StatelessWidget {
  const _S3Form({
    required this.fields,
    required this.onChanged,
    this.errorText,
    this.okText,
    this.keyHint = '',
  });

  final _S3Controllers fields;

  /// Gõ một ký tự là bên ngoài phải tính lại: nút gửi bật/tắt theo bốn ô bắt
  /// buộc, và nó không nằm trong widget này.
  final VoidCallback onChanged;

  /// Câu `hint` nguyên văn từ máy chủ: thiếu quyền gì, sửa thế nào.
  final String? errorText;

  /// Câu báo lượt thử ĐÃ XANH, cho đúng bộ giá trị đang hiện trên màn.
  final String? okText;

  /// Đuôi access key đang lưu (`…abcd`), làm chữ mờ cho ô khoá.
  final String keyHint;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Thứ tự sáu ô bám theo bản web: endpoint trước, rồi region/bucket,
          // rồi prefix, cuối cùng mới tới cặp khoá. Hai bản lệch thứ tự thì
          // người vừa cắm kho trên web xuống app phải dò lại từ đầu.
          _Field(
            label: l10n.storageFieldEndpoint,
            controller: fields.endpoint,
            placeholder: 'https://s3.ap-southeast-1.amazonaws.com',
            keyboardType: TextInputType.url,
            // Ô này là chỗ sai nhiều nhất: gõ thiếu `https://` thì máy chủ từ
            // chối ngay ở khâu kiểm dữ liệu, chưa hề chạm tới kho — và chữ mờ
            // gợi ý thì biến mất ngay khi người ta bắt đầu gõ.
            hint: l10n.storageFieldEndpointHint,
            onChanged: onChanged,
          ),
          _Field(
            label: l10n.storageFieldRegion,
            controller: fields.region,
            placeholder: 'auto',
            onChanged: onChanged,
          ),
          _Field(
            label: l10n.storageFieldBucket,
            controller: fields.bucket,
            placeholder: 'shop-evidence',
            onChanged: onChanged,
          ),
          _Field(
            label: l10n.storageFieldPrefix,
            controller: fields.prefix,
            placeholder: 'evidencecam',
            hint: l10n.storageFieldPrefixHint,
            onChanged: onChanged,
          ),
          _Field(
            label: l10n.storageFieldAccessKey,
            controller: fields.keyId,
            // Đuôi khoá đang lưu làm chữ mờ: khách nhận ra mình đã dán khoá
            // nào mà không có gì bí mật lọt ra.
            placeholder: keyHint.isEmpty ? 'AKIA…' : keyHint,
            onChanged: onChanged,
          ),
          _Field(
            label: l10n.storageFieldSecretKey,
            controller: fields.secret,
            placeholder: '••••••••',
            obscure: true,
            onChanged: onChanged,
          ),
          if (errorText?.isNotEmpty ?? false) ...[
            const SizedBox(height: 8),
            _NoteBox(text: errorText!, danger: true),
          ] else if (okText?.isNotEmpty ?? false) ...[
            const SizedBox(height: 8),
            _NoteBox(text: okText!),
          ],
        ],
      ),
    );
  }
}

/// Xem trước kho vừa CHỌN nhưng chưa lưu: bấm Lưu sẽ xảy ra chuyện gì.
///
/// Thuần chữ, không nút. Nút Lưu trên đầu màn vẫn là chỗ duy nhất đổi kho.
class _PickPreview extends StatelessWidget {
  const _PickPreview({required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (index, line) in lines.indexed) ...[
            if (index > 0) const SizedBox(height: 6),
            PenText(line, size: 12, color: PenColors.mut, lineHeight: 1.4),
          ],
        ],
      ),
    );
  }
}

/// Bảng tình trạng của kho ĐANG dùng: lỗi, cam kết không giữ được, năm con số,
/// mốc rà gần nhất, rồi tới các nút thao tác.
class _StatusDetail extends StatelessWidget {
  const _StatusDetail({
    required this.state,
    required this.kind,
    required this.busy,
    this.actionsOpen = true,
    this.onDisconnect,
    this.onEdit,
    this.onSwitchDriveAccount,
  });

  final EcStorageState state;
  final bool busy;

  /// Đã lộ phần thao tác (đổi tài khoản, đăng xuất) chưa. `false` = bảng này
  /// chỉ để đọc.
  final bool actionsOpen;

  /// Gỡ tài khoản của [kind] — loại kho của chính thẻ này, không phải loại
  /// đang được dùng.
  final ValueChanged<EcStorageKind>? onDisconnect;

  /// Đổi sang tài khoản Google khác. Chỉ Drive; `null` = không hiện nút.
  final VoidCallback? onSwitchDriveAccount;

  /// Sửa cấu hình — chỉ S3. Drive không có gì để sửa ngoài cắm lại.
  final VoidCallback? onEdit;

  /// Loại kho của THẺ chứa bảng này — không phải loại kho đang được dùng.
  final EcStorageKind kind;

  /// `dd/MM/yyyy HH:mm` theo giờ máy. Tự dựng thay vì kéo `intl` vào package
  /// này: đúng một chuỗi cần định dạng, và nó không đổi theo ngôn ngữ.
  static String _at(int ms) {
    final t = DateTime.fromMillisecondsSinceEpoch(ms);
    String p(int n) => n.toString().padLeft(2, '0');
    return '${p(t.day)}/${p(t.month)}/${t.year} ${p(t.hour)}:${p(t.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final health = state.health;
    final isDrive = kind == EcStorageKind.gdrive;
    final email = state.driveEmail ?? '';
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Thẻ Drive chỉ giữ phần TÀI KHOẢN đổ xuống.
          //
          // Bảng tình trạng, hai câu cảnh báo về cam kết và mốc rà gần nhất
          // đều nói về kho nói chung; với Drive thì thứ người ta mở thẻ ra để
          // đọc chỉ có một: đang cắm bằng tài khoản nào. Mọi dòng khác đứng
          // trên nó chỉ đẩy câu trả lời xuống dưới màn hình.
          if (!isDrive) ...[
            // Câu lỗi nguyên văn của nhà cung cấp là thứ DUY NHẤT giúp chủ shop
            // tự sửa quyền bên phía họ. Không bao giờ thay bằng câu chung.
            if (!state.ok && (state.lastError?.isNotEmpty ?? false)) ...[
              _NoteBox(text: state.lastError!, danger: true),
              const SizedBox(height: 10),
            ],
            // Cam kết nào hứa được là do máy chủ ĐO, không do tên nhà cung cấp.
            if (!state.presignedDownload)
              PenText(
                l10n.storageNoPresign,
                size: 12,
                color: PenColors.mut,
                lineHeight: 1.4,
              ),
            if (!state.objectLock) ...[
              const SizedBox(height: 6),
              PenText(
                l10n.storageNoObjectLock,
                size: 12,
                color: PenColors.mut,
                lineHeight: 1.4,
              ),
            ],
            const SizedBox(height: 10),
            PenText(
              l10n.storageHealthTitle,
              size: 13,
              color: PenColors.mut,
              weight: FontWeight.w600,
            ),
            const SizedBox(height: 6),
            _HealthRow(label: l10n.storageHealthTotal, value: health.total),
            _HealthRow(label: l10n.storageHealthIntact, value: health.intact),
            // Ba dòng sự cố chỉ hiện khi KHÁC 0 — khác bản web, cố ý. Bảng lúc
            // nào cũng có "0 lỗi" thì mắt lướt qua rất nhanh, và đúng hôm có lỗi
            // thật cũng không ai thấy. Màn hình điện thoại lại càng ít chỗ.
            if (health.unreachable > 0)
              _HealthRow(
                label: l10n.storageHealthUnreachable,
                value: health.unreachable,
                danger: true,
              ),
            if (health.mismatched > 0)
              _HealthRow(
                label: l10n.storageHealthMismatched,
                value: health.mismatched,
                danger: true,
              ),
            if (health.pendingRelay > 0)
              _HealthRow(
                label: l10n.storageHealthPendingRelay,
                value: health.pendingRelay,
              ),
            if (health.hasProblems) ...[
              const SizedBox(height: 8),
              _NoteBox(text: l10n.storageProblemsNote, danger: true),
            ],
            const SizedBox(height: 8),
            PenText(
              health.lastCheckedAt == null
                  ? l10n.storageNeverChecked
                  : l10n.storageLastCheckAt(_at(health.lastCheckedAt!)),
              size: 12,
              color: PenColors.mut,
            ),
          ],
          // Thẻ Drive LUÔN nói ra hàng tài khoản, kể cả khi chưa đọc được
          // email — nó là dòng duy nhất thẻ này có. Và CHỈ thẻ Drive: hỏi theo
          // `driveEmail` có rỗng hay không là gắn hàng "Tài khoản Drive" vào cả
          // thẻ S3, vì một shop giữ được tài khoản của cả hai kho cùng lúc.
          //
          // Bảng tình trạng chỉ vẽ cho kho khác Drive, và hai nút thao tác chỉ
          // vẽ khi thẻ đang được chọn. Treo hàng email vào một chuỗi rỗng nữa
          // thì cả ba điều kiện cùng sai là chuyện thường ngày — đang dùng S3,
          // tài khoản Drive nằm chờ, chưa ai chạm vào thẻ — và `Column` này
          // rỗng. Thẻ thì đã kẻ đường ngăn từ lúc thấy `detail != null`, nên
          // người dùng nhận đúng chữ "Google Drive" trên một đường kẻ treo lơ
          // lửng, không một lời giải thích.
          if (isDrive) ...[
            const SizedBox(height: 8),
            PenText(l10n.storageDriveAccount, size: 12, color: PenColors.mut),
            const SizedBox(height: 2),
            // Nút đổi tài khoản nằm NGAY CẠNH email, không nằm dưới cùng cùng
            // đám nút kia: thứ người ta muốn đổi là đúng cái địa chỉ đang đọc,
            // và đặt nút cạnh nó thì không phải dò xem nút nào tác động lên gì.
            Row(
              children: [
                Expanded(
                  child: PenText(
                    // Chưa đọc được thì NÓI là chưa đọc được. Bỏ trống hàng
                    // này đọc ra thành "chưa cắm tài khoản nào", mà đó là câu
                    // sai: kho vẫn đang nhận video bằng một tài khoản có thật.
                    email.isEmpty ? l10n.storageDriveAccountUnknown : email,
                    size: 13,
                    color: email.isEmpty ? PenColors.mut : PenColors.ink,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (actionsOpen &&
                    state.canManage &&
                    onSwitchDriveAccount != null) ...[
                  const SizedBox(width: 8),
                  EcTap(
                    onTap: busy ? null : onSwitchDriveAccount,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        LucideIcons.repeat,
                        size: 18,
                        color: busy ? PenColors.mut : PenColors.link,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
          if (actionsOpen && state.canManage) ...[
            const SizedBox(height: 12),
            if (onEdit != null) ...[
              PenOutlineButton(
                label: l10n.storageEditCta,
                onPressed: busy ? null : onEdit,
              ),
              const SizedBox(height: 8),
            ],
            // ĐÚNG MỘT nút gỡ kho, và nó nói bằng chữ của loại kho đang cắm.
            //
            // Bản trước có hai nút cạnh nhau — "đăng xuất" và "thôi dùng kho
            // riêng". Hai chữ khác nhau cho hai việc mà người dùng đọc ra là
            // gần như một, nên chỉ tổ bắt họ dừng lại đoán xem nút nào làm gì.
            //
            // Muốn về kho hệ thống thì chọn thẳng thẻ Cloud Zenpack rồi bấm
            // Lưu — đó mới là chỗ tự nhiên để ĐỔI kho, chứ không phải một cái
            // nút nằm lẫn trong bảng tình trạng của kho hiện tại.
            PenOutlineButton(
              // Theo kho ĐÃ CẮM, không theo kho đang dùng: bảng này giờ mở
              // được cả khi tài khoản Drive đang nằm chờ, và lúc đó `kind` là
              // `system` — nút sẽ hiện "Thôi dùng kho riêng" cho một thao tác
              // thật ra là gỡ tài khoản Google.
              label: isDrive ? l10n.storageDriveLogout : l10n.storageDisconnect,
              onPressed: busy ? null : () => onDisconnect?.call(kind),
            ),
          ],
        ],
      ),
    );
  }
}

class _HealthRow extends StatelessWidget {
  const _HealthRow({
    required this.label,
    required this.value,
    this.danger = false,
  });

  final String label;
  final int value;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: PenText(
              label,
              size: 13,
              color: danger ? PenColors.warning : PenColors.mut,
            ),
          ),
          const SizedBox(width: 8),
          PenText(
            '$value',
            size: 13,
            weight: FontWeight.w700,
            color: danger ? PenColors.warning : PenColors.ink,
          ),
        ],
      ),
    );
  }
}

class _NoteBox extends StatelessWidget {
  const _NoteBox({required this.text, this.danger = false});

  final String text;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return PenBox(
      width: double.infinity,
      axis: PenAxis.column,
      radius: 10,
      fill: danger ? BrandColors.warningTint : PenColors.soft,
      padding: const EdgeInsets.all(12),
      cross: CrossAxisAlignment.start,
      children: [
        PenText(
          text,
          size: 13,
          color: danger ? PenColors.ink : PenColors.mut,
        ),
      ],
    );
  }
}

/// Form cắm kho S3. Google Drive không đi đường này — nó qua OAuth.
///
/// Năm ô, và không ô nào bỏ được: thiếu một là vòng kiểm tra của máy chủ đỏ ở
/// bước đầu tiên. Khoá bí mật nhập một lần rồi không bao giờ đọc lại được —
/// máy chủ mã hoá và không trả về, nên màn này luôn nhập mới chứ không sửa.
class EcStorageConnectScreen extends StatefulWidget {
  const EcStorageConnectScreen({
    required this.onSubmit,
    this.onBack,
    this.busy = false,
    this.errorText,
    super.key,
  });

  /// Trả về khi máy chủ đã chạy xong vòng kiểm tra. Bên gọi hiện lỗi qua
  /// [errorText] và tự đóng màn khi thành công.
  final void Function({
    required String endpoint,
    required String bucket,
    required String accessKeyId,
    required String secretAccessKey,
    required String region,
    required String prefix,
  })
  onSubmit;
  final VoidCallback? onBack;
  final bool busy;

  /// Câu `hint` nguyên văn từ máy chủ: thiếu quyền gì, sửa thế nào.
  final String? errorText;

  @override
  State<EcStorageConnectScreen> createState() => _EcStorageConnectScreenState();
}

class _EcStorageConnectScreenState extends State<EcStorageConnectScreen> {
  final _fields = _S3Controllers();

  @override
  void dispose() {
    _fields.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PenScreen(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PenHeader(title: l10n.storageConnectS3, onBack: widget.onBack),
              _S3Form(
                fields: _fields,
                errorText: widget.errorText,
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: 16),
              PenPrimaryButton(
                label: l10n.storageConnectSubmit,
                onPressed: widget.busy || !_fields.ready
                    ? null
                    : () => _fields.submit(widget.onSubmit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatefulWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.placeholder,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String? placeholder;
  final String? hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final VoidCallback? onChanged;

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  /// Ô khoá đang che hay đang hiện. Chỉ đổi thứ MẮT nhìn thấy — thứ gửi đi vẫn
  /// là nguyên chuỗi trong controller.
  ///
  /// Khoá bí mật dài mấy chục ký tự và luôn được dán từ bảng điều khiển của nhà
  /// cung cấp. Dán hụt một ký tự thì máy chủ trả về `SignatureDoesNotMatch` —
  /// câu đó không chỉ ra ô nào sai, và một hàng chấm tròn thì không soi lại
  /// được. Con mắt là đường DUY NHẤT để tự kiểm tra thứ mình vừa dán.
  late bool _obscure = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PenText(
            widget.label,
            size: 13,
            color: PenColors.mut,
            weight: FontWeight.w600,
          ),
          const SizedBox(height: 6),
          CupertinoTextField(
            controller: widget.controller,
            placeholder: widget.placeholder,
            obscureText: _obscure,
            keyboardType: widget.keyboardType,
            // Endpoint và khoá phân biệt hoa thường; bàn phím tự viết hoa chữ
            // đầu là hỏng ngay ô đầu tiên và lỗi trả về không nói được vì sao.
            autocorrect: false,
            enableSuggestions: false,
            textCapitalization: TextCapitalization.none,
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: PenColors.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: PenColors.soft),
            ),
            onChanged: (_) => widget.onChanged?.call(),
            suffix: widget.obscure
                ? Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: EcTap(
                      onTap: () => setState(() => _obscure = !_obscure),
                      child: Icon(
                        _obscure ? LucideIcons.eye : LucideIcons.eyeOff,
                        size: 18,
                        color: PenColors.mut,
                      ),
                    ),
                  )
                : null,
          ),
          if (widget.hint != null) ...[
            const SizedBox(height: 4),
            PenText(widget.hint!, size: 12, color: PenColors.mut),
          ],
        ],
      ),
    );
  }
}

/// Nút kiểm tra cấu hình S3, đứng giữa Huỷ và Lưu.
///
/// Cùng hình đĩa với hai nút kia; viền như nút Huỷ vì đây cũng không phải việc
/// chính — nó chỉ trả lời "cấu hình này chạy được chưa" mà không đổi gì.
class _TestButton extends StatelessWidget {
  const _TestButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: context.l10n.storageTestOnlyCta,
      child: EcTap(
        onTap: enabled ? onTap : null,
        child: PenBox(
          width: 40,
          height: 40,
          fill: PenColors.bg,
          stroke: enabled ? PenColors.line : PenColors.soft,
          radius: 999,
          axis: PenAxis.row,
          main: MainAxisAlignment.center,
          cross: CrossAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.flaskConical,
              size: 20,
              color: enabled ? PenColors.ink : PenColors.soft,
            ),
          ],
        ),
      ),
    );
  }
}

/// Nút huỷ, đứng cạnh nút lưu.
///
/// Cùng hình đĩa 40×40 với nút lưu để hai nút đọc như một cặp; viền chứ không
/// tô đặc, vì đây là đường lùi chứ không phải việc chính.
class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: context.l10n.commonCancel,
      child: EcTap(
        onTap: enabled ? onTap : null,
        child: PenBox(
          width: 40,
          height: 40,
          fill: PenColors.bg,
          stroke: enabled ? PenColors.line : PenColors.soft,
          radius: 999,
          axis: PenAxis.row,
          main: MainAxisAlignment.center,
          cross: CrossAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.x,
              size: 20,
              color: enabled ? PenColors.ink : PenColors.soft,
            ),
          ],
        ),
      ),
    );
  }
}

/// Nút lưu ở góc phải đầu màn Kho lưu trữ.
///
/// Dạng đĩa tròn như nút cộng ở màn Hồ sơ khiếu nại, để hai màn cùng một ngôn
/// ngữ. Mờ đi khi không có gì để lưu — vẫn chiếm chỗ chứ không biến mất, vì một
/// nút nhảy ra nhảy vào làm tiêu đề co giãn mỗi lần người dùng chạm một thẻ.
class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.enabled,
    required this.busy,
    required this.onTap,
  });

  final bool enabled;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final on = enabled && !busy;
    return Semantics(
      button: true,
      enabled: on,
      label: context.l10n.storageSave,
      child: EcTap(
        onTap: on ? onTap : null,
        child: PenBox(
          width: 40,
          height: 40,
          fill: on ? PenColors.primary : PenColors.bg,
          stroke: on ? null : PenColors.line,
          radius: 999,
          axis: PenAxis.row,
          main: MainAxisAlignment.center,
          cross: CrossAxisAlignment.center,
          children: [
            if (busy)
              const SizedBox(
                width: 18,
                height: 18,
                child: CupertinoActivityIndicator(),
              )
            else
              Icon(
                LucideIcons.save,
                size: 20,
                color: on ? PenColors.card : PenColors.soft,
              ),
          ],
        ),
      ),
    );
  }
}
