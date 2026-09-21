import 'package:flutter/material.dart';

/// EvidenceCam palette — the **shadcn/ui** token set from
/// `specs/projects/evidencecam/design-spec/design-dna-app.md` §1, whose values
/// come from the console's `theme.css` ("the mobile app's design DNA").
///
/// The legacy field names (`ink`, `mut`, `line`, `soft`, `dark`, `bg`, `rec`)
/// are deliberately **unchanged** so the ~460 existing call sites keep
/// compiling and the whole app recolours from this one file — the same
/// inheritance rule `theme.css` states for the console.
///
/// Four binding laws (design-dna-app.md §0):
///  1. Neutrals carry a whisper of warmth (OKLCH chroma 0.004–0.013, hue 45–50)
///     — the console's 09/2026 orange palette; never tinted brand.
///  2. [dark] (`--primary` `#D34500`, orange) is the only brand colour that fills
///     anything. [ring] `#EE5D2B` is a focus ring / chart colour only. Green is
///     no longer brand: it is the `--state-done` status colour ([success]).
///  3. Hover / active / selected read as **ink**, not brand — see [accent] and
///     [sidebarAccent], which are grey.
///  4. The palette is closed at five groups: neutral · primary · destructive ·
///     chart · warning. There is no sixth.
abstract final class BrandColors {
  /// Đang ở bảng màu TỐI hay không.
  ///
  /// Vì sao là một cờ tĩnh chứ không phải đọc từ `BuildContext`: 790 chỗ trong
  /// app gọi thẳng `BrandColors.ink` như một hằng số. Đổi sang đọc theo context
  /// là sửa cả 790 chỗ đó — còn đổi `static const` thành `static get` thì
  /// KHÔNG chỗ nào phải sửa, vì cú pháp gọi y hệt.
  ///
  /// Đánh đổi: các widget không tự vẽ lại khi cờ đổi. Bên gọi [datBanToi] phải
  /// dựng lại từ gốc cây — `_EcAppState` làm đúng thế qua `setState`.
  static bool _toi = false;

  static bool get dangToi => _toi;

  /// Bật/tắt bảng màu tối. Trả `true` nếu có đổi thật (bên gọi dựng lại cây).
  static bool datBanToi({required bool toi}) {
    if (_toi == toi) return false;
    _toi = toi;
    return true;
  }

  // ── Neutrals ──────────────────────────────────────────────────────────────

  /// `--foreground` — primary text, active nav & icons.
  static Color get ink =>
      _toi ? const Color(0xFFF5F1EF) : const Color(0xFF1B1412);

  /// `--muted-foreground` — secondary text, inactive nav, captions.
  static Color get mut =>
      _toi ? const Color(0xFFA49D99) : const Color(0xFF69615E);

  /// `--border` / `--input` — hairline borders & dividers. Always 1px.
  static Color get line =>
      _toi ? const Color(0xFF302B29) : const Color(0xFFE9E2DF);

  /// `--secondary` / `--muted` — soft fills: chips, badges, filled inputs.
  ///
  /// shadcn has no "soft tint" concept: a faint fill is grey, never a washed
  /// brand hue (design-dna-app.md §1). This is the biggest visual change from
  /// the old navy palette, and what makes the green read as expensive.
  static Color get soft =>
      _toi ? const Color(0xFF2C2521) : const Color(0xFFF7F2F0);

  /// `--background` — app background.
  static Color get bg =>
      _toi ? const Color(0xFF130E0C) : const Color(0xFFFEFBF9);

  /// `--card` / `--popover` — cards, list tiles, sheets, dropdowns.
  static Color get card =>
      _toi ? const Color(0xFF1D1714) : const Color(0xFFFFFFFF);

  /// `--accent` — hover / pressed / selected fill. **Grey, not a highlight
  /// hue** (law 3).
  static Color get accent =>
      _toi ? const Color(0xFF342C28) : const Color(0xFFF7F0ED);

  /// `--accent-foreground` — text on [accent]; reads as ink.
  static Color get accentForeground =>
      _toi ? const Color(0xFFF8F4F2) : const Color(0xFF16100D);

  /// `--secondary-foreground` — text on [soft].
  static Color get softForeground =>
      _toi ? const Color(0xFFF5F1EF) : const Color(0xFF27201D);

  // ── Primary (the only green that fills) ───────────────────────────────────

  /// `--primary` — primary buttons, links, switch-on, checkbox-checked.
  static Color get dark =>
      _toi ? const Color(0xFFFF814C) : const Color(0xFFD34500);

  /// `--primary-foreground` — text/icons drawn on [dark].
  static Color get onDark =>
      _toi ? const Color(0xFF130E0C) : const Color(0xFFFCFCFC);

