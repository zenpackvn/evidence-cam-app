/// Centralized corner-radius scale — the five shadcn steps derived from
/// `--radius: .625rem` (design-dna-app.md §3). Five steps, and no sixth:
/// the old 16/20 pair is gone.
///
/// Use these tokens with `BorderRadius.circular` (or `Radius.circular`) instead
/// of hardcoded pixel values so rounding stays consistent and can be tuned in
/// one place.
///
/// Prefer the **role-named** constants ([control], [dialog], [card], [pill])
/// in new code — they say what the value is for, which is how shadcn assigns
/// radii. The legacy t-shirt names are kept so existing call sites compile,
/// retuned onto the same five steps.
abstract final class AppRadius {
  // ── The five steps ────────────────────────────────────────────────────────

  /// `rounded-sm` — 6px.
  static const double sm6 = 6;

  /// `rounded-md` — 8px. Button, input, badge, select content.
  static const double control = 8;

  /// `rounded-lg` — 10px. Dialog, tabs list, checkbox.
  static const double dialog = 10;

  /// `rounded-xl` — 14px. Card.
  static const double card = 14;

  /// `rounded-full` — switch track/thumb, avatar, progress track.
  static const double pill = 999;

  /// Bottom sheets are **square** — shadcn's sheet is `inset-x-0 bottom-0
  /// h-auto border-t`, separated by a top hairline, not by rounding
  /// (design-dna-app.md §3, called out explicitly).
  static const double sheet = 0;

  // ── Legacy aliases, retuned onto the five steps ───────────────────────────

  /// 6px - tiny indicators (e.g. carousel dots). Was 4.
  static const double xs = sm6;

  /// 8px - chips, buttons, inputs, thumbnails. Unchanged.
  static const double sm = control;

  /// 14px - cards. Was 16.
  static const double lg = card;

  /// 10px - dialogs and elevated overlays. Was 20.
  ///
  /// Deliberately *smaller* than [lg]: in shadcn a dialog is `rounded-lg` (10)
  /// while a card is `rounded-xl` (14), so the ordering by name inverts here.
  static const double xl = dialog;
}
