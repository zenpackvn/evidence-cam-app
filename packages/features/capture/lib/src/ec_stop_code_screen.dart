/// Shows the printable "end session" QR code — sticking this at the packing
/// table lets a seller stop a recording by showing it to the camera, instead
/// of reaching for the on-screen Stop button.
library;

import 'package:app_ui/app_ui.dart';
import 'package:ec_ui/ec_ui.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageScaffold;
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'recording_session.dart' show kEndSessionBrand, kEndSessionQr;

TextStyle _t(double size, FontWeight weight, Color color) =>
    TextStyle(fontSize: size, fontWeight: weight, color: color, height: 1.4);

/// A full screen with the end-session QR code, large enough to photograph or
/// screenshot for printing.
class EcStopCodeScreen extends StatelessWidget {
  const EcStopCodeScreen({this.onBack, super.key});

  /// Called when the header back chevron is tapped.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: BrandColors.bg,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
              child: Row(
                children: [
                  EcTap(
                    onTap: onBack,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: BrandColors.ink,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      context.l10n.stopCodeTitle,
                      style: _t(18, FontWeight.w700, BrandColors.ink),
                    ),
                  ),
                  const SizedBox(width: 42),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: ecSquircleDecoration(
                          radius: 20,
                          color: Colors.white,
                          shadows: const [
                            BoxShadow(
                              color: Color(0x1A000000),
                              blurRadius: 16,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            QrImageView(
                              data: kEndSessionQr,
                              size: 220,
                              backgroundColor: Colors.white,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              kEndSessionBrand,
                              style: _t(18, FontWeight.w700, BrandColors.ink),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        context.l10n.stopCodeInstructions,
                        textAlign: TextAlign.center,
                        style: _t(14, FontWeight.w400, BrandColors.mut),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
