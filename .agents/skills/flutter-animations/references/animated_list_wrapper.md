# AnimatedListWrapper

Typed wrapper for `AnimatedList` with default entrance/exit transitions. Uses `AppAnimations` constants for consistent timing.

## `lib/src/core/animations/animated_list_wrapper.dart`

```dart
import 'package:flutter/material.dart';

import 'app_animations.dart';

/// Typed wrapper for [AnimatedList] with default entrance/exit transitions.
class AnimatedListWrapper<T> extends StatefulWidget {
  const AnimatedListWrapper({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.scrollController,
    this.padding,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, Animation<double> animation) itemBuilder;
  final ScrollController? scrollController;
  final EdgeInsetsGeometry? padding;

  @override
  State<AnimatedListWrapper<T>> createState() => AnimatedListWrapperState<T>();
}

class AnimatedListWrapperState<T> extends State<AnimatedListWrapper<T>> {
  final _listKey = GlobalKey<AnimatedListState>();
  late List<T> _items;

  @override
  void initState() {
    super.initState();
    _items = List.of(widget.items);
  }

  void insertItem(int index, T item) {
    _items.insert(index, item);
    _listKey.currentState?.insertItem(
      index,
      duration: AppAnimations.durationMedium,
    );
  }

  void removeItem(int index) {
    final removedItem = _items.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => SizeTransition(
        sizeFactor: animation,
        child: FadeTransition(
          opacity: animation,
          child: widget.itemBuilder(context, removedItem, animation),
        ),
      ),
      duration: AppAnimations.durationMedium,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      controller: widget.scrollController,
      padding: widget.padding,
      initialItemCount: _items.length,
      itemBuilder: (context, index, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: AppAnimations.curveSharp,
          )),
          child: FadeTransition(
            opacity: animation,
            child: widget.itemBuilder(context, _items[index], animation),
          ),
        );
      },
    );
  }
}
```
