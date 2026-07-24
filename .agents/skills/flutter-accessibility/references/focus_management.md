# Focus Management

Use `FocusTraversalGroup` for logical tab order. Auto-focus the primary action on page load. Return focus to the trigger after a dialog closes.

## Form with logical focus order

```dart
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Column(
        children: [
          FocusTraversalOrder(
            order: const NumericFocusOrder(1),
            child: TextField(
              focusNode: _emailFocus,
              autofocus: true, // First field gets focus on page load.
              decoration: const InputDecoration(labelText: 'Email'),
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _passwordFocus.requestFocus(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FocusTraversalOrder(
            order: const NumericFocusOrder(2),
            child: TextField(
              focusNode: _passwordFocus,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          FocusTraversalOrder(
            order: const NumericFocusOrder(3),
            child: ElevatedButton(
              onPressed: _submit,
              child: const Text('Sign In'),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    // Cubit handles actual submission.
    context.read<LoginCubit>().submit();
  }
}
```

## Returning focus after dialog dismissal

```dart
Future<void> _showDeleteDialog(BuildContext context, FocusNode returnFocus) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete item?'),
      content: const Text('This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  // Return focus to the element that opened the dialog.
  returnFocus.requestFocus();

  if (confirmed == true) {
    // Proceed with deletion via cubit.
  }
}
```

---

## Rules

- **`FocusTraversalGroup`** for logical tab order — wrap forms and interactive sections.
- **`autofocus: true`** on the primary action or first field when a page loads.
- **Return focus after dialog dismissal** — call `returnFocus.requestFocus()` after `await showDialog(...)`.
- **Dispose `FocusNode`s** in `dispose()` — always paired with creation.
- **Dialogs trap focus** — verify focus does not escape the dialog during screen reader navigation.