  /// `--ring` — focus ring only. Deliberately **lighter** than [dark].
  /// Never use as a fill (law 2).
  static Color get ring =>
      _toi ? const Color(0xFFEF774B) : const Color(0xFFEE5D2B);

  // ── Destructive ───────────────────────────────────────────────────────────

  /// `--destructive` — REC indicator, delete, errors. Text on it is always
  /// white.
  static Color get rec =>
      _toi ? const Color(0xFFF3606D) : const Color(0xFFCC2443);

  /// `--destructive-foreground`.
  static Color get onRec =>
      _toi ? const Color(0xFF130E0C) : const Color(0xFFFFFFFF);

  /// `bg-destructive/10` flattened over [bg] — faint error surfaces.
  static Color get recTint =>
      _toi ? const Color(0xFF2A1616) : const Color(0xFFF9E5E7);

  // ── Warning (the one sanctioned extension; reuses `--chart-4`) ────────────

  /// `--warning` — "quota almost gone" style cautions. There is deliberately
  /// no `--success` (use [dark] + a check icon) and no `--info` (use [soft]).
  static Color get warning =>
      _toi ? const Color(0xFFEBB353) : const Color(0xFF9F6200);

  /// `--warning-foreground`.
  static Color get onWarning =>
      _toi ? const Color(0xFF130E0C) : const Color(0xFFFFFFFF);

  /// `bg-warning/10` flattened over [bg].
  static Color get warningTint =>
      _toi ? const Color(0xFF291F13) : const Color(0xFFF5ECE0);

  // ── Trạng thái (console `--state-*`, 18/09) ─────────────────────────────
  /// `--state-done` — xanh "xong": đã ký, đã tải lên. Trạng thái, không phải
  /// thương hiệu; từ bộ cam-trắng, xanh lá chỉ còn vai này.
  static Color get success =>
      _toi ? const Color(0xFF6EBF8C) : const Color(0xFF2A7449);

  /// `--state-progress` — xanh dương "đang": đang ký, đang tải.
  static Color get progress =>
      _toi ? const Color(0xFF79B0E8) : const Color(0xFF316CA5);

  // ── Tab bar / rail surface ────────────────────────────────────────────────

  /// `--sidebar` — bottom tab bar. Offset from [bg] so it reads as its own
  /// surface.
  static Color get sidebar =>
      _toi ? const Color(0xFF181210) : const Color(0xFFFFFFFF);

  /// `--sidebar-accent` — the **selected** nav item. Cam rất nhạt (console
  /// 09/2026); chữ trên nó là [sidebarAccentForeground] cam đậm.
  static Color get sidebarAccent =>
      _toi ? const Color(0xFF3F271D) : const Color(0xFFFFF3EA);

  /// `--sidebar-accent-foreground`.
  static Color get sidebarAccentForeground =>
      _toi ? const Color(0xFFFFB48B) : const Color(0xFFC33400);

  // ── Charts ────────────────────────────────────────────────────────────────

  /// `--chart-1..5` — three steps of orange, then teal and blue.
  /// The only sanctioned multi-hue ramp in the system.
  static Color get chart1 =>
      _toi ? const Color(0xFFFF814C) : const Color(0xFFD34500);
  static Color get chart2 =>
      _toi ? const Color(0xFFDA6438) : const Color(0xFFEE5D2B);
  static Color get chart3 =>
      _toi ? const Color(0xFFFFB589) : const Color(0xFFFA9D6B);
  static Color get chart4 =>
      _toi ? const Color(0xFF56B6BB) : const Color(0xFF3B8F93);
  static Color get chart5 =>
      _toi ? const Color(0xFF6DA3DA) : const Color(0xFF386695);

  /// Distinguishable label colours for user-chosen video types.
  ///
  /// Drawn from the closed palette only (chart ramp + destructive + ink) —
  /// a picker may not invent hues outside the system (law 4).
  static List<Color> get labelRamp => <Color>[
    dark,
    chart3,
    chart4,
    chart5,
    rec,
    ink,
  ];

  // ── Sanctioned exceptions (design-dna-app.md §1) ──────────────────────────
  // Marketplace colors for shop badges (1 shop = 1 gian hàng trên 1 sàn).
  // These ship as platform identity, NOT as UI chrome: never use one to paint
  // a selected/hover state — that is law 3's job, and it is grey.
  static const shopee = Color(0xFFEE4D2D);
  static const tiktok = Color(0xFF161823);
  static const lazada = Color(0xFF0F146D);
  static const tiki = Color(0xFF1A94FF);

  /// The accent color for a marketplace platform id, or [mut] if unknown.
  static Color platform(String p) => switch (p) {
    'shopee' => shopee,
    'tiktok' => tiktok,
    'lazada' => lazada,
    'tiki' => tiki,
    _ => mut,
  };
}
