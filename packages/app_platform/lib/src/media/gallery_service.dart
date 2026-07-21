import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'package:photo_manager/photo_manager.dart';

/// One image from the device library (SM-005 F02-S11): exposes a small grid
/// thumbnail and resolves the full file path only when the user selects it.
class GalleryImage {
  GalleryImage(this._asset);

  final AssetEntity _asset;

  /// A square JPEG thumbnail for the picker grid.
  Future<Uint8List?> thumbnail({int size = 300}) =>
      _asset.thumbnailDataWithSize(ThumbnailSize.square(size));

  /// The full-resolution file path, resolved on selection.
  Future<String?> resolvePath() async => (await _asset.file)?.path;
}

/// Reads the device photo library for the in-app "Chọn từ thư viện" grid
/// (SM-005). Wraps `photo_manager` so features depend on this port, not the
/// plugin's `AssetEntity` types directly.
@lazySingleton
class GalleryService {
  /// Requests photo-library access. Returns true when granted (full or the
  /// iOS "limited" selection); false when denied.
  Future<bool> ensurePermission() async {
    final state = await PhotoManager.requestPermissionExtend();
    return state.isAuth || state.hasAccess;
  }

  /// The most recent [limit] images, newest first. Empty when there are none or
  /// access was not granted.
  Future<List<GalleryImage>> recentImages({int limit = 40}) async {
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );
    if (albums.isEmpty) return const [];
    final assets = await albums.first.getAssetListRange(start: 0, end: limit);
    return assets.map(GalleryImage.new).toList();
  }

  /// Opens the OS settings so the user can grant photo access after a denial.
  Future<void> openSettings() => PhotoManager.openSetting();
}
