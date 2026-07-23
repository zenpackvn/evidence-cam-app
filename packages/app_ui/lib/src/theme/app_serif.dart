import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The Playfair Display serif used by the in-app screen frames of
/// `pencil-new.pen` (mailbox, album, stamp detail): the "StampMail" wordmark,
/// page titles, and stamp names. The theme's display face stays Baloo 2 per
/// the foundations (the auth flow uses it); screens opt into the serif here.
abstract final class AppSerif {
  /// A Playfair Display style: [fontSize] and [height] straight from the
  /// design frame, defaulting to the bold weight every frame uses.
  static TextStyle style({
    required double fontSize,
    Color? color,
    FontWeight fontWeight = FontWeight.w700,
    double height = 1.21,
  }) => GoogleFonts.playfairDisplay(
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: height,
    color: color,
  );
}
