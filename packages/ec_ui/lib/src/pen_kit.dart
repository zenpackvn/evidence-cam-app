/// The components the Pencil design file repeats across screens, built once at
/// the design's own pixel values.
///
/// The generated screens under `src/gen/` are the literal transcription of the
/// design file and stay static; these are the live counterparts the feature
/// packages compose — same geometry, plus text, controllers and callbacks.
/// Every number here is lifted from `pencil-app-dna.pen`; change the design
/// file first, then this.
library;

import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Image;
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'core.dart';
import 'pen.dart';

/// The design file's palette, by the role each colour plays in it.
abstract final class PenColors {
  /// `--background` — every screen's fill.
  static const bg = Color(0xFFFCFCFC);

  /// `--card` / `--popover` — cards, fields, sheets.
  static const card = Color(0xFFFFFFFF);

  /// `--foreground` — primary text and icons.
  static const ink = Color(0xFF161616);

  /// `--muted-foreground` — labels, placeholders, captions.
  static const mut = Color(0xFF636363);

  /// `--border` — every 1px hairline.
  static const line = Color(0xFFE4E4E4);

  /// `--secondary` / `--muted` — soft grey fills and decorative shapes.
  static const soft = Color(0xFFF3F3F3);

  /// `--sidebar-accent` — the selected chip / nav item.
  static const selected = Color(0xFFEDEDED);

  /// `--primary` — the only green that fills: primary buttons.
  static const primary = Color(0xFF16522C);

  /// `--chart-2` — the lighter green, used for success text only.
  static const success = Color(0xFF1F9047);

  /// Links and link-like labels. `--primary`, same green as the primary
  /// button: design-dna law 2 puts links in `--primary`, and `--chart-5` blue
  /// is chart-only — the design file no longer uses `#2266A4` anywhere.
  static const link = Color(0xFF16522C);

  /// `--destructive` — REC, delete, errors.
  static const danger = Color(0xFFD02D27);

  /// `--warning` / `--chart-4` — the amber of "chờ tải" counts.
  static const warning = Color(0xFFB6770B);
}

/// Drop shadow the design file puts on raised cards.
const penCardShadow = BoxShadow(
  color: Color(0x12161616),
  offset: Offset(0, 2),
  blurRadius: 12,
);

/// Shadow of a card that overlaps [PenBrandBanner] — tinted with the banner's
/// own dark green instead of ink so the card reads as lifted off the green.
const penBrandCardShadow = BoxShadow(
  color: Color(0x290F3D20),
  offset: Offset(0, 4),
  blurRadius: 14,
);

/// The brand banner the two root tabs (Vận đơn, Tài khoản) open with: a dark
/// green gradient bleeding to the screen edges, rounded off at the bottom, with
/// the header and the first card sitting on top of it.
///
/// [height] is measured from the top of the *content* area; the banner itself
/// also fills the status bar behind it, so pass the design's height and let the
/// widget add the inset.
class PenBrandBanner extends StatelessWidget {
  const PenBrandBanner({required this.height, super.key});

  final double height;

  /// ponytail: `pen2dart.py` drops the gradient's angle, so this is Flutter's
  /// default left→right ramp. Two stops this close in hue barely read as a
  /// direction; set `begin`/`end` here if the design file says otherwise.
  static const gradient = LinearGradient(
    colors: [Color(0xFF0F3D20), Color(0xFF1F6B39)],
  );

  @override
  Widget build(BuildContext context) {
    return PenBox(
      width: double.infinity,
      height: MediaQuery.paddingOf(context).top + height,
      gradient: gradient,
      // The design rounds all four corners (its artboard is a device frame);
      // full-bleed on a real screen only the bottom two are visible.
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(26)),
    );
  }
}

/// Screen chrome: the background fill plus a scroll view that keeps the
/// design's layout intact on shorter devices instead of overflowing.
class PenScreen extends StatelessWidget {
  const PenScreen({
    required this.child,
    this.background = PenColors.bg,
    this.decorations = const <Widget>[],
    this.bottomBar,
    this.scrollable = true,
    super.key,
  });

  final Widget child;
  final Color background;

