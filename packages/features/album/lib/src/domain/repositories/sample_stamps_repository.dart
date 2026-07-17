import 'package:architecture/architecture.dart';

import '../entities/sample_stamp.dart';

/// Read-only access to the curated sample-stamp catalog (SM-035). Saving a
/// sample into the personal album goes through `StampsRepository`; this
/// repository only fetches the catalog.
// A single-method port by design; the data layer swaps the Dio impl for a fake
// in tests.
// ignore: one_member_abstracts
abstract interface class SampleStampsRepository {
  /// The catalog, optionally filtered to one [theme] (SM-035 BR-02 / AC-01).
  Future<Result<List<SampleStamp>>> list({String? theme});
}
