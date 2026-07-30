import 'package:flutter/material.dart';

/// Centralized elevation scale and shadow tokens — the four Tailwind steps
/// shadcn assigns per component (design-dna-app.md §4).
///
/// A shadow states *what a surface is*, never what state it is in: depth must
/// **not** signal hover, focus or press. Those three are colour, border and
/// ring (§4, §6).
///
/// Blur values are the CSS px values carried over unchanged; Flutter's
/// `blurRadius` is close enough to CSS `blur-radius` at these small sizes that
/// matching the numbers keeps the design file and the app in step.
abstract final class AppElevation {
  // ── Material elevation (used by flex_color_scheme's component themes) ─────

  /// 0 - flat surfaces (e.g. app bars, flush content).
  static const double none = 0;

  /// 1 - barely-there separation (e.g. resting cards, list tiles).
  static const double sm = 1;

  /// 3 - default raised surfaces (e.g. buttons, chips, sheets).
  static const double md = 3;

  /// 6 - prominently lifted surfaces (e.g. dialogs, FABs, overlays).
  static const double lg = 6;

  // ── The four shadcn shadow steps ──────────────────────────────────────────

  /// `shadow-xs` — `0 1px 2px rgb(0 0 0/.05)`.
  /// Every filled control: button, input, switch, checkbox.
  static const List<BoxShadow> shadowXs = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
  ];

  /// `shadow-sm` — `0 1px 3px rgb(0 0 0/.1), 0 1px 2px -1px rgb(0 0 0/.1)`.
  /// Cards.
  static const List<BoxShadow> shadowSm = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 2,
      spreadRadius: -1,
      offset: Offset(0, 1),
    ),
  ];

  /// `shadow-md` — `0 4px 6px -1px rgb(0 0 0/.1), 0 2px 4px -2px rgb(0 0 0/.1)`.
  /// Select / dropdown content.
  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 6,
      spreadRadius: -1,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 4,
      spreadRadius: -2,
      offset: Offset(0, 2),
    ),
  ];

  /// `shadow-lg` — `0 10px 15px -3px rgb(0 0 0/.1), 0 4px 6px -4px rgb(0 0 0/.1)`.
  /// Dialogs and bottom sheets.
  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 15,
      spreadRadius: -3,
      offset: Offset(0, 10),
    ),
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 6,
      spreadRadius: -4,
      offset: Offset(0, 4),
    ),
  ];

  /// Modal scrim — shadcn's overlay is flatly `bg-black/50` (§4).
  static const Color scrim = Color(0x80000000);

  /// A card's resting shadow. Kept under its original name so existing call
  /// sites compile; it is now exactly `shadow-sm` instead of the old
  /// two-layer "lifted" shadow, which was heavier than the system allows.
  static const List<BoxShadow> cardShadow = shadowSm;
}
