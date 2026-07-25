import 'package:flutter_starter_template/data/ec_env.dart';
import 'package:flutter_starter_template/data/ec_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('no URL → sample data repository', () {
    expect(buildRepository(url: ''), isA<FakeEcRepository>());
  });

  test('a URL → live remote repository', () {
    expect(
      buildRepository(url: 'https://api.example.workers.dev'),
      isA<RemoteEcRepository>(),
    );
  });
}
