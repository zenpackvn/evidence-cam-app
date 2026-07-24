# Restorable Widgets

## Form with State Restoration

```dart
// lib/src/features/checkout/presentation/checkout_page.dart

import 'package:flutter/material.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage>
    with RestorationMixin {
  // Restorable form fields — survive process death.
  final _name = RestorableTextEditingController();
  final _email = RestorableTextEditingController();
  final _address = RestorableTextEditingController();
  final _agreedToTerms = RestorableBool(false);

  @override
  String? get restorationId => 'checkout_page';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_name, 'name');
    registerForRestoration(_email, 'email');
    registerForRestoration(_address, 'address');
    registerForRestoration(_agreedToTerms, 'agreed_to_terms');
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _address.dispose();
    _agreedToTerms.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _name.value,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _email.value,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _address.value,
              decoration: const InputDecoration(labelText: 'Address'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('I agree to Terms'),
              value: _agreedToTerms.value,
              onChanged: (v) => setState(() => _agreedToTerms.value = v!),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Scroll Position Restoration

```dart
class _PostListPageState extends State<PostListPage>
    with RestorationMixin {
  final _scrollOffset = RestorableDouble(0);

  late final ScrollController _scrollController;

  @override
  String? get restorationId => 'post_list_page';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_scrollOffset, 'scroll_offset');
    _scrollController = ScrollController(
      initialScrollOffset: _scrollOffset.value,
    );
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    _scrollOffset.value = _scrollController.offset;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _scrollOffset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: 100,
      itemBuilder: (context, index) => ListTile(title: Text('Post $index')),
    );
  }
}
```

## Tab Index Restoration

```dart
class _MainShellState extends State<MainShell>
    with RestorationMixin {
  final _tabIndex = RestorableInt(0);

  @override
  String? get restorationId => 'main_shell';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_tabIndex, 'tab_index');

    // After restoration, sync GoRouter's branch index.
    if (initialRestore && _tabIndex.value != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.navigationShell.goBranch(_tabIndex.value);
      });
    }
  }

  @override
  void dispose() {
    _tabIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: (index) {
          _tabIndex.value = index;
          widget.navigationShell.goBranch(index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.list), label: 'Posts'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
```

## Custom Restorable Types

### RestorableEnum

```dart
// lib/src/core/restoration/restorable_enum.dart

import 'package:flutter/widgets.dart';

/// Restorable property for any enum type.
class RestorableEnum<T extends Enum> extends RestorableValue<T> {
  RestorableEnum(this._defaultValue, {required this.values});

  final T _defaultValue;
  final List<T> values;

  @override
  T createDefaultValue() => _defaultValue;

  @override
  void didUpdateValue(T? oldValue) {
    if (oldValue != value) notifyListeners();
  }

  @override
  T fromPrimitives(Object? data) {
    final index = data as int? ?? 0;
    return index < values.length ? values[index] : _defaultValue;
  }

  @override
  Object? toPrimitives() => value.index;
}
```

Usage:

```dart
class _FilterPageState extends State<FilterPage> with RestorationMixin {
  final _sortOrder = RestorableEnum<SortOrder>(
    SortOrder.newest,
    values: SortOrder.values,
  );

  @override
  String? get restorationId => 'filter_page';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_sortOrder, 'sort_order');
  }
}
```

### RestorableDateTime

```dart
import 'package:flutter/widgets.dart';

class RestorableDateTime extends RestorableValue<DateTime> {
  RestorableDateTime(this._defaultValue);

  final DateTime _defaultValue;

  @override
  DateTime createDefaultValue() => _defaultValue;

  @override
  void didUpdateValue(DateTime? oldValue) {
    if (oldValue != value) notifyListeners();
  }

  @override
  DateTime fromPrimitives(Object? data) {
    if (data is int) return DateTime.fromMillisecondsSinceEpoch(data);
    return _defaultValue;
  }

  @override
  Object? toPrimitives() => value.millisecondsSinceEpoch;
}
```
