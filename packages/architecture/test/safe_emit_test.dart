import 'package:architecture/architecture.dart';
import 'package:bloc/bloc.dart';
import 'package:test/test.dart';

class _Counter extends Cubit<int> with SafeEmitMixin {
  _Counter() : super(0);

  void bump() => safeEmit(state + 1);
}

void main() {
  group('SafeEmitMixin', () {
    test('emits while open', () {
      final cubit = _Counter()..bump();
      expect(cubit.state, 1);
      cubit.close();
    });

    test('is a no-op after close (no throw, no state change)', () async {
      final cubit = _Counter();
      await cubit.close();

      expect(cubit.bump, returnsNormally);
      expect(cubit.state, 0);
    });
  });
}
