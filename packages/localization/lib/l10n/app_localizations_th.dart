// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get bundleBackendPending =>
      'กำลังรอ endpoint ฝั่งเซิร์ฟเวอร์สำหรับส่วนนี้';

  @override
  String get bundleCreate => 'สร้าง';

  @override
  String get bundleCreateClaim => 'สร้างแฟ้มเคลม';

  @override
  String get accountClaims => 'แฟ้มเคลม';

  @override
  String get claimsTitle => 'แฟ้มเคลม';

  @override
  String get claimsLocalOnlyNote =>
      'บางแฟ้มยังอัปโหลดไม่สำเร็จ จึงมีอยู่เฉพาะในเครื่องนี้';

  @override
  String get claimsOfflineNote =>
      'เชื่อมต่อเซิร์ฟเวอร์ไม่ได้ นี่คือสำเนาในเครื่อง เปิดใหม่เมื่อมีเน็ตเพื่อดูทั้งหมด';

  @override
  String get claimsEmpty =>
      'ยังไม่มีแฟ้ม เปิดแท็บออเดอร์ แตะปุ่มบวก แล้วเลือกหลักฐานเพื่อสร้าง';

  @override
  String claimsSummary(int orders, int evidence) {
    return '$orders ออเดอร์ · $evidence หลักฐาน';
  }

  @override
  String claimsEvidenceOnly(int evidence) {
    return '$evidence รายการ';
  }

  @override
  String get claimsCopied => 'คัดลอกเนื้อหาแฟ้มแล้ว';

  @override
  String get claimsCreated => 'สร้างแฟ้มเคลมแล้ว';

  @override
  String get claimsPickNothing => 'ยังไม่ได้เลือกหลักฐาน';

  @override
  String get claimsDelete => 'ลบแฟ้ม';

  @override
  String get claimsDeleteConfirm => 'ลบแฟ้มนี้ไหม หลักฐานในออเดอร์ยังอยู่ครบ';

  @override
  String get claimsDeleteConfirmLink =>
      'ลบแฟ้มนี้ไหม ลิงก์สาธารณะจะตายทันที — ใครที่คุณส่งไปแล้วจะเปิดเจอหน้าว่าง หลักฐานในออเดอร์ยังอยู่ครบ';

  @override
  String get claimsRevokeFailed =>
      'เพิกถอนลิงก์ไม่สำเร็จ แฟ้มจึงคงไว้ตามเดิม ลิงก์ยังเปิดอยู่ — ลองใหม่เมื่อสัญญาณดีขึ้น หรือให้เจ้าของร้านเพิกถอนให้';

  @override
  String get claimsDeleted => 'ลบแฟ้มแล้ว';

  @override
  String get claimsPhotoAdded => 'เพิ่มรูปเข้าแฟ้มและเข้าคิวไปที่ออเดอร์แล้ว';

  @override
  String get claimsAddedLater => 'เพิ่มภายหลัง';

  @override
  String get claimsCreateTitle => 'แฟ้มเคลมใหม่';

  @override
  String get claimsCreateSearchHint => 'พิมพ์หรือสแกนเลขพัสดุ';

  @override
  String get claimsCreateNameHint => 'เช่น เคลมพัสดุตีกลับ 12/08';

  @override
  String get claimsCreateNameLabel => 'ชื่อแฟ้มเรื่อง';

  @override
  String get claimInfoTitle => 'รายละเอียดแฟ้มเรื่อง';

  @override
  String get claimTrackingLabel => 'รหัสพัสดุ';

  @override
  String get claimShopLabel => 'ร้านค้า';

  @override
  String get claimChannelLabel => 'ช่องทางขาย';

  @override
  String get claimOrderCreatedAt => 'วันที่สั่งซื้อ';

  @override
  String get claimEvidenceLabel => 'หลักฐาน';

  @override
  String claimEvidenceCount(int videos, int photos) {
    return '$videos วิดีโอ · $photos รูป';
  }

  @override
  String get claimCreatedAtLabel => 'วันที่สร้างแฟ้ม';

  @override
  String get claimCopyLink => 'Copy link';

  @override
  String get claimsRevokeNoLink =>
      'This dossier is not on the server yet, so there is no link to revoke.';

  @override
  String get claimPageFailed =>
      'Could not open the dossier page. Check your connection and try again.';

  @override
  String get claimLinkLabel => 'ลิงก์แฟ้มเรื่อง';

  @override
  String get claimLinkHint =>
      'ใครก็ตามที่มีลิงก์สามารถดูได้โดยไม่ต้องเข้าสู่ระบบ ลิงก์จะใช้ได้จนกว่าคุณจะเพิกถอน';

  @override
  String get claimRevokedBadge => 'เพิกถอนแล้ว';

  @override
  String get claimRevokedHint =>
      'ลิงก์ใช้ไม่ได้แล้ว ข้อมูลยังอยู่ครบ — สร้างแฟ้มใหม่หากต้องการส่งอีกครั้ง';

  @override
  String get claimRevoke => 'เพิกถอน';

  @override
  String get claimUntitled => 'แฟ้มที่ไม่มีชื่อ';

  @override
  String get claimRevokeConfirmTitle => 'เพิกถอนแฟ้มนี้หรือไม่?';

  @override
  String get claimRevokeConfirmBody =>
      'ลิงก์จะใช้ไม่ได้ทันทีสำหรับทุกคนที่ถืออยู่ รวมถึงแพลตฟอร์ม ข้อมูลและลิงก์รายคำสั่งซื้อไม่ได้รับผลกระทบ';

  @override
  String get claimRevoked => 'เพิกถอนแฟ้มแล้ว ลิงก์เปิดไม่ได้อีกต่อไป';

  @override
  String get claimRevokeFailed => 'เพิกถอนไม่สำเร็จ ลองใหม่เมื่อออนไลน์';

  @override
  String get claimNotUploaded =>
      'แฟ้มนี้ยังไม่ได้อัปโหลดจึงยังไม่มีลิงก์ เปิดใหม่เมื่อออนไลน์';

  @override
  String get claimDetailLoadFailed =>
      'โหลดแฟ้มไม่สำเร็จ ตรวจสอบการเชื่อมต่อแล้วเปิดใหม่';

  @override
  String get claimsCreateStart =>
      'พิมพ์เลขพัสดุ หรือแตะสแกน เพื่อค้นหาออเดอร์ที่จะเคลม';

  @override
  String get claimsCreateNoOrder =>
      'ไม่พบออเดอร์ที่มีเลขพัสดุนี้ในร้านที่เลือก';

  @override
  String get claimsRemoveItemTitle => 'นำออกจากแฟ้ม';

  @override
  String get claimsRemoveItemConfirm =>
      'นำหลักฐานนี้ออกจากแฟ้มเคลมไหม วิดีโอ/รูปในออเดอร์ยังอยู่ครบ';

  @override
  String get claimsItemRemoved => 'นำออกจากแฟ้มแล้ว';

  @override
  String get claimsItemAdded => 'เพิ่มลงในแฟ้มแล้ว';

  @override
  String get commonRemove => 'นำออก';

  @override
  String get commonDelete => 'ลบ';

  @override
  String get settingDefaultSuffix => 'ค่าเริ่มต้น';

  @override
  String get shopDetailClipLength => 'ความยาววิดีโอ';

  @override
  String get shopDeleteTitle => 'ลบร้าน';

  @override
  String get shopDeleteConfirm =>
      'ลบร้านนี้ไหม ออเดอร์ วิดีโอ และรูปทั้งหมดจะหายไปด้วย และกู้คืนไม่ได้';

  @override
  String get shopDeleteBlockedTitle => 'ร้านยังมีสมาชิกอยู่';

  @override
  String shopDeleteBlockedBody(int count) {
    return 'นำสมาชิกออกให้หมดก่อนลบร้าน ยังเหลืออีก $count คน';
  }

  @override
  String get shopDeleted => 'ลบร้านแล้ว';

  @override
  String bundleSelected(int count) {
    return 'เลือกไว้ $count';
  }

  @override
  String get bundleUploadDrive => 'อัปโหลดขึ้น Drive';

  @override
  String get commonCancel => 'ยกเลิก';

  @override
  String get commonRetry => 'ลองใหม่';

  @override
  String get commonClose => 'ปิด';

  @override
  String get toastChangeLanguage => 'เปลี่ยนภาษา';

  @override
  String get toastTermsPolicy => 'ข้อกำหนดและนโยบาย';

  @override
  String get toastInfoSaved => 'บันทึกข้อมูลแล้ว';

  @override
  String get toastPasswordCreated => 'สร้างรหัสผ่านแล้ว';

  @override
  String get toastPasswordChanged => 'เปลี่ยนรหัสผ่านแล้ว';

  @override
  String get toastPendingDossierConfirm =>
      'คุณยังมีแฟ้มเคลมที่เปิดอยู่ กรุณายืนยันอีกครั้ง';

  @override
  String get toastCopiedShareLink => 'คัดลอกลิงก์แชร์แล้ว';

  @override
  String get toastShareFailed => 'แชร์ไม่สำเร็จ ลองใหม่ภายหลัง';

  @override
  String get toastDownloadingVideo => 'กำลังดาวน์โหลดวิดีโอ';

  @override
  String get toastVideoDownloadedCopied =>
      'ดาวน์โหลดวิดีโอแล้วและคัดลอกที่อยู่ไฟล์';

  @override
  String get toastVideoSavedToGallery => 'บันทึกวิดีโอลงคลังภาพของเครื่องแล้ว';

  @override
  String get toastVideoDownloadFailed =>
      'ดาวน์โหลดวิดีโอไม่สำเร็จ ลองใหม่ภายหลัง';

  @override
  String get toastVideoDeleteUnavailable => 'วิดีโอนี้ลบไม่ได้';

  @override
  String get toastDownloadingPhoto => 'กำลังดาวน์โหลดรูป';

  @override
  String get toastPhotoSavedToGallery => 'บันทึกรูปลงคลังภาพของเครื่องแล้ว';

  @override
  String get toastPhotoDownloadedCopied =>
      'ดาวน์โหลดรูปแล้วและคัดลอกที่อยู่ไฟล์';

  @override
  String get toastPhotoDownloadFailed => 'ดาวน์โหลดรูปไม่สำเร็จ ลองใหม่ภายหลัง';

  @override
  String get toastPhotoNoDownloadLink => 'รูปนี้ยังไม่มีลิงก์ดาวน์โหลด';

  @override
  String get toastPhotoQueued => 'แนบรูปแล้ว — เข้าคิวอัปโหลด';

  @override
  String imageOverFixedCap(String megabytes, String limit) {
    return 'รูปขนาด $megabytes MB เกินขีดจำกัด $limit MB จึงไม่ได้แนบ เลือกรูปที่เล็กกว่านี้';
  }

  @override
  String get toastInvitePending => 'กำลังรอคำเชิญเข้าร้าน';

  @override
  String get toastInviteSent => 'ส่งคำเชิญแล้ว';

  @override
  String get toastMemberAdded => 'เพิ่มสมาชิกแล้ว';

  @override
  String get toastVideoPlayFailed => 'เล่นวิดีโอไม่ได้';

  @override
  String get toastShopCreated => 'สร้างร้านใหม่แล้ว';

  @override
  String get toastVideoQueued => 'บันทึกวิดีโอแล้ว — เข้าคิวอัปโหลด';

  @override
  String get toastVideoNoPlayLink => 'วิดีโอยังไม่มีลิงก์สำหรับเล่น';

  @override
  String get toastVideoNoDownloadLink => 'วิดีโอยังไม่มีลิงก์ดาวน์โหลด';

  @override
  String get toastVideoDeleted => 'ลบวิดีโอแล้ว';

  @override
  String get toastVideoTypeSaved => 'บันทึกประเภทวิดีโอแล้ว';

  @override
  String get toastVideoTypeDeleted => 'ลบประเภทวิดีโอแล้ว';

  @override
  String get toastNoVideoTypeToDelete => 'ไม่มีประเภทวิดีโอให้ลบ';

  @override
  String get toastNoMemberToUpdate => 'ไม่มีสมาชิกให้อัปเดต';

  @override
  String get toastMemberRemoved =>
      'นำออกจากร้านแล้ว (วิดีโอที่ถ่ายไว้ยังอัปโหลดต่อจนเสร็จ)';

  @override
  String get toastInviteRevoked => 'ลบคำเชิญแล้ว — ลิงก์ในอีเมลใช้ไม่ได้อีก';

  @override
  String copiedLabel(String label) {
    return 'คัดลอก$labelแล้ว';
  }

  @override
  String get labelTrackingCode => 'เลขพัสดุ';

  @override
  String resolutionChanged(String value) {
    return 'ความละเอียด: $value';
  }

  @override
  String get accountNoName => 'ยังไม่มีชื่อ';

  @override
  String get accountNoShop => 'ยังไม่ได้เลือกร้าน';

  @override
  String get accountCreatePassword => 'สร้างรหัสผ่าน';

  @override
  String get accountChangePassword => 'เปลี่ยนรหัสผ่าน';

  @override
  String accountLinkedMethods(int count) {
    return 'เชื่อมแล้ว $count';
  }

  @override
  String get roleOwner => 'เจ้าของ';

  @override
  String get roleStaff => 'พนักงาน';

  @override
  String memberInviteSent(String role) {
    return '$role · ส่งคำเชิญแล้ว';
  }

  @override
  String memberInvitePending(String role) {
    return '$role · รอการยืนยัน';
  }

  @override
  String get planFree => 'ฟรี';

  @override
  String get planBasic => 'Basic';

  @override
  String get planSaver => 'Saver';

  @override
  String get planPremium => 'Premium';

  @override
  String get planPro => 'โปร';

  @override
  String get planEnterprise => 'องค์กร';

  @override
  String get roleOther => 'อื่น ๆ';

  @override
  String get roleUnknown => 'ไม่ทราบ';

  @override
  String get memberFallbackName => 'สมาชิก';

  @override
  String get uploadStatusDone => 'อัปโหลดแล้ว';

  @override
  String get uploadStatusPending => 'รออัปโหลด';

  @override
  String get uploadStatusQuotaHold => 'พักไว้ (โควตา)';

  @override
  String get uploadStatusDeleted => 'ลบแล้ว';

  @override
  String get uploadStatusError => 'เกิดข้อผิดพลาดฝั่งเซิร์ฟเวอร์';

  @override
  String get uploadStatusExpired => 'หมดอายุการเก็บรักษา';

  @override
  String expiredOnDate(String date) {
    return 'หมดอายุการเก็บรักษาเมื่อ $date';
  }

  @override
  String get kindPhoto => 'รูปที่แนบ';

  @override
  String get kindVideo => 'วิดีโอ';

  @override
  String get recordedByFallback => 'บัญชีปัจจุบัน';

  @override
  String get deviceUnknown => 'อุปกรณ์ไม่ทราบชื่อ';

  @override
  String get orderNoEvidence => 'ยังไม่มีหลักฐาน';

  @override
  String get timelineEmpty => 'พัสดุนี้ยังไม่มีวิดีโอหรือรูป';

  @override
  String get errorGenericRetry => 'เกิดข้อผิดพลาด กรุณาลองใหม่';

  @override
  String get errorPendingDossier =>
      'คุณยังมีแฟ้มเคลมที่เปิดอยู่ กรุณาจัดการก่อนไปต่อ';

  @override
  String get errorSessionExpired => 'เซสชันหมดอายุ กรุณาเข้าสู่ระบบใหม่';

  @override
  String get errorNoNetwork => 'ไม่มีการเชื่อมต่อเครือข่าย กรุณาลองใหม่';

  @override
  String get errorNoPermission => 'คุณไม่มีสิทธิ์ทำรายการนี้';

  @override
  String get errorServerBusy => 'ระบบกำลังทำงานหนัก กรุณาลองใหม่ภายหลัง';

  @override
  String get errorSessionInvalid => 'เซสชันไม่ถูกต้อง กรุณาเข้าสู่ระบบใหม่';

  @override
  String get errorVideoTypeInUse =>
      'ลบประเภทวิดีโอที่มีวิดีโออยู่แล้วไม่ได้ กรุณาตรวจวิดีโอที่ใช้ประเภทนี้ก่อน';

  @override
  String get errorBuiltinVideoTypeLocked =>
      'ประเภทวิดีโอมาตรฐาน 3 แบบ แก้ไขหรือลบไม่ได้';

  @override
  String get errorVideoTypeNameExists => 'ชื่อประเภทวิดีโอนี้มีอยู่แล้วในร้าน';

  @override
  String get errorCheckNetwork => 'ตรวจสอบเครือข่ายหรือลองใหม่ภายหลัง';

  @override
  String get errorLoadShopList => 'โหลดรายชื่อร้านไม่สำเร็จ';

  @override
  String get errorLoadShopMgmt => 'โหลดหน้าจัดการร้านไม่สำเร็จ';

  @override
  String get errorLoadShopDetail => 'โหลดรายละเอียดร้านไม่สำเร็จ';

  @override
  String get errorLoadMembers => 'โหลดรายชื่อสมาชิกไม่สำเร็จ';

  @override
  String get membersRestricted =>
      'เฉพาะเจ้าของร้านเท่านั้นที่เห็นรายชื่อสมาชิก';

  @override
  String get errorLoadOrders => 'โหลดออเดอร์ไม่สำเร็จ';

  @override
  String get errorLoadOrderDetail => 'โหลดรายละเอียดออเดอร์ไม่สำเร็จ';

  @override
  String get noShopSelectedOrdersDetail => 'กรุณาเลือกร้านก่อนดูออเดอร์';

  @override
  String get noShopSelectedRecordDetail => 'กรุณาเลือกร้านก่อนถ่ายวิดีโอ';

  @override
  String get noShopSelectedManageDetail => 'กรุณาเลือกร้านที่จะจัดการ';

  @override
  String get noOrdersTitle => 'ยังไม่มีออเดอร์';

  @override
  String get noOrdersDetail => 'กรุณาเลือกออเดอร์จากรายการ';

  @override
  String get noVideoDataTitle => 'ไม่มีข้อมูลวิดีโอ';

  @override
  String get cannotOpenVideoTitle => 'เปิดวิดีโอไม่ได้';

  @override
  String get cannotOpenVideoDetail => 'วิดีโอยังไม่มีลิงก์สำหรับเล่น';

  @override
  String get createOrderDialogTitle => 'สร้างออเดอร์ใหม่ไหม';

  @override
  String createOrderDialogBody(String code) {
    return '$code ไม่ตรงกับเลขพัสดุใดในร้านนี้ ตรวจสอบเลขอีกครั้งหรือยืนยันเพื่อสร้างออเดอร์ใหม่';
  }

  @override
  String get createOrderConfirm => 'สร้างออเดอร์ใหม่';

  @override
  String get statOrdersToday => 'ออเดอร์';

  @override
  String get statVideosRecorded => 'วิดีโอที่ถ่ายแล้ว';

  @override
  String get statPendingUpload => 'รออัปโหลด';

  @override
  String get accountPlanQuota => 'พื้นที่เก็บ';

  @override
  String get accountChangePlan => 'เปลี่ยนแพ็กเกจ';

  @override
  String get accountSectionApp => 'แพ็กเกจและแอป';

  @override
  String get accountLanguage => 'ภาษา';

  @override
  String get accountSectionSecurity => 'ความปลอดภัยและการเข้าสู่ระบบ';

  @override
  String get accountLoginMethods => 'วิธีเข้าสู่ระบบ';

  @override
  String get accountSignOut => 'ออกจากระบบ';

  @override
  String get accountSignOutConfirmTitle => 'ออกจากระบบไหม';

  @override
  String get accountSignOutConfirmMessage =>
      'คุณต้องเข้าสู่ระบบใหม่เพื่อใช้แอปต่อ';

  @override
  String get accountDeleteAccount => 'ลบบัญชี';

  @override
  String accountVersion(String version) {
    return 'เวอร์ชัน $version';
  }

  @override
  String get accountShopMgmtHint =>
      'จัดการร้าน/สมาชิก: แตะย้อนกลับที่หัวข้อเพื่อกลับไปชั้นร้าน';

  @override
  String get accountInfoTitle => 'ข้อมูลบัญชี';

  @override
  String get accountFullName => 'ชื่อ-นามสกุล';

  @override
  String get accountFullNameHint => 'กรอกชื่อ-นามสกุลของคุณ';

  @override
  String get accountFullNameRequired => 'กรุณากรอกชื่อ-นามสกุลของคุณ';

  @override
  String get phoneOptionalLabel => 'เบอร์โทรศัพท์ (ไม่บังคับ)';

  @override
  String get phoneOptionalHint =>
      'ไม่บังคับ — ใช้สำหรับการช่วยเหลือบัญชีเท่านั้น';

  @override
  String get phoneInvalid => 'เบอร์โทรศัพท์ไม่ถูกต้อง';

  @override
  String get accountSaveChanges => 'บันทึกการเปลี่ยนแปลง';

  @override
  String get accountEmailLockedHint => 'อีเมลที่ใช้เข้าสู่ระบบ — เปลี่ยนไม่ได้';

  @override
  String get commonContinue => 'ดำเนินการต่อ';

  @override
  String get commonLater => 'ไว้ทีหลัง';

  @override
  String get cameraPermissionRationaleTitle => 'ต้องขอสิทธิ์กล้อง';

  @override
  String get cameraPermissionRationaleBody =>
      'ZenPack ต้องใช้กล้องเพื่อถ่ายวิดีโอหลักฐานการแพ็กสินค้าของออเดอร์คุณ';

  @override
  String get cameraPermissionDeniedTitle => 'ยังถ่ายวิดีโอไม่ได้';

  @override
  String get cameraPermissionDeniedBody =>
      'ZenPack ถ่ายวิดีโอไม่ได้เพราะยังไม่ได้รับสิทธิ์กล้อง คุณยังดู ค้นหา และจัดการออเดอร์ได้ตามปกติ';

  @override
  String get cameraPermissionOpenSettings => 'เปิดการตั้งค่า';

  @override
  String get languageNameVietnamese => 'เวียดนาม';

  @override
  String get languageNameEnglish => 'อังกฤษ';

  @override
  String get languageChangeAppliesNote => 'การเปลี่ยนแปลงมีผลทันทีทั้งแอป';

  @override
  String get linkLinked => 'เชื่อมแล้ว';

  @override
  String get linkNotLinked => 'ยังไม่ได้เชื่อม';

  @override
  String get loginMethodsEmailNote =>
      'อีเมลคือตัวระบุบัญชีของคุณ — ลบไม่ได้ เชื่อม Google/Apple เพื่อเข้าสู่ระบบเร็วขึ้นด้วยบัญชีเดียวกัน';

  @override
  String get loginMethodIdentity => 'ตัวระบุ';

  @override
  String get linkAction => 'เชื่อม';

  @override
  String get linkUnlink => 'ยกเลิกการเชื่อม';

  @override
  String get quotaScreenTitle => 'รายงานและโควตา';

  @override
  String get quotaRemainingThisMonth => 'เหลือในเดือนนี้';

  @override
  String get quotaSubtitle => 'ติดตามพื้นที่เก็บที่คุณใช้อยู่';

  @override
  String quotaRemainingAmount(String amount) {
    return 'เหลือ $amount';
  }

  @override
  String get quotaStorage => 'พื้นที่เก็บ';

  @override
  String get deleteAccountTitleStep1 => 'ลบบัญชีไหม';

  @override
  String get deleteAccountTitleStep2 => 'ยืนยันการลบถาวรไหม';

  @override
  String get deleteAccountBodyStep1 =>
      'วิดีโอ พัสดุ และแฟ้มทั้งหมดของคุณจะถูกลบถาวร การกระทำนี้ย้อนกลับไม่ได้';

  @override
  String get deleteAccountBodyStep2 =>
      'นี่คือขั้นยืนยันสุดท้าย หลังลบแล้วคุณจะถูกออกจากระบบทันที';

  @override
  String get deleteConfirmPermanent => 'ลบถาวร';

  @override
  String get deleteStep1Hint => 'ขั้นที่ 1/2 — จะขอยืนยันอีกครั้ง';

  @override
  String get deleteStep2Hint => 'ขั้นที่ 2/2 — การกระทำนี้ย้อนกลับไม่ได้';

  @override
  String get passwordCurrentLabel => 'รหัสผ่านปัจจุบัน';

  @override
  String get passwordCurrentRequired => 'กรุณากรอกรหัสผ่านปัจจุบัน';

  @override
  String get passwordNewLabel => 'รหัสผ่านใหม่';

  @override
  String get passwordMinHint => 'อย่างน้อย 8 ตัวอักษร';

  @override
  String get passwordNewRequired => 'กรุณากรอกรหัสผ่านใหม่';

  @override
  String get passwordMin8Error => 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร';

  @override
  String get passwordNeedsLetterDigit => 'รหัสผ่านต้องมีทั้งตัวอักษรและตัวเลข';

  @override
  String get passwordTooCommon => 'รหัสผ่านนี้เดาง่ายเกินไป — เลือกใหม่';

  @override
  String get passwordConfirmLabel => 'กรอกรหัสผ่านใหม่อีกครั้ง';

  @override
  String get passwordMismatch => 'รหัสผ่านไม่ตรงกัน';

  @override
  String get passwordSave => 'บันทึกรหัสผ่าน';

  @override
  String get passwordChangeLogoutNote =>
      'หลังเปลี่ยนแล้วคุณจะถูกออกจากระบบในเครื่องอื่น';

  @override
  String get navOrders => 'ออเดอร์';

  @override
  String get navRecord => 'ถ่ายวิดีโอ';

  @override
  String get navAccount => 'บัญชี';

  @override
  String get navClaims => 'เคลม';

  @override
  String get changeAvatar => 'เปลี่ยนรูปโปรไฟล์';

  @override
  String quotaVideosRatio(int remaining, int total) {
    return '$remaining / $total วิดีโอ';
  }

  @override
  String quotaUsedPercent(int percent) {
    return 'ใช้ไป $percent%';
  }

  @override
  String quotaRetentionDays(int days) {
    return '$days วัน';
  }

  @override
  String quotaUsedRatio(String used, String cap, int percent) {
    return 'ใช้ไป $used / $cap · $percent%';
  }

  @override
  String get quotaVideosStored => 'วิดีโอที่เก็บไว้';

  @override
  String quotaVideosStoredCount(int count) {
    return '$count วิดีโอ';
  }

  @override
  String get quotaByType => 'พื้นที่เก็บแยกตามประเภท';

  @override
  String quotaByTypeVideosCount(int count) {
    return 'เก็บไว้ $count วิดีโอ';
  }

  @override
  String quotaRefundNote(int days) {
    return 'พื้นที่จะว่างเมื่อวิดีโอพ้นระยะเก็บรักษา $days วัน';
  }

  @override
  String deletePendingProfilesWarning(int count) {
    return 'คุณยังมีแฟ้ม “ส่งให้แพลตฟอร์มแล้ว” อีก $count แฟ้ม — ลิงก์แชร์ของแฟ้มเหล่านั้นจะใช้ไม่ได้';
  }

  @override
  String get detailRecordedTime => 'เวลาที่ถ่าย';

  @override
  String get detailDuration => 'ความยาว';

  @override
  String get detailRecordedBy => 'ถ่ายโดย';

  @override
  String get detailCapturedTime => 'เวลาที่บันทึก';

  @override
  String get detailCapturedBy => 'บันทึกโดย';

  @override
  String get detailDevice => 'อุปกรณ์';

  @override
  String get detailSize => 'ขนาด';

  @override
  String get detailUploadStatus => 'สถานะอัปโหลด';

  @override
  String get detailSeal => 'การผนึก';

  @override
  String sealSealed(String at) {
    return 'ล็อกแล้ว · $at';
  }

  @override
  String get sealWorking => 'กำลังประทับเวลา…';

  @override
  String get sealWorkingHint =>
      'ไฟล์ที่เก็บไว้ยังไม่มีเวลาฝังบนภาพ ลิงก์แชร์และดาวน์โหลดจึงต้องรออีกนิด ปกติไม่กี่วินาที';

  @override
  String get playLocalCopyNote =>
      'สำเนาชั่วคราวในเครื่องนี้ — ภาพยังไม่มีเวลาประทับ';

  @override
  String get sealNone => 'ถ่ายก่อนที่จะมีระบบผนึก';

  @override
  String get sealFailed => 'ยังไม่ได้ประทับเวลา · วิดีโอยังเล่นและดาวน์โหลดได้';

  @override
  String get sealMismatch => 'ลายนิ้วมือไม่ตรงกัน — ถ่ายคลิปนี้ใหม่';

  @override
  String get sealTimeDrift =>
      'นาฬิกากล้องคลาดจากเซิร์ฟเวอร์ ตราประทับจึงมีเวลาที่เซิร์ฟเวอร์รับคลิปกำกับไว้ด้วย';

  @override
  String get detailSealAnchor => 'หลักฐานอิสระ';

  @override
  String sealAnchorConfirmed(String block) {
    return 'มี · รายการ #$block';
  }

  @override
  String get sealAnchorConfirmedNoBlock => 'มี';

  @override
  String get sealAnchorPending => 'กำลังบันทึกลงบัญชีสาธารณะ (ไม่กี่ชั่วโมง)';

  @override
  String get sealAnchorNone => 'ไม่มี';

  @override
  String get sealVerifyOpen => 'เปิดหน้าตรวจสอบ';

  @override
  String get sealVerifyHint =>
      'ส่งลิงก์นี้ให้แพลตฟอร์ม — เขาตรวจสอบเองได้ ไม่ต้องเชื่อ ZenPack';

  @override
  String get sealVerifyFailed => 'เปิดหน้าตรวจสอบไม่ได้';

  @override
  String get detailPlayVideo => 'เล่นวิดีโอ';

  @override
  String get detailCopyAssetLink => 'คัดลอกลิงก์';

  @override
  String get assetLinkTitle => 'ลิงก์หลักฐาน';

  @override
  String get detailDownloadVideo => 'ดาวน์โหลดวิดีโอ';

  @override
  String get detailDownloadNote =>
      'เฉพาะเจ้าของ/ผู้จัดการ · ใช้เมื่อแพลตฟอร์มขอไฟล์ต้นฉบับ';

  @override
  String get detailTrimVideo => 'ตัดคลิปสั้นเพื่อส่ง';

  @override
  String get detailTrimNote => 'คลิปเต็มยังอยู่ครบ · คลิปที่ตัดยังมีเวลาประทับ';

  @override
  String get trimSave => 'บันทึก';

  @override
  String get trimEstimatedSize => 'ประมาณ';

  @override
  String get trimFailed => 'ตัดวิดีโอไม่สำเร็จ คลิปเต็มยังอยู่';

  @override
  String get trimPreparing => 'กำลังดาวน์โหลดคลิปเต็ม…';

  @override
  String get detailDownloadPhoto => 'ดาวน์โหลดรูป';

  @override
  String get attachPhotoToOrder => 'แนบรูปเข้าออเดอร์';

  @override
  String get deleteVideoAction => 'ลบวิดีโอ';

  @override
  String get deletePhotoAction => 'ลบรูป';

  @override
  String get deleteVideoNote =>
      'เฉพาะเจ้าของ/ผู้จัดการ · ล็อกไว้ระหว่างมีแฟ้มเปิดอยู่ · ยืนยันสองขั้น';

  @override
  String get deleteVideoConfirmTitle => 'ยืนยันครั้งสุดท้าย';

  @override
  String get deleteVideoConfirmBody =>
      'หลักฐานนี้จะถูกลบถาวรและกู้คืนไม่ได้ — ยังจะลบไหม';

  @override
  String get deleteVideoConfirmAction => 'ลบถาวร';

  @override
  String ordersErrorCount(int count) {
    return '· $count ข้อผิดพลาด';
  }

  @override
  String ordersPendingCount(int count) {
    return '· $count รอดำเนินการ';
  }

  @override
  String ordersPendingEvidenceWarning(int count) {
    return '$count หลักฐานยังไม่ได้อัปโหลด · ยังไม่มีลิงก์ให้คัดลอก';
  }

  @override
  String get captureFramePrompt => 'สแกนเลขพัสดุ';

  @override
  String get captureCameraDownHint => 'วางใบปะหน้าในกรอบ';

  @override
  String get cutoverSavedVideo => 'บันทึกวิดีโอแล้ว';

  @override
  String get cutoverPreparingNext => 'กำลังเตรียมสำหรับชิ้นถัดไป';

  @override
  String get cutoverNextOrder => 'ออเดอร์ถัดไป';

  @override
  String get lowStorageTitle => 'พื้นที่เก็บใกล้เต็ม';

  @override
  String get lowStorageBody =>
      'เครื่องนี้พื้นที่เหลือน้อย วิดีโอที่กำลังถ่ายอาจบันทึกไม่ครบ ลบไฟล์บางส่วนก่อนถ่ายต่อ';

  @override
  String get lowStorageAction => 'เข้าใจแล้ว';

  @override
  String cutoverClosedSummary(String code, String duration) {
    return 'ปิดเลขพัสดุ $code แล้ว ($duration)';
  }

  @override
  String get cutoverSignalText => 'เสียงและสั่นตอนเปลี่ยนออเดอร์';

  @override
  String get tooltipBack => 'ย้อนกลับ';

  @override
  String get tooltipSwitchCamera => 'สลับกล้อง';

  @override
  String get tooltipEnterTracking => 'กรอกเลขพัสดุ';

  @override
  String get tooltipZoomIn => 'ซูมเข้า';

  @override
  String get tooltipZoomOut => 'ซูมออก';

  @override
  String get captureResolution => 'ความละเอียด';

  @override
  String get stopRecording => 'หยุดถ่าย';

  @override
  String get videoTypeSettings => 'ตั้งค่าประเภทวิดีโอ';

  @override
  String get uploadQueueTitle => 'คิวอัปโหลด';

  @override
  String get quotaExhaustedNote =>
      'โควตารายเดือนหมดแล้ว ยังถ่ายได้ตามปกติ แต่คลิปเหล่านี้อยู่ในเครื่องนี้และยังไม่ถูกคุ้มครอง — จะอัปโหลดเองเมื่อเพิ่มโควตา';

  @override
  String get queueEmpty => 'ยังไม่มีวิดีโอในคิว';

  @override
  String get queueAutoUploadNote => 'ระบบจะอัปโหลดเองเมื่อคุณออนไลน์';

  @override
  String get waitingUpload => 'รออัปโหลด';

  @override
  String get uploaded => 'อัปโหลดแล้ว';

  @override
  String get waitingQuota => 'รอโควตา · ยังอยู่ในเครื่อง';

  @override
  String get pausedUpload => 'หยุดชั่วคราว';

  @override
  String get queuePauseAction => 'หยุดชั่วคราว';

  @override
  String get queueResumeAction => 'ทำต่อ';

  @override
  String get queueDeleteAction => 'นำออก';

  @override
  String get queueClearAction => 'ล้างทั้งหมด';

  @override
  String get queueClearConfirmTitle => 'ล้างคิวทั้งหมดหรือไม่';

  @override
  String get queueClearConfirmBody =>
      'คลิปที่ยังไม่อัปโหลดอยู่ในเครื่องนี้เท่านั้น ล้างแล้วจะหายถาวร';

  @override
  String get queueDeleteConfirmTitle => 'นำออกจากคิวไหม';

  @override
  String get queueDeleteConfirmBody =>
      'คลิปนี้ยังไม่ได้อัปโหลด — การนำออกจะลบมันออกจากเครื่องอย่างถาวร';

  @override
  String get toastQueueItemDeleted => 'นำออกจากคิวอัปโหลดแล้ว';

  @override
  String get manualTrackingTitle => 'กรอกเลขพัสดุ';

  @override
  String get manualTrackingNote => 'พิมพ์เอง หรือสแกนรหัสอีกครั้ง';

  @override
  String get commonDone => 'เสร็จสิ้น';

  @override
  String get startRecording => 'เริ่มถ่าย';

  @override
  String get returnCodeMismatch => 'รหัสคืนสินค้าไม่ตรงกัน';

  @override
  String get enterCodeManually => 'กรอกรหัสเอง';

  @override
  String get videoTypeLabel => 'ประเภทวิดีโอ';

  @override
  String get videoTypeSelectNote =>
      'เลือกประเภทให้ถูก — เพิ่ม/แก้/ลบได้ในรายละเอียดร้าน';

  @override
  String get videoTypeSheetTitle => 'เลือกประเภทวิดีโอ';

  @override
  String get videoTypeGroupDefault => 'ประเภทมาตรฐาน (บังคับ)';

  @override
  String get videoTypeGroupCustom => 'ประเภทเฉพาะของร้าน';

  @override
  String get manageVideoTypesNote => 'จัดการประเภทวิดีโอ — เปิดรายละเอียดร้าน';

  @override
  String queueFilterAll(int count) {
    return 'ทั้งหมด ($count)';
  }

  @override
  String queueFilterUploading(int count) {
    return 'กำลังอัปโหลด ($count)';
  }

  @override
  String queueFilterErrored(int count) {
    return 'ข้อผิดพลาด ($count)';
  }

  @override
  String queueFilterQuotaWait(int count) {
    return 'รอโควตา ($count)';
  }

  @override
  String queueSummary(int pending, int uploading, int errored) {
    return '$pending วิดีโอรออยู่ · $uploading กำลังอัปโหลด · $errored ล้มเหลว';
  }

  @override
  String uploadingProgress(int percent) {
    return 'กำลังอัปโหลด $percent%';
  }

  @override
  String errorRetryCount(int count) {
    return 'ข้อผิดพลาด · ลองใหม่ ($count)';
  }

  @override
  String returnCodeMismatchBody(String returnCode, String shopName) {
    return '$returnCode ไม่ตรงกับออเดอร์ใดใน $shopName ตรวจรหัสอีกครั้ง กรอกเอง หรือยืนยันเพื่อสร้างออเดอร์ใหม่';
  }

  @override
  String get onboardingSubtitle =>
      'ถ่ายวิดีโอหลักฐานการแพ็กสำหรับผู้ขายออนไลน์';

  @override
  String get onboardingStart => 'เริ่มใช้งาน';

  @override
  String get authSignIn => 'เข้าสู่ระบบ';

  @override
  String get authChooseMethod => 'เลือกวิธีเข้าสู่ระบบ';

  @override
  String get authEmailRequired => 'กรุณากรอกอีเมล';

  @override
  String get authEmailInvalid => 'อีเมลไม่ถูกต้อง';

  @override
  String get authPassword => 'รหัสผ่าน';

  @override
  String get authPasswordRequired => 'กรุณากรอกรหัสผ่าน';

  @override
  String get authForgotPassword => 'ลืมรหัสผ่านไหม';

  @override
  String get registerWithGoogle => 'สมัครด้วย Google';

  @override
  String get registerWithApple => 'สมัครด้วย Apple';

  @override
  String get authSignInGoogle => 'เข้าสู่ระบบด้วย Google';

  @override
  String get authSignInApple => 'เข้าสู่ระบบด้วย Apple';

  @override
  String get authNoAccountPrompt => 'ยังไม่มีบัญชีใช่ไหม ';

  @override
  String get authRegister => 'สมัครสมาชิก';

  @override
  String get authOr => 'หรือ';

  @override
  String get registerTitle => 'สร้างบัญชีใหม่';

  @override
  String get registerConfirmPassword => 'กรอกรหัสผ่านอีกครั้ง';

  @override
  String get registerAgreePolicy => 'ฉันยอมรับนโยบาย ';

  @override
  String get registerViewPolicy => 'ดูนโยบาย';

  @override
  String get registerCreateAccount => 'สร้างบัญชี';

  @override
  String get registerSameEmailNote =>
      'อีเมลเดียวกันจะเชื่อมเข้าบัญชีเดียวโดยอัตโนมัติ';

  @override
  String get registerHaveAccountPrompt => 'มีบัญชีอยู่แล้วใช่ไหม ';

  @override
  String get registerSuccessTitle => 'สร้างบัญชีแล้ว';

  @override
  String registerSuccessVerifyMessage(String email) {
    return 'เราส่งอีเมลยืนยันไปที่ $email ตรวจกล่องจดหมาย (รวมสแปม) แล้วเข้าสู่ระบบ';
  }

  @override
  String get registerSuccessMessage =>
      'บัญชีของคุณพร้อมแล้ว เข้าสู่ระบบด้วยอีเมลและรหัสผ่านที่เพิ่งสมัคร';

  @override
  String get registerSuccessAction => 'เข้าสู่ระบบ';

  @override
  String get loginNotVerifiedTitle => 'ยังไม่ได้ยืนยันอีเมล';

  @override
  String loginNotVerifiedMessage(String email) {
    return 'เปิดอีเมลยืนยันที่ส่งไปยัง $email (ดูสแปมด้วย) กดลิงก์ แล้วเข้าสู่ระบบอีกครั้ง';
  }

  @override
  String get loginResendVerification => 'ส่งอีเมลอีกครั้ง';

  @override
  String get loginVerificationResent => 'ส่งอีเมลยืนยันอีกครั้งแล้ว';

  @override
  String get forgotPasswordTitle => 'ลืมรหัสผ่าน';

  @override
  String get forgotPasswordSubtitle => 'กรอกอีเมลเพื่อรับลิงก์ตั้งรหัสผ่านใหม่';

  @override
  String get forgotPasswordSubmit => 'ส่งลิงก์ตั้งรหัสใหม่';

  @override
  String get forgotPasswordSent => 'ส่งแล้ว — ตรวจกล่องจดหมาย (รวมสแปม)';

  @override
  String get forgotPasswordRememberPrompt => 'จำรหัสผ่านได้แล้วใช่ไหม ';

  @override
  String get shopYourShops => 'ร้านของคุณ';

  @override
  String get shopTapToClockIn => 'แตะร้านเพื่อเข้ากะ · จัดการได้ที่นี่เลย';

  @override
  String get shopLastOpenedNote =>
      'ครั้งหน้าจะเปิดร้านที่เพิ่งเข้าล่าสุดให้ทันที';

  @override
  String get shopManageStore => 'จัดการร้าน';

  @override
  String get shopManageVisibilityNote =>
      'เห็นเฉพาะเจ้าของบัญชี / ผู้จัดการร้าน';

  @override
  String get shopEmpty => 'ยังไม่มีร้าน';

  @override
  String get shopEmptyBody =>
      'บัญชีของคุณยังไม่อยู่ในร้านใด สร้างร้านใหม่เพื่อเริ่มต้น หรือรอคำเชิญจากเจ้าของร้าน';

  @override
  String get shopCreateNew => 'สร้างร้านใหม่ (ชื่อ + แพลตฟอร์ม)';

  @override
  String get shopInvitesHere => 'คำเชิญเข้าร้านจะปรากฏที่นี่';

  @override
  String get shopCreateTitle => 'สร้างร้าน';

  @override
  String get shopNameLabel => 'ชื่อร้าน';

  @override
  String get shopNameRequired => 'กรุณากรอกชื่อร้าน';

  @override
  String get shopPlatform => 'แพลตฟอร์ม';

  @override
  String get shopCreateOwnerNote =>
      'คุณจะเป็นเจ้าของร้าน — เพิ่มสมาชิกภายหลังในหน้าจัดการร้าน';

  @override
  String get shopMgmtVisibilityNote =>
      'พนักงานไม่เห็นหน้านี้ · ผู้จัดการเห็นเฉพาะร้านที่ตนดูแล';

  @override
  String get shopAddNew => 'เพิ่มร้านใหม่';

  @override
  String get sectionMembers => 'สมาชิก';

  @override
  String get sectionShopSettings => 'การตั้งค่าร้าน';

  @override
  String get sectionVideoTypes => 'ประเภทวิดีโอ';

  @override
  String get videoTypesLockedNote =>
      'ประเภทมาตรฐาน 3 แบบถูกล็อก — แก้ไข/ลบไม่ได้';

  @override
  String get addMemberByContact => 'เพิ่มสมาชิกด้วยอีเมล/เบอร์โทร';

  @override
  String get recordResolution => 'ความละเอียดการถ่าย';

  @override
  String get addVideoType => 'เพิ่มประเภท (กรอกชื่อ)';

  @override
  String get createVideoTypeTitle => 'สร้างประเภทวิดีโอ';

  @override
  String get videoTypeName => 'ชื่อประเภทวิดีโอ';

  @override
  String get videoTypeNameHint => 'เช่น ชั่งน้ำหนัก';

  @override
  String get createVideoType => 'สร้างประเภท';

  @override
  String get deleteVideoTypeBody =>
      'ลบได้เฉพาะตอนที่ประเภทนี้ยังไม่มีวิดีโอ ถ้ามีวิดีโอแล้ว ระบบจะกันการลบไว้เพื่อไม่ให้ตัวกรองและสถิติหลักฐานเสียหาย';

  @override
  String get deleteVideoTypeConfirm => 'ลบประเภท';

  @override
  String get deleteVideoTypeNote => '(ลบได้เฉพาะตอนที่ประเภทยังไม่มีวิดีโอ)';

  @override
  String get addMemberTitle => 'เพิ่มสมาชิก';

  @override
  String get addMemberBody =>
      'กรอกอีเมลของบัญชี ZenPack ที่สมัครแล้ว เขาจะได้รับคำเชิญและต้องยืนยันเพื่อเข้าร้าน';

  @override
  String get emailLabel => 'อีเมล';

  @override
  String get emailRequired => 'กรุณากรอกอีเมล';

  @override
  String get emailInvalid => 'กรุณากรอกอีเมลที่ถูกต้องหนึ่งรายการ';

  @override
  String get errorInviteAccountNotFound =>
      'อีเมลนี้ยังไม่มีบัญชี ZenPack ให้เขาสมัครก่อน แล้วเชิญอีกครั้ง';

  @override
  String get errorInviteAlreadyMember => 'เขาเป็นสมาชิกร้านนี้อยู่แล้ว';

  @override
  String get errorInviteMemberLimit =>
      'จำนวนสมาชิกของแพ็กเกจนี้เต็มแล้ว คำเชิญที่ยังไม่ตอบก็นับรวม — ยกเลิกสักรายการเพื่อให้มีที่ว่าง';

  @override
  String get errorInviteAlreadyOwner => 'นั่นคือเจ้าของร้าน — ไม่ต้องเชิญ';

  @override
  String get errorInviteInvalidRequest =>
      'อีเมลนั้นไม่ถูกต้อง ตรวจสอบแล้วส่งใหม่';

  @override
  String get addMemberSubmit => 'เพิ่ม';

  @override
  String get memberOwnerLocked =>
      'เจ้าของเปลี่ยนบทบาทหรือถูกนำออกที่นี่ไม่ได้ — ความเป็นเจ้าของผูกกับร้าน ไม่ใช่กับแถวสมาชิก';

  @override
  String get removeFromShop => 'นำออกจากร้าน';

  @override
  String get revokeInvite => 'ลบคำเชิญ';

  @override
  String get resolutionAppliesNote => 'มีผลกับวิดีโอที่ถ่ายใหม่ของร้าน';

  @override
  String get resolutionDefaultOption => '720p (ค่าเริ่มต้น)';

  @override
  String get ordersSearchHint => 'กรอกเลขพัสดุ';

  @override
  String get ordersEmpty => 'ร้านนี้ยังไม่มีออเดอร์';

  @override
  String recordAutoStopIn(String time) {
    return 'หยุดอัตโนมัติใน $time';
  }

  @override
  String get ordersNotFound => 'ไม่พบออเดอร์';

  @override
  String get ordersNotFoundHint => 'ตรวจเลขพัสดุอีกครั้งแล้วลองใหม่';

  @override
  String ordersPageRange(int first, int last, int total) {
    return '$first–$last จาก $total ออเดอร์';
  }

  @override
  String get ordersPagePrevious => 'หน้าก่อนหน้า';

  @override
  String get ordersPageNext => 'หน้าถัดไป';

  @override
  String ordersPageNumber(int page) {
    return 'หน้า $page';
  }

  @override
  String get filterStatusLabel => 'สถานะ';

  @override
  String get filterStatusAll => 'ทั้งหมด';

  @override
  String get filterStatusPending => 'รออัปโหลด';

  @override
  String get filterStatusError => 'อัปโหลดผิดพลาด';

  @override
  String get filterStatusDone => 'อัปโหลดครบแล้ว';

  @override
  String get filterTimeLabel => 'เวลา';

  @override
  String get filterTimeAll => 'ทุกช่วงเวลา';

  @override
  String get filterTimeToday => 'วันนี้';

  @override
  String get filterTimeYesterday => 'เมื่อวาน';

  @override
  String get filterTime7d => '7 วันล่าสุด';

  @override
  String get filterTime30d => '30 วันล่าสุด';

  @override
  String get filterTimePickDate => 'เลือกวันที่…';

  @override
  String get filterTypeLabel => 'ประเภทวิดีโอ';

  @override
  String get filterTypeAll => 'ทั้งหมด';

  @override
  String deleteVideoTypeTitle(String typeName) {
    return 'ลบประเภท \"$typeName\" ไหม';
  }

  @override
  String memberCurrentRole(String role) {
    return 'บทบาทปัจจุบัน: $role';
  }

  @override
  String get stopCodeTitle => 'คิวอาร์โค้ดหยุดถ่าย';

  @override
  String get stopCodeInstructions =>
      'พิมพ์แล้วติดไว้ที่โต๊ะแพ็ก ยกให้กล้องเห็นระหว่างถ่ายเพื่อหยุดอัตโนมัติ';

  @override
  String get scannedCodeNotFound => 'ไม่มีออเดอร์ที่ตรงกับรหัสที่สแกน';

  @override
  String get onboardingTaglineOne => 'ทุกพัสดุ';

  @override
  String get onboardingTaglineTwo => 'หนึ่งหลักฐาน';

  @override
  String get onboardingTaglineThree => 'ปกป้องรายได้ของคุณ';

  @override
  String get authEmailPlaceholder => 'กรอกอีเมลของคุณ';

  @override
  String get authPasswordPlaceholder => 'กรอกรหัสผ่านของคุณ';

  @override
  String get registerCreateAccountSubtitle => 'สร้างบัญชีใหม่';

  @override
  String get registerFullName => 'ชื่อ-นามสกุล';

  @override
  String get registerFullNameRequired => 'กรุณากรอกชื่อ-นามสกุลของคุณ';

  @override
  String get registerAgreePrefix => 'ฉันยอมรับ';

  @override
  String get registerTermsOfUse => 'ข้อกำหนดการใช้งาน';

  @override
  String get shopChooseTitle => 'เลือกร้าน';

  @override
  String get shopChooseSubtitle => 'เลือกร้านเพื่อไปต่อ';

  @override
  String get shopManageTitle => 'จัดการร้าน';

  @override
  String get shopManageOwnerOnly => 'เห็นเฉพาะเจ้าของและผู้จัดการร้าน';

  @override
  String get noShopTitle => 'ยังไม่มีร้าน';

  @override
  String get noShopLineOne => 'บัญชีของคุณยังไม่อยู่ในร้านใด';

  @override
  String get noShopLineTwo => 'สร้างร้านเพื่อเริ่มต้น';

  @override
  String get noShopLineThree => 'หรือรอคำเชิญจากเจ้าของร้าน';

  @override
  String get noShopCreateCta => 'สร้างร้าน (ชื่อ + แพลตฟอร์ม)';

  @override
  String get noShopInviteHint => 'คำเชิญเข้าร้านจะปรากฏที่นี่';

  @override
  String get createShopTitle => 'สร้างร้าน';

  @override
  String get createShopNameLabel => 'ชื่อร้าน';

  @override
  String get createShopNameHint => 'เช่น ร้าน ABC';

  @override
  String get createShopPlatformLabel => 'แพลตฟอร์ม';

  @override
  String get createShopOwnerNote =>
      'คุณจะเป็นเจ้าของร้าน — เพิ่มสมาชิกภายหลังในหน้าจัดการร้าน';

  @override
  String get createShopSubmit => 'สร้างร้าน';

  @override
  String get shopManageDescription => 'ดูและจัดการร้านที่คุณดูแล';

  @override
  String get shopManageAddCta => 'เพิ่มร้าน';

  @override
  String get shopManageStaffNote =>
      'พนักงานไม่เห็นหน้านี้ — เฉพาะเจ้าของและผู้จัดการร้าน';

  @override
  String get shopDetailTitle => 'รายละเอียดร้าน';

  @override
  String get shopDetailResolution => 'ความละเอียดการถ่าย';

  @override
  String get shopDetailClipDuration => 'ความยาวสูงสุด/วิดีโอ';

  @override
  String clipDurationValue(String minutes) {
    return '$minutes นาที';
  }

  @override
  String clipRecommendedHint(
    String minutes,
    String platform,
    String megabytes,
    String resolution,
  ) {
    return 'แนะนำ $minutes นาที — สำหรับ $platform ($megabytes MB/วิดีโอ) + $resolution';
  }

  @override
  String clipRecommendedHintUnverified(String minutes, String platform) {
    return 'แนะนำ $minutes นาที — ยังไม่ยืนยันขีดจำกัดของ $platform จึงใช้ค่าที่ปลอดภัยที่สุดเท่าที่ทราบ';
  }

  @override
  String clipOverRecommendedWarning(
    String minutes,
    String platform,
    String chosen,
    String megabytes,
  ) {
    return 'เกินคำแนะนำ $minutes นาทีของ $platform — วิดีโอ $chosen นาทีมีขนาดราว $megabytes MB จึงต้องส่งเป็นลิงก์แฟ้มแทนการแนบในแบบฟอร์มร้องเรียน';
  }

  @override
  String get clipDurationTitle => 'ความยาวสูงสุดต่อวิดีโอ';

  @override
  String get clipDurationSubtitle => 'ปิดอัตโนมัติเมื่อถึงความยาวนี้';

  @override
  String clipDurationPlanCap(String minutes) {
    return 'แพ็กเกจของคุณรองรับได้ถึง $minutes นาที';
  }

  @override
  String clipDurationChanged(String minutes) {
    return 'ความยาวสูงสุด/วิดีโอ: $minutes นาที';
  }

  @override
  String get shopDetailImageSize => 'ขนาดรูป';

  @override
  String get shopDetailVideoSize => 'ขนาดวิดีโอ';

  @override
  String get shopDetailUploadSize => 'ขนาดสูงสุด/ไฟล์';

  @override
  String uploadSizeValue(String megabytes) {
    return '$megabytes MB';
  }

  @override
  String uploadRecommendedHint(String megabytes, String platform) {
    return 'แนะนำ $megabytes MB — ขีดจำกัดไฟล์แนบของ $platform';
  }

  @override
  String uploadOverRecommendedWarning(
    String megabytes,
    String platform,
    String chosen,
  ) {
    return 'เกินคำแนะนำ $megabytes MB ของ $platform — ไฟล์ถึง $chosen MB ยังเก็บครบ แต่ต้องส่งเป็นลิงก์แฟ้มแทนการแนบในแบบฟอร์มร้องเรียน';
  }

  @override
  String get uploadSizeValueUnlimited => 'ไม่จำกัด';

  @override
  String get uploadSizeTitle => 'ขนาดสูงสุดต่อไฟล์';

  @override
  String uploadSizeSubtitle(String megabytes, String platform) {
    return 'ไฟล์เกินขีดจำกัดจะไม่ถูกแนบ; $megabytes MB ยังแนบตรงไปยัง $platform ได้';
  }

  @override
  String uploadSizeOptionRecommended(String megabytes) {
    return '$megabytes MB (แนะนำ)';
  }

  @override
  String uploadSizeChanged(String megabytes) {
    return 'ขนาดต่อไฟล์: $megabytes';
  }

  @override
  String avatarTooLarge(String megabytes, String limit) {
    return 'บันทึกชื่อและเบอร์โทรแล้ว รูปโปรไฟล์ $megabytes MB เกินขีดจำกัด $limit MB จึงไม่ถึงเซิร์ฟเวอร์ — เลือกรูปที่เล็กกว่านี้';
  }

  @override
  String avatarUploadFailed(String reason) {
    return 'บันทึกชื่อและเบอร์โทรแล้ว รูปโปรไฟล์ไม่ถึงเซิร์ฟเวอร์: $reason';
  }

  @override
  String nearClipLimitWarning(String minutes) {
    return 'ใกล้ถึงขีดจำกัด $minutes นาที — วิดีโอจะปิดเอง';
  }

  @override
  String get shopDetailAddType => 'เพิ่มประเภท (กรอกชื่อ)';

  @override
  String get inviteMemberTitle => 'เชิญสมาชิก';

  @override
  String get inviteRoleFixedNote =>
      'เขาเข้าร่วมในฐานะพนักงาน: ถ่ายวิดีโอและดูวิดีโอของตัวเองได้';

  @override
  String get inviteMemberHint => '(ยังไม่มีบัญชี → ส่งคำเชิญ)';

  @override
  String get videoTypeIcon => 'ไอคอน';

  @override
  String get videoTypeColor => 'สี';

  @override
  String get createVideoTypeSubmit => 'สร้างประเภท';

  @override
  String get deleteVideoTypeSafeNote => 'ไม่มีหลักฐานใดสูญหาย';

  @override
  String get commonConfirm => 'ยืนยัน';

  @override
  String orderErrorCount(int count) {
    return '$count ล้มเหลว';
  }

  @override
  String get videoDetailSheetTitle => 'รายละเอียดวิดีโอ';

  @override
  String get tooltipStopRecording => 'หยุดถ่าย';

  @override
  String get dossierLinkTitle => 'ลิงก์แฟ้มข้อพิพาท';

  @override
  String get accountEndQr => 'รหัสหยุดถ่าย';

  @override
  String get accountEndQrTitle => 'รหัสหยุดถ่าย';

  @override
  String get accountEndQrShare => 'แชร์รหัส';

  @override
  String get accountEndQrSave => 'บันทึกลงคลังภาพ';

  @override
  String get recordInterruptedTitle => 'หยุดถ่ายชั่วคราว';

  @override
  String get recordInterruptedBody =>
      'การถ่ายถูกหยุดชั่วคราวเพราะมีสิ่งรบกวน ถ่ายต่อไหม';

  @override
  String get recordInterruptedResume => 'ถ่ายต่อ';

  @override
  String get recordInterruptedFinish => 'จบ';

  @override
  String get commonApply => 'ใช้ค่านี้';

  @override
  String get unitMinutes => 'นาที';

  @override
  String get clipDurationCustomLabel => 'หรือกรอกจำนวนนาทีที่ต้องการ';

  @override
  String get supportOpenFailed => 'เปิดไม่ได้ — ตรวจว่าติดตั้งแอปแล้วหรือยัง';

  @override
  String get feedbackThanksTitle => 'ขอบคุณ!';

  @override
  String get feedbackThanksBody => 'ความคิดเห็นของคุณช่วยให้ ZenPack ดีขึ้น';

  @override
  String get feedbackTitle => 'อยากบอกอะไรกับเราบ้าง';

  @override
  String get feedbackHint => 'พิมพ์ความคิดเห็นของคุณ...';

  @override
  String get feedbackSend => 'ส่งความคิดเห็น';

  @override
  String get feedbackThanks => 'ขอบคุณสำหรับความคิดเห็น';

  @override
  String get accountSectionAbout => 'เกี่ยวกับ';

  @override
  String get accountFeedback => 'ส่งความคิดเห็นถึงเรา';

  @override
  String get accountFeedbackNote => 'แบ่งปันความคิดเพื่อให้ ZenPack ดีขึ้น';

  @override
  String get accountRateApp => 'ให้คะแนนแอป';

  @override
  String get accountRateAppNote => 'สนับสนุนการพัฒนา ZenPack';

  @override
  String get supportFacebook => 'ทักทางเฟซบุ๊ก';

  @override
  String get supportZalo => 'ทักทาง Zalo';

  @override
  String get supportCall => 'โทรหาฝ่ายช่วยเหลือ';

  @override
  String sheetCustomMin(String min, String unit) {
    return 'กรอก $min $unit ขึ้นไป';
  }

  @override
  String sheetCustomRange(String min, String max, String unit) {
    return 'กรอกระหว่าง $min ถึง $max $unit';
  }

  @override
  String get accountEndQrNote =>
      'พิมพ์แล้วติดไว้ที่โต๊ะแพ็ก สแกนระหว่างถ่ายเพื่อปิดคลิป รหัสเดียวกันใช้ได้ทุกเครื่อง';

  @override
  String get languageChangeScopeNote =>
      'ทุกป้ายกำกับ การแจ้งเตือน และแฟ้ม\nจะเปลี่ยนเป็นภาษาที่คุณเลือก';

  @override
  String get manualEntryEmptyError => 'กรอกเลขพัสดุก่อนเริ่มถ่าย';

  @override
  String get appUpdateTitle => 'มีเวอร์ชันใหม่';

  @override
  String get appUpdateMessage =>
      'อัปเดต ZenPack เพื่อรับการแก้ไขและฟีเจอร์ล่าสุด';

  @override
  String get appUpdateNow => 'อัปเดต';

  @override
  String get appUpdateLater => 'ไว้ทีหลัง';

  @override
  String get quotaVideosThisMonth => 'วิดีโอเดือนนี้';

  @override
  String get quotaSubtitleVideos => 'ติดตามว่าคุณถ่ายวิดีโอไปกี่คลิปในเดือนนี้';

  @override
  String get quotaUpgrade => 'อัปเกรดแพ็กเกจ';

  @override
  String get quotaBlockedTitle => 'โควตาวิดีโอหมดแล้ว';

  @override
  String get quotaBlockedNote =>
      'ยังถ่ายได้ตามปกติ แต่คลิปยังอัปโหลดไม่ได้ — คลิปอยู่ในเครื่องนี้และยังไม่ถูกคุ้มครอง จะอัปโหลดเองเมื่อเพิ่มโควตา';

  @override
  String get quotaBlockedOwnerNote =>
      'โควตาของร้านนี้กำหนดโดยเจ้าของบัญชี — โปรดขอให้เพิ่มให้ แพ็กเกจที่คุณซื้อเองจะใช้ได้กับบัญชีของคุณเท่านั้น';

  @override
  String get quotaTopupCredits => 'เติมเครดิต';

  @override
  String get quotaOverCap => 'เกินโควตาของแพ็กเกจ';

  @override
  String quotaBlockAt(int n) {
    return 'ระงับการถ่ายใหม่ที่ $n วิดีโอ';
  }

  @override
  String get quotaResetMonthly => 'รีเซ็ตต้นเดือนหน้า ไม่มียอดยกมา';

  @override
  String get storageOwnTitle => 'พื้นที่เก็บของคุณเอง';

  @override
  String storageOwnPending(int count) {
    return '$count วิดีโอรอส่งเข้าพื้นที่เก็บของคุณ';
  }

  @override
  String storageOwnProblem(int count) {
    return '$count วิดีโอในพื้นที่เก็บของคุณมีปัญหา';
  }

  @override
  String get quotaExhaustedWarn =>
      'อย่าถอนการติดตั้งแอปหรือล้างข้อมูลจนกว่าจะอัปโหลดเสร็จ';

  @override
  String quotaStrandedTitle(int count) {
    return '$count วิดีโอรออยู่ในเครื่องนี้';
  }

  @override
  String get quotaStrandedNote =>
      'วิดีโอเหล่านี้มีอยู่แค่ในเครื่องนี้ ถ้าทำเครื่องหาย ถอนการติดตั้ง หรือล้างข้อมูล วิดีโอจะหายไปด้วย';

  @override
  String get storageTitle => 'พื้นที่เก็บวิดีโอ';

  @override
  String get storageSave => 'บันทึกการเลือกที่จัดเก็บ';

  @override
  String get storageSystemName => 'พื้นที่เก็บของระบบ';

  @override
  String get storageS3Name => 'พื้นที่เก็บของคุณเอง (S3)';

  @override
  String get storageDriveName => 'Google Drive ของคุณ';

  @override
  String get storageSystemDesc =>
      'ค่าเริ่มต้น ไม่ต้องตั้งค่าอะไร และเป็นที่เดียวที่คำมั่นเรื่องหลักฐานทุกข้อยังคงอยู่ครบ';

  @override
  String get storageOwnDesc =>
      'วิดีโอใหม่จะเข้าพื้นที่เก็บของคุณโดยตรง ส่วนวิดีโอเก่ายังอยู่ที่เดิมจนหมดระยะเก็บรักษา';

  @override
  String get storageNoPresign =>
      'พื้นที่เก็บนี้เซ็นลิงก์ดาวน์โหลดไม่ได้ วิดีโอจึงต้องผ่านเซิร์ฟเวอร์ — คนที่เปิดลิงก์ของคุณจะรู้สึกช้ากว่า';

  @override
  String get storageNoObjectLock =>
      'พื้นที่เก็บนี้ไม่มีการล็อกอ็อบเจกต์ คุณจึงรับรองกับแพลตฟอร์มไม่ได้ว่าหลักฐานลบไม่ได้';

  @override
  String get storageNotInPlan =>
      'แพ็กเกจของคุณยังไม่รวมพื้นที่เก็บของตัวเอง อัปเกรดบนเว็บเพื่อใช้งาน';

  @override
  String get storageHealthTitle => 'สุขภาพพื้นที่เก็บ';

  @override
  String get storageHealthTotal => 'วิดีโอทั้งหมด';

  @override
  String get storageHealthIntact => 'สมบูรณ์';

  @override
  String get storageHealthUnreachable => 'เข้าถึงไม่ได้';

  @override
  String get storageHealthMismatched => 'ไม่ตรงกับการผนึก';

  @override
  String get storageHealthPendingRelay => 'รออยู่ในพื้นที่พักข้อมูล';

  @override
  String get storageProblemsNote =>
      'วิดีโอบางรายการมีปัญหาในพื้นที่เก็บของคุณ ตรวจสิทธิ์การเข้าถึงฝั่งผู้ให้บริการ';

  @override
  String get storageTest => 'ทดสอบการเชื่อมต่ออีกครั้ง';

  @override
  String get storageInUse => 'กำลังใช้งาน';

  @override
  String storageLastCheckAt(String time) {
    return 'ตรวจสอบล่าสุด: $time';
  }

  @override
  String get storageNeverChecked => 'ยังไม่เคยตรวจสอบ';

  @override
  String get storageDriveAccount => 'บัญชี Drive';

  @override
  String get storageDisconnect => 'เลิกใช้พื้นที่เก็บของตัวเอง';

  @override
  String get storageDisconnectConfirm =>
      'วิดีโอที่ถ่ายนับจากนี้จะเข้าพื้นที่เก็บของระบบ ส่วนวิดีโอเก่ายังอยู่ในพื้นที่ของคุณ และระบบจะเข้าถึงไม่ได้อีก';

  @override
  String get storageConnectS3 => 'เชื่อมพื้นที่เก็บ S3';

  @override
  String get storageConnectDrive => 'เชื่อม Google Drive';

  @override
  String get storageConnectHint =>
      'ให้สิทธิ์อ่าน/เขียน/ลบ เฉพาะที่ prefix ด้านล่างเท่านั้น — ไม่ต้องให้สิทธิ์ทั้ง bucket';

  @override
  String get storageConnectSubmit => 'ทดสอบและบันทึก';

  @override
  String get storageFieldEndpoint => 'Endpoint';

  @override
  String get storageFieldBucket => 'Bucket';

  @override
  String get storageFieldAccessKey => 'Access key ID';

  @override
  String get storageFieldSecretKey => 'Secret access key';

  @override
  String get storageFieldRegion => 'Region';

  @override
  String get storageFieldPrefix => 'Prefix';

  @override
  String get storageFieldPrefixHint =>
      'โฟลเดอร์ย่อยใน bucket ถ้าไม่แน่ใจให้ใช้ค่าเริ่มต้น';

  @override
  String get storageConnected => 'เชื่อมพื้นที่เก็บของคุณแล้ว';

  @override
  String get storageDisconnected => 'ยกเลิกการเชื่อมพื้นที่เก็บของคุณแล้ว';

  @override
  String get storageTestOk => 'การเชื่อมต่อปกติดี';

  @override
  String get storageOwnerOnly =>
      'เฉพาะเจ้าของร้านเท่านั้นที่เปลี่ยนพื้นที่เก็บได้';

  @override
  String get dangerZone => 'โซนอันตราย';

  @override
  String get shopDelete => 'ลบร้าน';

  @override
  String get shopDeleteDesc =>
      'ลบออเดอร์ หลักฐาน ไฟล์ที่เก็บไว้ และสมาชิกอย่างถาวร ย้อนกลับไม่ได้';

  @override
  String get shopDeleteConfirmTitle => 'ลบร้านนี้ไหม';

  @override
  String shopDeleteConfirmBody(int orders, int videos, int members) {
    return '$orders ออเดอร์ · $videos วิดีโอ · $members สมาชิก จะถูกลบถาวร';
  }

  @override
  String shopDeleteOpenDossiers(int n) {
    return 'ยังมีแฟ้มเคลมเปิดอยู่ $n แฟ้ม ลิงก์ที่ส่งให้แพลตฟอร์มไปแล้วจะใช้ไม่ได้ทันทีที่คุณลบ';
  }

  @override
  String get shopDeleteForce => 'ยืนยันลบ';

  @override
  String get shopDeleteFailed => 'ลบร้านไม่สำเร็จ';

  @override
  String get claimsCreatedLocalOnly =>
      'บันทึกแฟ้มไว้ในเครื่องนี้แล้ว แต่ยังอัปโหลดไม่ได้ จึงยังไม่มีลิงก์แชร์ — เปิดใหม่อีกครั้งเมื่อออนไลน์';

  @override
  String get claimsLinkCopied =>
      'คัดลอกลิงก์แฟ้มแล้ว วางลงช่องทางเคลมของแพลตฟอร์ม';

  @override
  String get shopRenameTitle => 'เปลี่ยนชื่อร้าน';

  @override
  String get shopRenameHint => 'ชื่อร้าน';

  @override
  String get shopRenamed => 'เปลี่ยนชื่อร้านแล้ว';

  @override
  String get commonSave => 'บันทึก';

  @override
  String get inviteJoinRow => 'ฉันมีคำเชิญ';

  @override
  String inviteJoinedShop(String shop) {
    return 'เข้าร่วม $shop แล้ว';
  }

  @override
  String inviteAlreadyJoined(String shop) {
    return 'คุณอยู่ใน $shop อยู่แล้ว';
  }

  @override
  String get inviteBadLink => 'ลิงก์นั้นไม่ถูกต้อง วางลิงก์ทั้งอันจากอีเมล';

  @override
  String get inviteNotFound => 'ไม่มีคำเชิญนี้หรือถูกยกเลิกแล้ว';

  @override
  String get inviteTaken => 'มีคนอื่นรับคำเชิญนี้ไปแล้ว';

  @override
  String get inviteExpired => 'คำเชิญหมดอายุแล้ว แจ้งเจ้าของร้านให้ส่งใหม่';

  @override
  String get inviteQrRow => 'คิวอาร์โค้ด';

  @override
  String get inviteQrTitle => 'รหัสเชิญเข้าร้าน';

  @override
  String get inviteQrNote =>
      'ให้คนที่คุณต้องการเชิญสแกนหน้าจอนี้ รหัสใช้ได้ครั้งเดียว เมื่อมีคนเข้าร่วมรหัสจะเปลี่ยน';

  @override
  String get inviteScanTitle => 'สแกนรหัสคำเชิญ';

  @override
  String get inviteScanDetail =>
      'ขอให้เจ้าของร้านเปิดคิวอาร์โค้ดคำเชิญ แล้วสแกนที่นี่';

  @override
  String get commonShare => 'แชร์';

  @override
  String get inviteQrSaved => 'บันทึกคิวอาร์โค้ดลงคลังภาพแล้ว';

  @override
  String get inviteQrSaveFailed => 'บันทึกคิวอาร์โค้ดไม่สำเร็จ';

  @override
  String get voiceRecordingStarted => 'เริ่มบันทึกแล้ว';

  @override
  String get voiceRecordingStopped => 'หยุดบันทึกแล้ว';

  @override
  String get voiceWrongCode => 'รหัสไม่ถูกต้อง';

  @override
  String get voiceCapSoon => 'วิดีโอกำลังจะปิดเอง';

  @override
  String voiceCapNear(int minutes) {
    return 'ใกล้ถึงขีดจำกัด $minutes นาที วิดีโอจะปิดเอง';
  }

  @override
  String get voiceInterrupted => 'การบันทึกถูกขัดจังหวะ';

  @override
  String get videoTypePacking => 'การแพ็กสินค้า';

  @override
  String get videoTypeCarrier => 'ส่งมอบให้ขนส่ง';

  @override
  String get videoTypeReturn => 'คืนสินค้า';

  @override
  String get storageIntro =>
      'วิดีโอของร้านเก็บไว้ที่ไหน ไม่ว่าเก็บที่ใด บันทึกการผนึกยังอยู่ที่ระบบเสมอ — เปลี่ยนที่เก็บไม่ทำให้หลักฐานอ่อนลง';

  @override
  String get storageS3Title => 'คลาวด์ของคุณเอง (มาตรฐาน S3)';

  @override
  String get storageS3Desc =>
      'AWS S3, Cloudflare R2, MinIO, Wasabi… วิดีโออยู่ในบัคเก็ตของคุณ และความคงทนเป็นความรับผิดชอบของคุณเอง';

  @override
  String get storageDriveTitle => 'Google Drive';

  @override
  String get storageDriveDesc =>
      'เชื่อมด้วยการให้สิทธิ์ครั้งเดียว ไม่ต้องวางคีย์ บัญชีฟรีมีเพียง 15 GB ที่ใช้ร่วมกับ Gmail';

  @override
  String get storageNeedProPlan =>
      'การเชื่อมที่เก็บของคุณเองต้องใช้แพ็กเกจ Professional ขึ้นไป';

  @override
  String get attachCodeToOrder => 'สแกนรหัสเพิ่มเข้าออเดอร์นี้';

  @override
  String get attachedCodes => 'รหัสที่แนบเพิ่ม';

  @override
  String get codeAttached => 'แนบรหัสเข้าออเดอร์แล้ว';

  @override
  String get codeBelongsToAnotherOrder =>
      'รหัสนี้อยู่กับออเดอร์อื่นแล้ว รวมไม่ได้';

  @override
  String get codeAttachFailed => 'แนบรหัสไม่ได้ ลองอีกครั้ง';
}
