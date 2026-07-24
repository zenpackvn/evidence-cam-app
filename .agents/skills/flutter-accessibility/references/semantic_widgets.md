# Semantic Widgets

Use `Semantics` to give screen readers meaningful context. Use `ExcludeSemantics` to hide purely decorative elements. Use `MergeSemantics` to combine related elements into a single announcement.

## Icon button without a visible label

```dart
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onToggle,
  });

  final bool isFavorite;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isFavorite ? 'Remove from favorites' : 'Add to favorites',
      child: IconButton(
        icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
        onPressed: onToggle,
      ),
    );
  }
}
```

## Decorative image — excluded from semantics

```dart
class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Image.asset(
        'assets/images/decorative_wave.webp',
        fit: BoxFit.cover,
        width: double.infinity,
        height: 120,
        cacheHeight: 240,
      ),
    );
  }
}
```

## Merging related elements into one announcement

```dart
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.rating,
  });

  final String name;
  final String price;
  final double rating;

  @override
  Widget build(BuildContext context) {
    // Screen reader announces: "Running Shoe, $129.99, 4.5 out of 5 stars"
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: Theme.of(context).textTheme.titleMedium),
            Text(price, style: Theme.of(context).textTheme.bodyLarge),
            Semantics(
              label: '${rating.toStringAsFixed(1)} out of 5 stars',
              child: Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < rating.round() ? Icons.star : Icons.star_border,
                    size: AppSpacing.iconSm,
                    color: AppColors.warning,
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Custom rating widget with full semantics

```dart
class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.rating,
    required this.onChanged,
    this.maxStars = 5,
  });

  final int rating;
  final ValueChanged<int> onChanged;
  final int maxStars;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Rating',
      value: '$rating out of $maxStars stars',
      hint: 'Double-tap to change',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(maxStars, (index) {
          final starNumber = index + 1;
          return Semantics(
            button: true,
            label: '$starNumber star${starNumber > 1 ? 's' : ''}',
            selected: starNumber <= rating,
            child: InkWell(
              onTap: () => onChanged(starNumber),
              borderRadius: const BorderRadius.all(
                Radius.circular(AppSpacing.radiusFull),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: AppSpacing.huge,
                  minHeight: AppSpacing.huge,
                ),
                child: Center(
                  child: Icon(
                    starNumber <= rating ? Icons.star : Icons.star_border,
                    color: AppColors.warning,
                    size: AppSpacing.iconLg,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
```

---

## Rules

- **Semantics on every interactive element** — All buttons, links, and tappable areas must have a semantic label. Use `Semantics(label:)` or the widget's built-in `tooltip` / `semanticLabel` property.
- **`ExcludeSemantics` only for decorative elements** — Never exclude interactive widgets from the semantics tree.
- **`MergeSemantics` for related content** — Group label + value + description into a single announcement to reduce screen reader verbosity.
- **Custom widgets need full `Semantics`** — label, value, hint, and actions must all be set for custom interactive controls (sliders, toggles, charts, ratings).
