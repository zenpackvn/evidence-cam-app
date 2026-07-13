import 'dart:ui';

import 'package:flutter/painting.dart';

import 'stamp_draft.dart';

/// A named color filter (SM-006). [premium] gates 8 of the 16 behind Premium
/// (SM-006: 8 free / 8 locked). [category] groups them into the 4 design tabs.
class StampFilter {
  const StampFilter({
    required this.id,
    required this.label,
    required this.category,
    required this.matrix,
    this.premium = false,
  });

  final String id;
  final String label;
  final FilterCategory category;

  /// The 5x4 color matrix applied via [ColorFilter.matrix]. `null` for the
  /// original (no filter).
  final List<double>? matrix;
  final bool premium;
}

enum FilterCategory { classic, retro, mood, season }

/// The 16-filter catalog (SM-006 BR: 4 groups, 8 free + 8 premium). Matrices are
/// hand-tuned presets; the "Chỉnh tay" adjustments (SM-006) are layered on top
/// at render time via [adjustmentMatrix].
const stampFilters = <StampFilter>[
  StampFilter(
    id: StampDraft.kOriginalFilter,
    label: 'Gốc',
    category: FilterCategory.classic,
    matrix: null,
  ),
  // ── Classic (Cổ điển) ──────────────────────────────────────────────────
  StampFilter(
    id: 'mono',
    label: 'Đen trắng',
    category: FilterCategory.classic,
    matrix: _grayscale,
  ),
  StampFilter(
    id: 'sepia',
    label: 'Nâu cổ',
    category: FilterCategory.classic,
    matrix: _sepia,
  ),
  StampFilter(
    id: 'noir',
    label: 'Noir',
    category: FilterCategory.classic,
    matrix: _noir,
    premium: true,
  ),
  // ── Retro / Vintage ────────────────────────────────────────────────────
  StampFilter(
    id: 'film04',
    label: 'Film 04',
    category: FilterCategory.retro,
    matrix: _warmFade,
  ),
  StampFilter(
    id: 'film03',
    label: 'Film 03',
    category: FilterCategory.retro,
    matrix: _coolFade,
  ),
  StampFilter(
    id: 'film01',
    label: 'Film 01',
    category: FilterCategory.retro,
    matrix: _fadedBlue,
    premium: true,
  ),
  StampFilter(
    id: 'film02',
    label: 'Film 02',
    category: FilterCategory.retro,
    matrix: _goldGrain,
    premium: true,
  ),
  // ── Mood (Tâm trạng) ───────────────────────────────────────────────────
  StampFilter(
    id: 'warm',
    label: 'Ấm áp',
    category: FilterCategory.mood,
    matrix: _warm,
  ),
  StampFilter(
    id: 'cool',
    label: 'Lạnh',
    category: FilterCategory.mood,
    matrix: _cool,
  ),
  StampFilter(
    id: 'dream',
    label: 'Mộng mơ',
    category: FilterCategory.mood,
    matrix: _dream,
    premium: true,
  ),
  StampFilter(
    id: 'moody',
    label: 'Trầm',
    category: FilterCategory.mood,
    matrix: _moody,
    premium: true,
  ),
  // ── Season (Mùa) ───────────────────────────────────────────────────────
  StampFilter(
    id: 'spring',
    label: 'Xuân',
    category: FilterCategory.season,
    matrix: _spring,
  ),
  StampFilter(
    id: 'autumn',
    label: 'Thu',
    category: FilterCategory.season,
    matrix: _autumn,
    premium: true,
  ),
  StampFilter(
    id: 'winter',
    label: 'Đông',
    category: FilterCategory.season,
    matrix: _winter,
    premium: true,
  ),
  StampFilter(
    id: 'summer',
    label: 'Hạ',
    category: FilterCategory.season,
    matrix: _summer,
    premium: true,
  ),
];

/// Looks up a filter by id, falling back to the original.
StampFilter filterById(String id) => stampFilters.firstWhere(
  (f) => f.id == id,
  orElse: () => stampFilters.first,
);

/// Builds the effective [ColorFilter] for a draft: the selected preset matrix
/// composed with the manual adjustments. Returns `null` when there is nothing to
/// apply (original filter + identity adjustments), so the raw image renders.
ColorFilter? effectiveColorFilter(StampDraft draft) {
  final preset = filterById(draft.filterId).matrix;
  final adjust = draft.adjustments.isIdentity
      ? null
      : adjustmentMatrix(draft.adjustments);
  if (preset == null && adjust == null) return null;
  final combined = preset == null
      ? adjust!
      : (adjust == null ? preset : _multiply(adjust, preset));
  return ColorFilter.matrix(combined);
}

