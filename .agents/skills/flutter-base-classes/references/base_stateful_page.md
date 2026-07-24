# BaseStatefulPage

Base `StatefulWidget` for pages that need disposable resources — controllers, scroll positions, focus nodes. Provides lifecycle hooks and the standard cubit access pattern.

## File

`lib/src/core/base/base_stateful_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Base for stateful pages that need controllers (scroll, text, focus).
///
/// Provides lifecycle hooks and the standard cubit access pattern.
/// Use when the page needs [TextEditingController], [ScrollController],
/// [FocusNode], or other disposable resources.
abstract class BaseStatefulPage<C extends Cubit<S>, S> extends StatefulWidget {
  const BaseStatefulPage({super.key});
}

abstract class BaseStatefulPageState<
    W extends BaseStatefulPage<C, S>,
    C extends Cubit<S>,
    S> extends State<W> {
  /// Convenience accessor for the cubit.
  C get cubit => context.read<C>();

  /// Called once after first frame. Override to trigger initial loads.
  @mustCallSuper
  void onInit() {}

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => onInit());
  }
}
```

## Usage

```dart
class ChatPage extends BaseStatefulPage<ChatCubit, ChatState> {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState
    extends BaseStatefulPageState<ChatPage, ChatCubit, ChatState> {
  final _scrollController = ScrollController();
  final _messageController = TextEditingController();

  @override
  void onInit() {
    cubit.loadMessages();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Chat'),
      body: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          // build chat UI...
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
```

## When to use `BasePage` vs `BaseStatefulPage`

| | Use |
|--|--|
| No disposable resources | `BasePage<C, T>` |
| Needs scroll controller, text controller, focus node | `BaseStatefulPage<C, S>` |

## Rules

- Use `BaseStatefulPage` only when the page genuinely needs disposable resources.
- Always dispose controllers and focus nodes in `dispose()`.
- Trigger initial data loads in `onInit()` (runs after first frame), not `initState()`.
