# Theme — Anti-Patterns

### DON'T: Hardcode colors and spacing

```dart
// BAD — magic numbers scattered everywhere
Container(
  color: Color(0xFF1A73E8),
  padding: EdgeInsets.all(16),
  child: Text('Hello', style: TextStyle(fontSize: 14)),
)

// GOOD — use design tokens
Container(
  color: Theme.of(context).colorScheme.primary,
  padding: EdgeInsets.all(AppSpacing.md),
  child: Text('Hello', style: Theme.of(context).textTheme.bodyMedium),
)
```

### DON'T: Define duplicate color/typography constants per feature

```dart
// BAD — feature-specific color constants
class PostColors {
  static const primary = Color(0xFF1A73E8); // duplicates AppColors
}

// GOOD — always use AppColors / AppTheme tokens
// If a feature needs a unique color, add it to AppColors
```

### DON'T: Override ThemeData in child widgets

```dart
// BAD — overriding theme mid-tree breaks consistency
Theme(
  data: ThemeData(primaryColor: Colors.red),
  child: child,
)

// GOOD — use component themes set at the AppTheme level
```

### DON'T: Use `static const TextStyle` for AppTypography members

```dart
// BAD — GoogleFonts.inter(...) is not a const expression; this causes a compile error
static const TextStyle bodyMd = TextStyle(fontFamily: 'Inter', fontSize: 14);

// GOOD — getters return non-const GoogleFonts styles at call time
static TextStyle get bodyMd => GoogleFonts.inter(fontSize: 14, height: 1.5);
```

### DON'T: Omit a component theme from dark that exists in light

```dart
// BAD — elevatedButtonTheme defined only in AppTheme.light; dark lerps against Material default
ThemeData.dark().copyWith(
  colorScheme: darkColorScheme,
  // elevatedButtonTheme missing → TextStyleTween warning + potential crash on theme switch
)

// GOOD — both light and dark define exactly the same set of component themes
ThemeData.dark().copyWith(
  colorScheme: darkColorScheme,
  elevatedButtonTheme: ElevatedButtonThemeData(style: _elevatedButtonStyle(darkColorScheme)),
)
```
