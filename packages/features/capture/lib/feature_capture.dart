/// Capture feature: the hands-free recording session state machine and the
/// on-device bill scanner.
///
/// The app shell's record route (`ec_record_route.dart`) and scan route drive
/// `RecordingSessionBloc` and construct a `BillScanner`; the Flow 3 screens they
/// render still live in the app and relocate here in a later step.
library;

export 'src/camera_video_capture_pin.dart';
export 'src/device_samples.dart';
export 'src/ec_bill_scanner.dart';
export 'src/ec_chon_anh_quet.dart';
export 'src/ec_evidence_store.dart';
export 'src/ec_evidence_uploader.dart';
export 'src/ec_flow3.dart';
export 'src/ec_preview_store.dart';
export 'src/ec_stop_code_screen.dart';
export 'src/ec_upload_queue.dart';
export 'src/ec_video_faststart.dart';
export 'src/ec_video_trim.dart';
export 'src/ec_zoom.dart';
export 'src/recording_session.dart';
