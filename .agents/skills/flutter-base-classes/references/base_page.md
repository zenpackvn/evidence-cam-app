# BasePage

Base `StatelessWidget` that wires a cubit with `BaseState<T>` and maps states to UI. Subclasses override content builders only — no boilerplate `Scaffold`/`BlocBuilder`.

## File

`lib/src/core/base/base_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/common/app_error_state.dart';
import '../widgets/loading/screen_loading.dart';
import 'base_state.dart';

/// Base page that wires a cubit of type [C] with state [BaseState<T>].
///
/// Handles the standard state → UI mapping:
/// - Initial/Loading → loading widget
/// - Success → [buildSuccess]
/// - Empty → [buildEmpty]
/// - Error → [buildError]
///
/// Subclass only overrides the content builders.
abstract class BasePage<C extends Cubit<BaseState<T>>, T> extends StatelessWidget {
  const BasePage({super.key});

  /// Build the success UI with the loaded data.
  Widget buildSuccess(BuildContext context, T data);

  /// Build the empty state UI. Override for custom empty view.
  Widget buildEmpty(BuildContext context) {
    return const Center(child: Text('No data available'));
  }

  /// Build the error state UI. Override for custom error view.
  Widget buildError(BuildContext context, Failure failure) {
    return AppErrorState(
      message: failure.message,
      onRetry: () => context.read<C>().load(),
    );
  }

  /// Build the loading UI. Override for custom loading.
  Widget buildLoading(BuildContext context) {
    return const ScreenLoading();
  }

  /// Optional: build the app bar. Return null for no app bar.
  PreferredSizeWidget? buildAppBar(BuildContext context) => null;

  /// Optional: floating action button.
  Widget? buildFab(BuildContext context) => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      floatingActionButton: buildFab(context),
      body: BlocBuilder<C, BaseState<T>>(
        builder: (context, state) => switch (state) {
          BaseInitial() => buildLoading(context),
          BaseLoading() => buildLoading(context),
          BaseSuccess(:final data) => buildSuccess(context, data),
          BaseEmpty() => buildEmpty(context),
          BaseError(:final failure) => buildError(context, failure),
        },
      ),
    );
  }
}
```

## Usage

```dart
import '../../../core/base/base_page.dart';
import '../../../core/widgets/common/app_top_bar.dart';
import '../domain/entities/user.dart';
import 'user_detail_cubit.dart';

class UserDetailPage extends BasePage<UserDetailCubit, User> {
  const UserDetailPage({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return const AppTopBar(title: 'User Detail');
  }

  @override
  Widget buildSuccess(BuildContext context, User user) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        AppAvatar(name: user.name, size: AppAvatarSize.large),
        const AppSpacerV.md(),
        Text(user.name, style: Theme.of(context).textTheme.headlineMedium),
        Text(user.email),
      ],
    );
  }
}
```

## Rules

- Use `BasePage` for any page with the standard initial/loading/success/empty/error flow.
- Override `buildSuccess()` always. Override `buildEmpty()` and `buildError()` only for custom UI.
- For pages requiring controllers (scroll, text, focus), use `BaseStatefulPage` instead.