/// Derives a 5x4 color matrix from manual adjustments (SM-006 "Chỉnh tay").
/// brightness/contrast/warmth/saturation are each in [-1, 1].
List<double> adjustmentMatrix(Adjustments a) {
  // Saturation.
  const lumR = 0.2126;
  const lumG = 0.7152;
  const lumB = 0.0722;
  final s = 1 + a.saturation; // 0..2
  final sr = (1 - s) * lumR;
  final sg = (1 - s) * lumG;
  final sb = (1 - s) * lumB;
  final sat = <double>[
    sr + s, sg, sb, 0, 0, //
    sr, sg + s, sb, 0, 0, //
    sr, sg, sb + s, 0, 0, //
    0, 0, 0, 1, 0, //
  ];

  // Contrast (pivot at 0.5) and brightness (offset), plus a warmth tilt that
  // pushes red up and blue down.
  final c = 1 + a.contrast; // 0..2
  final t = (0.5 - 0.5 * c + a.brightness) * 255;
  final warmR = a.warmth * 40;
  final warmB = -a.warmth * 40;
  final tone = <double>[
    c, 0, 0, 0, t + warmR, //
    0, c, 0, 0, t, //
    0, 0, c, 0, t + warmB, //
    0, 0, 0, 1, 0, //
  ];

  return _multiply(tone, sat);
}

/// Multiplies two 5x4 color matrices (a after b).
List<double> _multiply(List<double> a, List<double> b) {
  final out = List<double>.filled(20, 0);
  for (var row = 0; row < 4; row++) {
    for (var col = 0; col < 5; col++) {
      var sum = 0.0;
      for (var k = 0; k < 4; k++) {
        sum += a[row * 5 + k] * b[k * 5 + col];
      }
      // The 5th column also picks up a's constant offset for this row.
      if (col == 4) sum += a[row * 5 + 4];
      out[row * 5 + col] = sum;
    }
  }
  return out;
}

// ── Preset matrices ────────────────────────────────────────────────────────
const _grayscale = <double>[
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0, 0, 0, 1, 0, //
];
const _sepia = <double>[
  0.393, 0.769, 0.189, 0, 0, //
  0.349, 0.686, 0.168, 0, 0, //
  0.272, 0.534, 0.131, 0, 0, //
  0, 0, 0, 1, 0, //
];
const _noir = <double>[
  0.28, 0.75, 0.07, 0, -18, //
  0.28, 0.75, 0.07, 0, -18, //
  0.28, 0.75, 0.07, 0, -18, //
  0, 0, 0, 1, 0, //
];
const _warmFade = <double>[
  1.1, 0, 0, 0, 12, //
  0, 1.02, 0, 0, 8, //
  0, 0, 0.9, 0, 0, //
  0, 0, 0, 1, 0, //
];
const _coolFade = <double>[
  0.9, 0, 0, 0, 0, //
  0, 1, 0, 0, 6, //
  0, 0, 1.1, 0, 14, //
  0, 0, 0, 1, 0, //
];
const _fadedBlue = <double>[
  0.9, 0.05, 0.05, 0, 10, //
  0.05, 0.9, 0.05, 0, 10, //
  0.1, 0.1, 1, 0, 20, //
  0, 0, 0, 1, 0, //
];
const _goldGrain = <double>[
  1.15, 0.05, 0, 0, 10, //
  0.05, 1, 0, 0, 5, //
  0, 0, 0.85, 0, 0, //
  0, 0, 0, 1, 0, //
];
const _warm = <double>[
  1.12, 0, 0, 0, 8, //
  0, 1.02, 0, 0, 2, //
  0, 0, 0.92, 0, 0, //
  0, 0, 0, 1, 0, //
];
const _cool = <double>[
  0.92, 0, 0, 0, 0, //
  0, 1, 0, 0, 2, //
  0, 0, 1.12, 0, 8, //
  0, 0, 0, 1, 0, //
];
const _dream = <double>[
  1.05, 0.05, 0.05, 0, 20, //
  0.05, 1, 0.05, 0, 18, //
  0.05, 0.05, 1.05, 0, 22, //
  0, 0, 0, 1, 0, //
];
const _moody = <double>[
  0.85, 0, 0, 0, -8, //
  0, 0.88, 0, 0, -6, //
  0, 0, 0.95, 0, -2, //
  0, 0, 0, 1, 0, //
];
const _spring = <double>[
  1, 0, 0.05, 0, 6, //
  0.05, 1.05, 0, 0, 8, //
  0, 0.05, 1, 0, 4, //
  0, 0, 0, 1, 0, //
];
const _autumn = <double>[
  1.15, 0.05, 0, 0, 10, //
  0, 1, 0, 0, 2, //
  0, 0, 0.82, 0, 0, //
  0, 0, 0, 1, 0, //
];
const _winter = <double>[
  0.9, 0, 0.05, 0, 4, //
  0, 0.98, 0.02, 0, 6, //
  0.05, 0, 1.15, 0, 12, //
  0, 0, 0, 1, 0, //
];
const _summer = <double>[
  1.1, 0, 0, 0, 6, //
  0, 1.08, 0, 0, 6, //
  0, 0, 0.95, 0, 0, //
  0, 0, 0, 1, 0, //
];