  /// Absolutely-placed artwork drawn behind [child].
  final List<Widget> decorations;
  final Widget? bottomBar;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    Widget body = child;
    if (scrollable) {
      // No `IntrinsicHeight` here: it under-measures wrapped text and clips
      // the tail of a long screen. Screens that need a flexible spacer pass
      // `scrollable: false` and lay themselves out against the viewport.
      body = LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: child,
          ),
        ),
      );
    }
    return CupertinoPageScaffold(
      backgroundColor: background,
      child: Stack(
        children: [
          ...decorations,
          SafeArea(
            bottom: bottomBar == null,
            child: bottomBar == null
                ? body
                : Column(
                    children: [
                      Expanded(child: body),
                      bottomBar!,
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// Primary action: 62px tall, 14px radius, `--primary` fill, 18/700 label.
class PenPrimaryButton extends StatelessWidget {
  const PenPrimaryButton({
    required this.label,
    this.icon,
    this.onPressed,
    this.height = 62,
    this.color = PenColors.primary,
    this.labelSize = 18,
    super.key,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double height;

  /// Label point size — 18 everywhere except the splash's 20pt "Bắt đầu".
  final double labelSize;

  /// Fill color — defaults to the brand green; pass [PenColors.danger] for a
  /// destructive primary action (e.g. "Xóa vĩnh viễn").
  final Color color;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return EcTap(
      onTap: onPressed,
      child: PenBox(
        width: double.infinity,
        height: height,
        fill: enabled ? color : color.withValues(alpha: 0.4),
        radius: 14,
        axis: PenAxis.row,
        gap: 12,
        main: MainAxisAlignment.center,
        cross: CrossAxisAlignment.center,
        children: [
          if (icon != null) Icon(icon, size: 21, color: PenColors.card),
          Flexible(
            child: PenText(
              label,
              size: labelSize,
              color: PenColors.card,
              weight: FontWeight.w700,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Secondary action: same box, white fill and a hairline border.
class PenOutlineButton extends StatelessWidget {
  const PenOutlineButton({
    required this.label,
    this.icon,
    this.onPressed,
    this.height = 60,
    super.key,
  });

  final String label;
  final Widget? icon;
  final VoidCallback? onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return EcTap(
      onTap: onPressed,
      child: PenBox(
        width: double.infinity,
        height: height,
        fill: PenColors.card,
        stroke: PenColors.line,
        radius: 14,
        axis: PenAxis.row,
        gap: 12,
        main: MainAxisAlignment.center,
        cross: CrossAxisAlignment.center,
        children: [
          if (icon != null) icon!,
          Flexible(
            child: PenText(
              label,
              size: 16,
              color: PenColors.ink,
              weight: FontWeight.w600,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Labelled input: 14/600 label, then a 60px field with a leading lucide icon
/// and an optional trailing one. Registers with the enclosing [Form] when a
/// [validator] is given and shows its error underneath.
class PenField extends StatefulWidget {
  const PenField({
    required this.icon,
    required this.hint,
    this.label,
    this.controller,
    this.obscure = false,
    this.keyboardType,
    this.validator,
    this.readOnly = false,
    super.key,
  });

  final IconData icon;
  final String hint;
  final String? label;
  final TextEditingController? controller;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool readOnly;

  @override
  State<PenField> createState() => _PenFieldState();
}

class _PenFieldState extends State<PenField> {
  late bool _obscure = widget.obscure;

  @override
  Widget build(BuildContext context) {
    if (widget.validator == null) return _build(null);
    return FormField<String>(
      initialValue: widget.controller?.text ?? '',
      // Chấm theo text sống của controller: chữ điền sẵn bằng code (email/mật
      // khẩu lấy từ keychain sau khi màn đã dựng) không bắn `onChanged`, nên
      // giá trị trong FormField vẫn rỗng và validator báo "chưa nhập" dù ô
      // đang hiện đầy chữ.
      validator: (value) => widget.validator!(widget.controller?.text ?? value),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: _build,
    );
  }

  Widget _build(FormFieldState<String>? state) {
    final error = state?.errorText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.label != null) ...[
          PenText(
            widget.label!,
            size: 14,
            color: PenColors.ink,
            weight: FontWeight.w600,
          ),
          const SizedBox(height: 8),
        ],
        PenBox(
          width: double.infinity,
          height: 60,
          fill: PenColors.card,
          stroke: error == null ? PenColors.line : PenColors.danger,
          radius: 14,
          axis: PenAxis.row,
          gap: 13,
          cross: CrossAxisAlignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          children: [
            Icon(widget.icon, size: 21, color: PenColors.ink),
            Expanded(
              child: CupertinoTextField(
                controller: widget.controller,
                onChanged: state?.didChange,
                obscureText: _obscure,
                readOnly: widget.readOnly,
                keyboardType: widget.keyboardType,
                padding: EdgeInsets.zero,
                decoration: const BoxDecoration(),
                placeholder: widget.hint,
                style: const TextStyle(fontSize: 14, color: PenColors.ink),
                placeholderStyle: const TextStyle(
                  fontSize: 14,
                  color: PenColors.mut,
                ),
              ),
            ),
            if (widget.obscure)
              EcTap(
                onTap: () => setState(() => _obscure = !_obscure),
                child: Icon(
                  // The design draws the *action*, not the state: an open
                  // eye offers "reveal" while the text is hidden.
                  _obscure ? LucideIcons.eye : LucideIcons.eyeOff,
                  size: 21,
                  color: PenColors.ink,
                ),
              ),
          ],
        ),
        if (error != null) ...[
          const SizedBox(height: 6),
          PenText(error, size: 12, color: PenColors.danger),
        ],
      ],
    );
  }
}

/// The register screen's field variant: the label lives *inside* the box,
/// stacked above the value, next to a leading lucide icon.
class PenStackedField extends StatefulWidget {
  const PenStackedField({
    required this.icon,
    required this.label,
    this.controller,
    this.obscure = false,
    this.keyboardType,
    this.validator,
    super.key,
  });

  final IconData icon;
  final String label;
  final TextEditingController? controller;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  State<PenStackedField> createState() => _PenStackedFieldState();
}

class _PenStackedFieldState extends State<PenStackedField> {
  late bool _obscure = widget.obscure;

  /// The design only stacks label-over-value once the field has content; an
  /// empty field is a single placeholder line. That needs the text to be
  /// observable, so an uncontrolled field still gets a controller.
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => widget.validator == null
          ? _build(null)
          : FormField<String>(
              initialValue: _controller.text,
              // Same as PenField: text set from code never reaches the
              // FormField, so validate the controller itself.
              validator: (value) => widget.validator!(_controller.text),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              builder: _build,
            ),
    );
  }

  Widget _build(FormFieldState<String>? state) {
    final error = state?.errorText;
    final isEmpty = _controller.text.isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PenBox(
          width: double.infinity,
          fill: PenColors.card,
          stroke: error == null ? PenColors.line : PenColors.danger,
          radius: 14,
          axis: PenAxis.row,
          gap: 14,
          cross: CrossAxisAlignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
          children: [
            Icon(widget.icon, size: 21, color: PenColors.ink),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isEmpty) ...[
                    PenText(widget.label, size: 12, color: PenColors.mut),
                    const SizedBox(height: 2),
                  ],
                  CupertinoTextField(
                    controller: _controller,
                    onChanged: state?.didChange,
                    obscureText: _obscure,
                    keyboardType: widget.keyboardType,
                    padding: EdgeInsets.zero,
                    decoration: const BoxDecoration(),
                    placeholder: widget.label,
                    placeholderStyle: const TextStyle(
                      fontSize: 14,
                      color: PenColors.mut,
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: PenColors.ink,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.obscure)
              EcTap(
                onTap: () => setState(() => _obscure = !_obscure),
                child: Icon(
                  _obscure ? LucideIcons.eye : LucideIcons.eyeOff,
                  size: 20,
                  color: PenColors.mut,
                ),
              ),
          ],
        ),
        if (error != null) ...[
          const SizedBox(height: 6),
          PenText(error, size: 12, color: PenColors.danger),
        ],
      ],
    );
  }
}

/// 24px square checkbox: ink fill and a white tick when checked.
class PenCheckbox extends StatelessWidget {
  const PenCheckbox({required this.checked, this.onChanged, super.key});

  final bool checked;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return EcTap(
      onTap: onChanged == null ? null : () => onChanged!(!checked),
      child: PenBox(
        width: 24,
        height: 24,
        fill: checked ? PenColors.ink : PenColors.card,
        stroke: checked ? null : PenColors.line,
        radius: 6,
        axis: PenAxis.row,
        main: MainAxisAlignment.center,
        cross: CrossAxisAlignment.center,
        children: [
          if (checked)
            const Icon(LucideIcons.check, size: 15, color: PenColors.card),
        ],
      ),
    );
  }
}

/// The rounded language pill pinned to the top-right of the entry screens.
class PenLangPill extends StatelessWidget {
  const PenLangPill({required this.label, this.onTap, super.key});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return EcTap(
      onTap: onTap,
      child: PenBox(
        fill: PenColors.card,
        stroke: PenColors.line,
        radius: 999,
        axis: PenAxis.row,
        gap: 6,
        cross: CrossAxisAlignment.center,
        hugMain: true,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        children: [
          const Icon(LucideIcons.globe, size: 16, color: PenColors.ink),
          PenText(
            label,
            size: 14,
            color: PenColors.ink,
            weight: FontWeight.w700,
            softWrap: false,
          ),
          const Icon(LucideIcons.chevronDown, size: 14, color: PenColors.mut),
        ],
      ),
    );
  }
}

/// Logo, wordmark, sparkle rule and the screen's title/subtitle — the header
/// the login and register screens share.
class PenBrandHeader extends StatelessWidget {
  const PenBrandHeader({
    required this.title,
    this.subtitle,
    this.logoSize = 40,
    super.key,
  });

  final String title;
  final String? subtitle;
  final double logoSize;

  @override
  Widget build(BuildContext context) {
    // `BrandHeader` (gap 3) then `Title` (padding-top 12, gap 4) — the same
    // block opens F1-02, F1-03 and F1-04.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/design/logo.png',
          package: 'ec_ui',
          width: logoSize,
          height: logoSize,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 3),
        PenText(
          'ZenPack',
          size: 18,
          color: PenColors.primary,
          weight: FontWeight.w800,
          softWrap: false,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 9),
          child: PenOrnamentRule(),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            children: [
              PenText(
                title,
                size: 30,
                color: PenColors.primary,
                weight: FontWeight.w800,
                align: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                PenText(
                  subtitle!,
                  size: 14,
                  color: PenColors.mut,
                  align: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Hairline — sparkle — hairline.
class PenOrnamentRule extends StatelessWidget {
  const PenOrnamentRule({
    this.lineWidth = 44,
    this.gap = 8,
    this.sparkleSize = 10,
    super.key,
  });

  /// Each hairline's width — 44 in the auth headers, 78 on the splash.
  final double lineWidth;
  final double gap;
  final double sparkleSize;

  static const _sparkle =
      'M7 0l1.6 5.4 5.4 1.6-5.4 1.6-1.6 5.4-1.6-5.4-5.4-1.6 5.4-1.6z';

  @override
  Widget build(BuildContext context) {
    return PenBox(
      axis: PenAxis.row,
      gap: gap,
      main: MainAxisAlignment.center,
      cross: CrossAxisAlignment.center,
      hugMain: true,
      children: [
        PenBox(width: lineWidth, height: 1, fill: PenColors.soft),
        PenPath(
          _sparkle,
          viewBox: const [0, 0, 14, 14],
          width: sparkleSize,
          height: sparkleSize,
          color: PenColors.line,
        ),
        PenBox(width: lineWidth, height: 1, fill: PenColors.soft),
      ],
    );
  }
}

/// Hairline — label — hairline, the "hoặc" separator above the social buttons.
class PenLabelledRule extends StatelessWidget {
  const PenLabelledRule(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return PenBox(
      width: double.infinity,
      axis: PenAxis.row,
      gap: 12,
      cross: CrossAxisAlignment.center,
      padding: const EdgeInsets.symmetric(vertical: 4),
      children: [
        const Expanded(child: PenBox(height: 1, fill: PenColors.line)),
        PenText(label, size: 14, color: PenColors.mut, softWrap: false),
        const Expanded(child: PenBox(height: 1, fill: PenColors.line)),
      ],
    );
  }
}

/// "Bạn chưa có tài khoản? **Đăng ký**" — muted prompt plus a blue action.
class PenPromptLink extends StatelessWidget {
  const PenPromptLink({
    required this.prompt,
    required this.action,
    this.onTap,
    super.key,
  });

  final String prompt;
  final String action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: PenText(
            prompt,
            size: 14,
            color: PenColors.mut,
            align: TextAlign.center,
          ),
        ),
        const SizedBox(width: 6),
        EcTap(
          onTap: onTap,
          child: PenText(
            action,
            size: 14,
            color: PenColors.link,
            weight: FontWeight.w700,
            softWrap: false,
          ),
        ),
      ],
    );
  }
}

/// Blue text action (the "Quên mật khẩu?" / "Thử lại" style link).
class PenLink extends StatelessWidget {
  const PenLink(this.label, {this.onTap, this.size = 14, super.key});

  final String label;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return EcTap(
      onTap: onTap,
      child: PenText(
        label,
        size: size,
        color: PenColors.link,
        weight: FontWeight.w600,
        softWrap: false,
      ),
    );
  }
}

/// Back chevron, 26px, as every pushed screen in the design draws it.
class PenBackButton extends StatelessWidget {
  const PenBackButton({
    this.onTap,
    this.size = 26,
    this.color = PenColors.ink,
    super.key,
  });

  final VoidCallback? onTap;
  final double size;

  /// White on the screens whose header sits on [PenBrandBanner].
  final Color color;

  @override
  Widget build(BuildContext context) {
    return EcTap(
      onTap: onTap,
      child: Icon(LucideIcons.chevronLeft, size: size, color: color),
    );
  }
}

/// The order-row leading tile: the poster frame of the order's latest clip
/// (F2-01's "ảnh overview"), with the marketplace the order came from badged
/// on its corner. Falls back to the parcel glyph until a poster exists — an
/// order whose first clip is still uploading has no frame to show yet.
class PenOrderThumb extends StatelessWidget {
  const PenOrderThumb({
    this.imageUrl,
    this.platform,
    this.size = 56,
    super.key,
  });

  /// Remote poster URL. `null` (or a load failure) shows the parcel glyph.
  final String? imageUrl;

  /// Marketplace id (`shopee`, `tiktok`, …); omit to drop the badge.
  final String? platform;
  final double size;

  static const _badge = 23.0;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          PenBox(
            width: size,
            height: size,
            fill: PenColors.bg,
            stroke: const Color(0x14000000),
            radius: 12,
            clip: true,
            axis: PenAxis.row,
            main: MainAxisAlignment.center,
            cross: CrossAxisAlignment.center,
            children: [
              if (url == null || url.isEmpty)
                PenParcelGlyph(size: size * 34 / 52)
              else
                SizedBox.expand(
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        Center(child: PenParcelGlyph(size: size * 34 / 52)),
                  ),
                ),
            ],
          ),
          if (platform != null)
            Positioned(
              right: 0,
              bottom: 0,
              child: PenBox(
                width: _badge,
                height: _badge,
                fill: PenColors.card,
                stroke: const Color(0x14000000),
                radius: 999,
                axis: PenAxis.row,
                main: MainAxisAlignment.center,
                cross: CrossAxisAlignment.center,
                children: [PenPlatforms.logo(platform!, size: 15)],
              ),
            ),
        ],
      ),
    );
  }
}

/// The isometric parcel glyph the design draws inside order-row tiles.
class PenParcelGlyph extends StatelessWidget {
  const PenParcelGlyph({this.size = 34, super.key});

  final double size;

  static const _top = 'M15 0l15 7.5-15 7.5-15-7.5z';
  static const _tapeA = 'M9.6 2.7l15 7.5-4.2 2.1-15-7.5z';
  static const _tapeB = 'M20.4 2.7l4.2 2.1-15 7.5-4.2-2.1z';
  static const _left = 'M0 0l15 7.5 0 14.5-15-7.5z';
  static const _right = 'M15 0l0 14.5-15 7.5 0-14.5z';

  @override
  Widget build(BuildContext context) {
    final k = size / 34;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          for (final d in const [_top, _tapeA, _tapeB])
            Positioned(
              left: 2 * k,
              top: 4 * k,
              child: PenPath(
                d,
                viewBox: const [0, 0, 30, 15],
                width: 30 * k,
                height: 15 * k,
                color: PenColors.soft,
              ),
            ),
          Positioned(
            left: 2 * k,
            top: 11.5 * k,
            child: PenPath(
              _left,
              viewBox: const [0, 0, 15, 22],
              width: 15 * k,
              height: 22 * k,
              color: PenColors.mut,
            ),
          ),
          Positioned(
            left: 17 * k,
            top: 11.5 * k,
            child: PenPath(
              _right,
              viewBox: const [0, 0, 15, 22],
              width: 15 * k,
              height: 22 * k,
              color: PenColors.mut,
            ),
          ),
        ],
      ),
    );
  }
}

/// The three-tab bar: 92pt tall, top-rounded, active tab in ink with an
/// underline, the rest muted.
class PenTabBar extends StatelessWidget {
  const PenTabBar({required this.activeIndex, required this.tabs, super.key});

  final int activeIndex;

  /// Icon + label per tab, plus what to do when it is tapped.
  final List<(IconData, String, VoidCallback?)> tabs;

  @override
  Widget build(BuildContext context) {
    return PenBox(
      width: double.infinity,
      height: 92,
      fill: PenColors.card,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      axis: PenAxis.row,
      padding: const EdgeInsets.fromLTRB(10, 16, 10, 0),
      children: [
        for (var i = 0; i < tabs.length; i++)
          Expanded(
            child: _Tab(
              icon: tabs[i].$1,
              label: tabs[i].$2,
              active: i == activeIndex,
              onTap: tabs[i].$3,
            ),
          ),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.icon,
    required this.label,
    required this.active,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Tab đang chọn chỉ khác nhau ở **màu** — xanh lá thương hiệu
    // (`--primary`), theo yêu cầu của người dùng, cố ý lệch khung design (bản
    // vẽ tô đen). Gạch chân 34×3 và chữ w700 làm cột active cao và rộng hơn
    // hàng xóm, kéo icon nhích lên ~5px so với các tab còn lại nên không dùng.
    final color = active ? PenColors.primary : PenColors.mut;
    return EcTap(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 25, color: color),
          const SizedBox(height: 7),
          PenText(
            label,
            size: 14,
            color: color,
            weight: FontWeight.w500,
            softWrap: false,
          ),
        ],
      ),
    );
  }
}

/// A rounded filter pill. An applied filter reads as an ink fill with a white
/// label; an unset one is a hairline outline — never a brand tint (law 3 of the
/// design DNA).
class PenChip extends StatelessWidget {
  const PenChip({
    required this.label,
    required this.selected,
    this.trailing,
    this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final IconData? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ink = selected ? PenColors.card : PenColors.ink;
    return EcTap(
      onTap: onTap,
      child: PenBox(
        fill: selected ? PenColors.ink : PenColors.bg,
        stroke: selected ? null : PenColors.line,
        radius: 999,
        axis: PenAxis.row,
        gap: 7,
        cross: CrossAxisAlignment.center,
        hugMain: true,
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 18),
        children: [
          Flexible(
            child: PenText(
              label,
              size: 14,
              color: ink,
              weight: selected ? FontWeight.w600 : FontWeight.w500,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null)
            Icon(trailing, size: 16, color: selected ? ink : PenColors.mut),
        ],
      ),
    );
  }
}

/// A bottom sheet the design's way: dimmed backdrop, top-rounded white panel,
/// grabber, content. Tapping the backdrop — or dragging the panel down past
/// [_dismissDistance] (or flicking it) — pops the route.
class PenSheet extends StatefulWidget {
  const PenSheet({
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(22, 12, 22, 20),
    this.onDismiss,
    this.dim = const Color(0xA6636363),
    super.key,
  });

  final List<Widget> children;
  final EdgeInsets padding;

  /// What tapping the backdrop — or flinging the sheet down — does; defaults to
  /// popping the route.
  final VoidCallback? onDismiss;

  /// The design's `Dim` rect behind the sheet. Dialogs over a light screen use
  /// the default grey wash; sheets that need more separation (the video-detail
  /// sheet) darken with ink instead.
  final Color dim;

  @override
  State<PenSheet> createState() => _PenSheetState();
}

/// How far down the panel must be dragged, or how fast it must be flicked,
/// before letting go dismisses instead of snapping back.
const _dismissDistance = 90.0;
const _dismissVelocity = 700.0;

/// Phần phải bù thêm ở đáy sheet để nội dung không nằm dưới thanh home
/// indicator: chỉ khoảng còn thiếu so với padding đáy mà design đã có (và
/// `PenBox` đã nhân với `penDensityScale`), nên máy không khuyết vẫn giữ đúng
/// padding thiết kế.
double _bottomInset(BuildContext context, EdgeInsets padding) => math.max(
  0,
  MediaQuery.viewPaddingOf(context).bottom - padding.bottom * penDensityScale,
);

class _PenSheetState extends State<PenSheet> {
  double _dy = 0;
  bool _dragging = false;

  void _dismiss() =>
      (widget.onDismiss ?? () => Navigator.of(context).maybePop())();

  void _onDragEnd(DragEndDetails details) {
    if (_dy > _dismissDistance ||
        details.velocity.pixelsPerSecond.dy > _dismissVelocity) {
      _dismiss();
      return;
    }
    setState(() {
      _dragging = false;
      _dy = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _dismiss,
            child: ColoredBox(color: widget.dim),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
            // ponytail: cả tấm panel là vùng kéo. Scrollable bên trong (bánh xe
            // ngày, danh sách dài) vẫn thắng arena cử chỉ dọc vì nằm sâu hơn,
            // nên chưa cần tách riêng vùng grabber.
            onVerticalDragUpdate: (d) => setState(() {
              _dragging = true;
              _dy = math.max(0, _dy + d.delta.dy);
            }),
            onVerticalDragEnd: _onDragEnd,
            onVerticalDragCancel: () => setState(() {
              _dragging = false;
              _dy = 0;
            }),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: _dy),
              // Follow the finger 1:1 while dragging; ease back on release.
              duration: _dragging
                  ? Duration.zero
                  : const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              builder: (_, dy, child) =>
                  Transform.translate(offset: Offset(0, dy), child: child),
              child: PenBox(
                width: double.infinity,
                fill: PenColors.card,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                axis: PenAxis.column,
                hugMain: true,
                padding: widget.padding,
                children: [
                  const Center(
                    child: PenBox(
                      width: 46,
                      height: 5,
                      fill: PenColors.line,
                      radius: 3,
                    ),
                  ),
                  ...widget.children,
                  // Nâng nội dung khỏi thanh home indicator. Cộng thêm chứ
                  // không thay thế, và chỉ phần còn thiếu — bọc SafeArea *và*
                  // giữ padding đáy là cách sinh ra khoảng trắng thừa ở đuôi
                  // sheet.
                  SizedBox(height: _bottomInset(context, widget.padding)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A centred modal card, 300pt wide with a deep lift — the design's dialog.
class PenDialog extends StatelessWidget {
  const PenDialog({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).maybePop(),
            child: const ColoredBox(color: Color(0xA6636363)),
          ),
        ),
        Center(
          child: GestureDetector(
            onTap: () {},
            child: SingleChildScrollView(
              child: PenBox(
                width: 300,
                fill: PenColors.card,
                radius: 14,
                shadows: const [
                  BoxShadow(
                    color: Color(0x1F161616),
                    offset: Offset(0, 14),
                    blurRadius: 36,
                  ),
                ],
                axis: PenAxis.column,
                hugMain: true,
                cross: CrossAxisAlignment.center,
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                children: children,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A 48/56-tall dialog or sheet button. [primary] fills `--primary`.
class PenDialogButton extends StatelessWidget {
  const PenDialogButton({
    required this.label,
    required this.primary,
    this.onPressed,
    this.height = 48,
    this.radius = 10,
    super.key,
  });

  final String label;
  final bool primary;
  final VoidCallback? onPressed;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return EcTap(
      onTap: onPressed,
      child: PenBox(
        width: double.infinity,
        height: height,
        fill: primary ? PenColors.primary : PenColors.card,
        stroke: primary ? null : PenColors.line,
        radius: radius,
        axis: PenAxis.row,
        main: MainAxisAlignment.center,
        cross: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: PenText(
              label,
              size: 16,
              color: primary ? PenColors.card : PenColors.ink,
              weight: primary ? FontWeight.w700 : FontWeight.w600,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Marketplace artwork, keyed the way the backend names the platform.
abstract final class PenPlatforms {
  /// The official brand mark of each marketplace, as vector so it stays sharp
  /// at any tile size instead of the blurry raster the design file exported.
  ///
  /// Every file is normalised to the same `0 0 100 100` viewBox with the mark
  /// scaled to fit and centred, so a tall icon (Shopee's bag) and a wide
  /// wordmark (Lazada, Tiki) carry the same optical weight in a square tile.
  /// Re-normalise any logo you add — a tight-bbox export renders at its own
  /// aspect and reads far bigger than its neighbours.
  static const _logos = <String, String>{
    'shopee': 'shopee',
    'tiktok': 'tiktok',
    'lazada': 'lazada',
    'tiki': 'tiki',
  };

  /// Brand colours, shipped as inline values in the design (not tokens).
  static const brand = <String, Color>{
    'shopee': Color(0xFFEE4D2D),
    'tiktok': Color(0xFF161823),
    'lazada': Color(0xFF0F146D),
    'tiki': Color(0xFF1A94FF),
  };

  /// The platform's logo at [size], or the generic store icon for "Khác".
  static Widget logo(String platform, {double size = 30}) {
    final asset = _logos[platform.toLowerCase()];
    if (asset == null) {
      return Icon(LucideIcons.store, size: size * 0.9, color: PenColors.ink);
    }
    // The box has to come from outside: `SvgPicture` keeps the picture's own
    // aspect ratio, so an un-normalised wordmark would blow a tile's Row apart.
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.asset(
        'assets/design/platforms/$asset.svg',
        package: 'ec_ui',
        fit: BoxFit.contain,
      ),
    );
  }
}

/// The four marketplace logos fanned over a grey halo with a green flow line —
/// the hero the shop-selection screens open with.
class PenPlatformHero extends StatelessWidget {
  const PenPlatformHero({super.key});

  static const _flowLine = 'M0 0 C45 32 115 30 172 2';

  @override
  Widget build(BuildContext context) {
    // `PenScreen` draws decorations outside its `SafeArea`, so the design's
    // y-coordinates start at the physical top of the screen — on a notch or
    // Dynamic Island phone that swallows the tiles. Carry the status-bar inset
    // inside the hero so every call site keeps its design position.
    return IgnorePointer(
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
        child: const SizedBox(
          width: 292,
          height: 138,
          child: Stack(
            children: [
              Positioned(
                left: 61,
                top: 0,
                child: PenEllipse(
                  width: 170,
                  height: 118,
                  color: PenColors.soft,
                ),
              ),
              Positioned(left: 20, top: 34, child: _HeroTile('shopee', 62, 34)),
              Positioned(left: 82, top: 6, child: _HeroTile('tiktok', 64, 36)),
              Positioned(
                left: 146,
                top: 34,
                child: _HeroTile('lazada', 72, 44),
              ),
              Positioned(left: 218, top: 58, child: _HeroTile('tiki', 62, 44)),
              Positioned(
                left: 58,
                top: 91,
                child: PenPath(
                  _flowLine,
                  viewBox: [0, 0, 172, 34],
                  width: 172,
                  height: 34,
                  color: PenColors.success,
                  strokeWidth: 3,
                  roundCap: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroTile extends StatelessWidget {
  const _HeroTile(this.platform, this.box, this.logo);

  final String platform;
  final double box;
  final double logo;

  @override
  Widget build(BuildContext context) {
    return PenBox(
      width: box,
      height: box,
      fill: PenColors.card,
      stroke: PenColors.line,
      radius: 16,
      shadows: const [penCardShadow],
      axis: PenAxis.row,
      main: MainAxisAlignment.center,
      cross: CrossAxisAlignment.center,
      children: [PenPlatforms.logo(platform, size: logo)],
    );
  }
}

/// A white 14-radius card with the design's hairline and lift — the shell every
/// list row, panel and tile in this design sits in.
class PenCard extends StatelessWidget {
  const PenCard({
    required this.children,
    this.axis = PenAxis.row,
    this.gap = 0,
    this.padding = EdgeInsets.zero,
    this.fill = PenColors.card,
    this.stroke = PenColors.line,
    this.strokeWidth = 1,
    this.radius = 14,
    this.lifted = true,
    this.cross,
    this.main = MainAxisAlignment.start,
    this.onTap,
    this.clip = false,
    super.key,
  });

  final List<Widget> children;
  final PenAxis axis;
  final double gap;
  final EdgeInsets padding;
  final Color fill;
  final Color? stroke;
  final double strokeWidth;
  final double radius;
  final bool lifted;
  final CrossAxisAlignment? cross;
  final MainAxisAlignment main;
  final VoidCallback? onTap;
  final bool clip;

  @override
  Widget build(BuildContext context) {
    final card = PenBox(
      width: double.infinity,
      fill: fill,
      stroke: stroke,
      strokeWidth: strokeWidth,
      radius: radius,
      shadows: lifted ? const [penCardShadow] : const [],
      axis: axis,
      gap: gap,
      main: main,
      cross:
          cross ??
          (axis == PenAxis.row
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start),
      padding: padding,
      clip: clip,
      children: children,
    );
    return onTap == null ? card : EcTap(onTap: onTap, child: card);
  }
}

/// The 34px selection dot: a filled green tick when selected, a grey ring when
/// not. (`innerRadius: 0.88` in the design file.)
class PenRadio extends StatelessWidget {
  const PenRadio({required this.selected, this.size = 34, super.key});

  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (!selected) {
      return PenEllipse(
        width: size,
        height: size,
        color: PenColors.mut,
        ring: 0.88,
      );
    }
    return PenBox(
      width: size,
      height: size,
      fill: PenColors.success,
      radius: 999,
      axis: PenAxis.row,
      main: MainAxisAlignment.center,
      cross: CrossAxisAlignment.center,
      children: [
        Icon(LucideIcons.check, size: size * 0.56, color: PenColors.card),
      ],
    );
  }
}

/// Back chevron + screen title, the header every pushed screen opens with.
class PenHeader extends StatelessWidget {
  const PenHeader({
    required this.title,
    this.onBack,
    this.trailing,
    this.gap = 16,
    this.backSize = 28,
    super.key,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;
  final double gap;

  /// Back-chevron point size. The design file draws 28 on most screens but 26
  /// on flow 4's, and 2px shifts the whole title.
  final double backSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PenBackButton(onTap: onBack, size: backSize),
        SizedBox(width: gap),
        Expanded(
          child: PenText(
            title,
            size: 24,
            color: PenColors.ink,
            weight: FontWeight.w800,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// The globe-and-chips illustration the language screen sits under its
/// options: a haloed wireframe globe, VI/EN chips, a cloud and a leaf sprig.
class PenGlobeIllustration extends StatelessWidget {
  const PenGlobeIllustration({super.key});

  static const _cloud =
      'M14 40c-8 0-14-7-14-14 0-7 6-13 12-13 2-8 10-13 18-13 8 0 15 6 17 14 '
      '1 0 2-1 4-1 10 0 19 7 19 14 0 7-7 13-14 13z';

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: SizedBox(
        width: 300,
        height: 260,
        child: Stack(
          children: [
            Positioned(
              left: 65,
              top: 0,
              child: PenEllipse(width: 170, height: 170, color: PenColors.soft),
            ),
            Positioned(
              left: 94,
              top: 29,
              child: PenEllipse(
                width: 112,
                height: 112,
                color: PenColors.ink,
                ring: 0.9,
              ),
            ),
            Positioned(
              left: 100,
              top: 35,
              child: PenEllipse(width: 100, height: 100, color: PenColors.soft),
            ),
            Positioned(
              left: 127,
              top: 35,
              child: PenEllipse(
                width: 46,
                height: 100,
                color: PenColors.ink,
                ring: 0.94,
              ),
            ),
            Positioned(
              left: 105,
              top: 70,
              child: PenBox(
                width: 90,
                height: 4,
                fill: PenColors.ink,
                radius: 2,
              ),
            ),
            Positioned(
              left: 112,
              top: 100,
              child: PenBox(
                width: 76,
                height: 4,
                fill: PenColors.soft,
                radius: 2,
              ),
            ),
            Positioned(
              left: 217,
              top: 12,
              child: PenPath(
                _cloud,
                viewBox: [0, 0, 70, 40],
                width: 70,
                height: 40,
                color: PenColors.soft,
              ),
            ),
            Positioned(
              left: 51,
              top: 8,
              child: _LangChipDeco(label: 'VI', selected: true),
            ),
            // Right/bottom anchored like the design file: the chip hugs its
            // label, so pinning its far edges is what keeps it in place.
            Positioned(
              right: 97,
              bottom: 154,
              child: _LangChipDeco(label: 'EN', selected: false),
            ),
          ],
        ),
      ),
    );
  }
}

class _LangChipDeco extends StatelessWidget {
  const _LangChipDeco({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return PenBox(
      fill: selected ? PenColors.selected : PenColors.card,
      stroke: selected ? null : PenColors.soft,
      radius: 999,
      axis: PenAxis.row,
      hugMain: true,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      children: [
        PenText(
          label,
          size: 14,
          color: PenColors.ink,
          weight: FontWeight.w700,
          softWrap: false,
        ),
      ],
    );
  }
}

/// The grey leaf sprig the design pins to a screen corner. [flip] mirrors it
/// for the left/right variants.
class PenLeafSprig extends StatelessWidget {
  const PenLeafSprig({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: SizedBox(
        width: 66,
        height: 76,
        child: Stack(
          children: [
            Positioned(
              left: 8,
              top: 0,
              child: PenEllipse(
                width: 46,
                height: 20,
                color: PenColors.soft,
                rotation: -18,
              ),
            ),
            Positioned(
              left: 0,
              top: 22,
              child: PenEllipse(
                width: 50,
                height: 20,
                color: PenColors.soft,
                rotation: 8,
              ),
            ),
            Positioned(
              left: 16,
              top: 42,
              child: PenEllipse(
                width: 42,
                height: 18,
                color: PenColors.soft,
                rotation: 26,
              ),
            ),
            Positioned(
              left: 20,
              top: 6,
              child: PenBox(
                width: 3,
                height: 56,
                fill: PenColors.soft,
                radius: 2,
                rotation: -8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The isometric parcel-stack-and-shield sprite the register screen pins to
/// its top-right corner.
class PenParcelSprite extends StatelessWidget {
  const PenParcelSprite({super.key});

  static const _top0 = 'M32.55 0l32.55 15.75-32.55 15.75-32.55-15.75z';
  static const _left0 = 'M0 0l32.55 15.75 0 33.6-32.55-15.75z';
  static const _right0 = 'M32.55 0l0 33.6-32.55 15.75 0-33.6z';
  static const _top1 = 'M37.8 0l37.8 17.85-37.8 17.85-37.8-17.85z';
  static const _left1 = 'M0 0l37.8 17.85 0 37.8-37.8-17.85z';
  static const _right1 = 'M37.8 0l0 37.8-37.8 17.85 0-37.8z';
  static const _shield =
      'M21 0l21 7.3 0 17.7c0 12.5-9.5 20-21 23-11.5-3-21-10.5-21-23l0-17.7z';

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: SizedBox(
        width: 102,
        height: 132,
        child: Stack(
          children: [
            Positioned(
              left: 22,
              top: 0,
              child: PenPath(
                _top0,
                viewBox: [0, 0, 65.1, 31.5],
                width: 65.1,
                height: 31.5,
                color: PenColors.soft,
              ),
            ),
            Positioned(
              left: 22,
              top: 15.75,
              child: PenPath(
                _left0,
                viewBox: [0, 0, 32.55, 49.35],
                width: 32.55,
                height: 49.35,
                color: PenColors.mut,
              ),
            ),
            Positioned(
              left: 54.55,
              top: 15.75,
              child: PenPath(
                _right0,
                viewBox: [0, 0, 32.55, 49.35],
                width: 32.55,
                height: 49.35,
                color: PenColors.mut,
              ),
            ),
            Positioned(
              left: 0,
              top: 35.7,
              child: PenPath(
                _top1,
                viewBox: [0, 0, 75.6, 35.7],
                width: 75.6,
                height: 35.7,
                color: PenColors.soft,
              ),
            ),
            Positioned(
              left: 0,
              top: 53.55,
              child: PenPath(
                _left1,
                viewBox: [0, 0, 37.8, 55.65],
                width: 37.8,
                height: 55.65,
                color: PenColors.mut,
              ),
            ),
            Positioned(
              left: 37.8,
              top: 53.55,
              child: PenPath(
                _right1,
                viewBox: [0, 0, 37.8, 55.65],
                width: 37.8,
                height: 55.65,
                color: PenColors.mut,
              ),
            ),
            Positioned(
              left: 48.3,
              top: 60.9,
              child: PenPath(
                _shield,
                viewBox: [0, 0, 42, 48],
                width: 44.1,
                height: 50.4,
                color: PenColors.primary,
              ),
            ),
            Positioned(
              left: 60.9,
              top: 79.8,
              child: PenBox(
                width: 18.9,
                height: 15.75,
                fill: PenColors.soft,
                radius: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Google's four-colour "G", verbatim from the design file's `GoogleMark`.
class PenGoogleMark extends StatelessWidget {
  const PenGoogleMark({this.size = 22, super.key});

  final double size;

  static const _paths = <(String, Color)>[
    (
      'M45.12 24.5c0-1.56-0.14-3.06-0.4-4.5h-20.72v8.51h11.84c-0.51 2.75-2.06 '
          '5.08-4.39 6.64v5.52h7.11c4.16-3.83 6.56-9.47 6.56-16.17z',
      Color(0xFF4285F4),
    ),
    (
      'M24 46c5.94 0 10.92-1.97 14.56-5.33l-7.11-5.52c-1.97 1.32-4.49 2.1-7.45 '
          '2.1-5.73 0-10.58-3.87-12.31-9.07h-7.35v5.7c3.62 7.19 11.06 12.12 '
          '19.66 12.12z',
      Color(0xFF34A853),
    ),
    (
      'M11.69 28.18c-0.44-1.32-0.69-2.73-0.69-4.18s0.25-2.86 0.69-4.18v-5.7h'
          '-7.35c-1.49 2.97-2.34 6.33-2.34 9.88s0.85 6.91 2.34 9.88l7.35-5.7z',
      Color(0xFFFBBC05),
    ),
    (
      'M24 10.75c3.23 0 6.13 1.11 8.41 3.29l6.31-6.31c-3.81-3.55-8.79-5.73'
          '-14.72-5.73-8.6 0-16.04 4.93-19.66 12.12l7.35 5.7c1.73-5.2 6.58-9.07 '
          '12.31-9.07z',
      Color(0xFFEA4335),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          for (final (geometry, color) in _paths)
            PenPath(
              geometry,
              viewBox: const [0, 0, 48, 48],
              width: size,
              height: size,
              color: color,
            ),
        ],
      ),
    );
  }
}

/// Apple's mark, verbatim from the design file's `AppleMark`.
class PenAppleMark extends StatelessWidget {
  const PenAppleMark({this.height = 23, super.key});

  final double height;

  static const _geometry =
      'M788.1 340.9c-5.8 4.5-108.2 62.2-108.2 190.5 0 148.4 130.3 200.9 134.2 '
      '202.2-0.6 3.2-20.7 71.9-68.7 141.9-42.8 61.6-87.5 123.1-155.5 123.1-67.4 '
      '0-84.6-39.5-162.4-39.5-75.9 0-102.9 40.8-164.5 40.8-56.3 0-88.9-57-125.6'
      '-127.4-82.3-123.9-116.7-242-116.7-353.6 0-183.7 119.4-281 236.9-281 62.4 '
      '0 114.4 41 153.6 41 37.3 0 95.4-43.5 166.4-43.5 26.9 0 129.3 2.4 210.5 '
      '105.5z m-214-195.2c29.6-35.1 50.5-83.8 50.5-132.5 0-6.8-0.6-13.6-1.8'
      '-19.2-48.2 1.8-105.5 32.1-140 72.3-27 30.6-52.6 79.3-52.6 128.7 0 6.1 '
      '0.6 12.2 1.2 14.2 3.2 0.6 8.4 1.3 13.6 1.3 43.2 0 97.5-28.9 129.1-64.8z';

  @override
  Widget build(BuildContext context) {
    return PenPath(
      _geometry,
      viewBox: const [0, 0, 814, 1000],
      width: height * 814 / 1000,
      height: height,
      color: PenColors.ink,
    );
  }
}
