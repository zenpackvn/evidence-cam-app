import 'dart:typed_data';

import 'package:gal/gal.dart';
import 'package:injectable/injectable.dart';

/// Saves an image to the device photo library. Wraps `gal` so features depend
/// on this port, not the plugin. Requesting the OS add-photo permission is
/// handled by `gal` on demand — declare the usage strings in `Info.plist`
/// (iOS `NSPhotoLibraryAddUsageDescription`) / the Android manifest.
@lazySingleton
class GallerySaveService {
  const GallerySaveService();

  /// Writes [bytes] (a PNG) to the gallery. Throws [GalException] on failure
  /// (e.g. permission denied) so the caller can show an error.
  Future<void> savePng(Uint8List bytes) => Gal.putImageBytes(bytes);

  /// Whether the app has (or can request) permission to add to the gallery.
  Future<bool> hasAccess() => Gal.hasAccess(toAlbum: true);

  /// Requests add-to-gallery access; returns whether it was granted.
  Future<bool> requestAccess() => Gal.requestAccess(toAlbum: true);
}
