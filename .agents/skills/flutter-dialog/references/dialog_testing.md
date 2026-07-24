# Dialog Testing — FakeDialog and Test Patterns

## `FakeDialog` implementation

```dart
class FakeDialog implements AppDialog {
  final List<String> calls = [];
  bool confirmResult = true;

  @override
  void showToast(
    String message, {
    AppToastPosition position = AppToastPosition.bottom,
    Duration displayTime = const Duration(milliseconds: 2000),
  }) => calls.add('toast:$message');

  @override
  void showNotification({
    required String message,
    AppNotifyType type = AppNotifyType.success,
    Duration displayTime = const Duration(milliseconds: 3000),
  }) => calls.add('notify:${type.name}:$message');

  @override
  Future<bool> showConfirm({
    required String title,
    String? message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDangerousAction = false,
  }) async {
    calls.add('confirm:$title');
    return confirmResult;
  }

  @override
  Future<T?> showCustom<T>({
    required Widget Function(BuildContext context) builder,
    bool clickMaskDismiss = true,
    bool usePenetrate = false,
    Alignment alignment = Alignment.center,
    String? tag,
  }) async {
    calls.add('custom:${tag ?? 'no-tag'}');
    return null;
  }

  @override
  void showLoading({String? message}) => calls.add('loading:${message ?? ''}');

  @override
  void dismissLoading() => calls.add('dismissLoading');

  @override
  Future<T?> showAttached<T>({
    required BuildContext targetContext,
    required Widget Function(BuildContext context) builder,
    Alignment targetAlignment = Alignment.bottomCenter,
    Alignment followerAlignment = Alignment.topCenter,
    bool clickMaskDismiss = true,
    String? tag,
  }) async {
    calls.add('attached:${tag ?? 'no-tag'}');
    return null;
  }

  @override
  void dismissAll() => calls.add('dismissAll');

  @override
  void dismiss({String? tag}) => calls.add('dismiss:${tag ?? ''}');

  @override
  Widget wrapApp(BuildContext context, Widget? child) => child ?? const SizedBox.shrink();
}
```

## Test example — cubit with confirm callback

```dart
void main() {
  late FakeDialog fakeDialog;
  late FakePostRepository fakeRepo;
  late PostCubit cubit;

  setUp(() {
    fakeDialog = FakeDialog();
    fakeRepo = FakePostRepository();
    cubit = PostCubit(fakeRepo);
  });

  tearDown(() => cubit.close());

  blocTest<PostCubit, PostState>(
    'deletePost — confirmed → emits deleting then deleted',
    build: () => cubit,
    act: (cubit) => cubit.deletePost(
      1,
      confirmDelete: () => fakeDialog.showConfirm(title: 'Delete?'),
    ),
    expect: () => [
      const PostDeleting(),
      const PostDeleted(),
    ],
    verify: (_) {
      expect(fakeDialog.calls, contains('confirm:Delete?'));
      expect(fakeRepo.deletedIds, contains(1));
    },
  );

  blocTest<PostCubit, PostState>(
    'deletePost — cancelled → emits nothing',
    setUp: () => fakeDialog.confirmResult = false,
    build: () => cubit,
    act: (cubit) => cubit.deletePost(
      1,
      confirmDelete: () => fakeDialog.showConfirm(title: 'Delete?'),
    ),
    expect: () => <PostState>[],
    verify: (_) {
      expect(fakeRepo.deletedIds, isEmpty);
    },
  );
}
```

## DI override in tests

```dart
setUp(() async {
  await getIt.reset();
  getIt.registerSingleton<AppDialog>(FakeDialog());
  // ... other registrations
});
```
