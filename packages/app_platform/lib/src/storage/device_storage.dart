import 'package:disk_space_plus/disk_space_plus.dart';

/// Below this, a 15-minute 720p clip risks not saving in full — FR-09's
/// "cảnh báo TRƯỚC khi quay" threshold. ponytail: one flat number for every
/// device/resolution rather than estimating per-clip size; revisit if lower
/// resolutions turn out to need a lower bar too.
const kLowStorageThresholdMb = 300;

/// Free device storage in MB, or `null` if the platform can't report it
/// (in which case the caller should not warn — better silent than a false
/// alarm on a device we can't actually read).
Future<double?> getFreeDiskSpaceMb() => DiskSpacePlus().getFreeDiskSpace;
