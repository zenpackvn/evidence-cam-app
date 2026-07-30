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
///  1. Neutrals are pure grey (OKLCH chroma 0) — never tinted.
///  2. [dark] (`--primary` `#16522C`) is the only green that fills anything.
///     The brighter [ring] `#1F9047` is a focus ring / chart colour only.
///  3. Hover / active / selected read as **ink**, not brand — see [accent] and
///     [sidebarAccent], which are grey.
///  4. The palette is closed at five groups: neutral · primary · destructive ·
///     chart · warning. There is no sixth.
abstract final class BrandColors {
  // ── Neutrals ──────────────────────────────────────────────────────────────

  /// `--foreground` — primary text, active nav & icons.
  static const ink = Color(0xFF161616);

  /// `--muted-foreground` — secondary text, inactive nav, captions.
  static const mut = Color(0xFF636363);

  /// `--border` / `--input` — hairline borders & dividers. Always 1px.
  static const line = Color(0xFFE4E4E4);

  /// `--secondary` / `--muted` — soft fills: chips, badges, filled inputs.
  ///
  /// shadcn has no "soft tint" concept: a faint fill is grey, never a washed
  /// brand hue (design-dna-app.md §1). This is the biggest visual change from
  /// the old navy palette, and what makes the green read as expensive.
  static const soft = Color(0xFFF3F3F3);

  /// `--background` — app background.
  static const bg = Color(0xFFFCFCFC);

  /// `--card` / `--popover` — cards, list tiles, sheets, dropdowns.
  static const card = Color(0xFFFFFFFF);

  /// `--accent` — hover / pressed / selected fill. **Grey, not a highlight
  /// hue** (law 3).
  static const accent = Color(0xFFF2F2F2);

  /// `--accent-foreground` — text on [accent]; reads as ink.
  static const accentForeground = Color(0xFF121212);

  /// `--secondary-foreground` — text on [soft].
  static const softForeground = Color(0xFF222222);

  // ── Primary (the only green that fills) ───────────────────────────────────

  /// `--primary` — primary buttons, links, switch-on, checkbox-checked.
  static const dark = Color(0xFF16522C);

  /// `--primary-foreground` — text/icons drawn on [dark].
  static const onDark = Color(0xFFFCFCFC);

  /// `--ring` — focus ring only. Deliberately **lighter** than [dark].
  /// Never use as a fill (law 2).
  static const ring = Color(0xFF1F9047);

  // ── Destructive ───────────────────────────────────────────────────────────

  /// `--destructive` — REC indicator, delete, errors. Text on it is always
  /// white.
  static const rec = Color(0xFFD02D27);

  /// `--destructive-foreground`.
  static const onRec = Color(0xFFFFFFFF);

  /// `bg-destructive/10` flattened over [bg] — faint error surfaces.
  static const recTint = Color(0xFFF8E7E7);

  // ── Warning (the one sanctioned extension; reuses `--chart-4`) ────────────

  /// `--warning` — "quota almost gone" style cautions. There is deliberately
  /// no `--success` (use [dark] + a check icon) and no `--info` (use [soft]).
  static const warning = Color(0xFFB6770B);

  /// `--warning-foreground`.
  static const onWarning = Color(0xFFFFFFFF);

  /// `bg-warning/10` flattened over [bg].
  static const warningTint = Color(0xFFF5EFE4);

  // ── Tab bar / rail surface ────────────────────────────────────────────────

  /// `--sidebar` — bottom tab bar. Offset from [bg] so it reads as its own
  /// surface.
  static const sidebar = Color(0xFFF7F7F7);

  /// `--sidebar-accent` — the **selected** nav item. Grey, not green (law 3).
  static const sidebarAccent = Color(0xFFEDEDED);

  /// `--sidebar-accent-foreground`.
  static const sidebarAccentForeground = Color(0xFF121212);

  // ── Charts ────────────────────────────────────────────────────────────────

  /// `--chart-1..5` — three steps of green, then amber and blue.
  /// The only sanctioned multi-hue ramp in the system.
  static const chart1 = Color(0xFF16522C);
  static const chart2 = Color(0xFF1F9047);
  static const chart3 = Color(0xFF67BB75);
  static const chart4 = Color(0xFFB6770B);
  static const chart5 = Color(0xFF2266A4);

  /// Distinguishable label colours for user-chosen video types.
  ///
  /// Drawn from the closed palette only (chart ramp + destructive + ink) —
  /// a picker may not invent hues outside the system (law 4).
  static const labelRamp = <Color>[dark, chart3, chart4, chart5, rec, ink];

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
