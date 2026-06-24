/// Deterministic A/B experiment bucketing for staged rollouts.
///
/// Maps a stable identifier (a user id, or a device id for signed-out users)
/// to a bucket in `[0, 100)`. The mapping is a pure hash, so the same id always
/// lands in the same bucket across launches and devices — a user does not flip
/// in and out of an experiment between sessions.
///
/// Gate a feature by comparing the bucket to a rollout percentage stored in
/// Remote Config: `bucketFor(userId) < remoteConfig.getInt('feature_x_rollout')`
/// ramps the feature from 0 to 100% by editing one server value, with no
/// release. Two different experiments use different [salt]s so their cohorts
/// are independent rather than always the same users.
int bucketFor(String id, {String salt = ''}) {
  return _fnv1a('$salt:$id') % 100;
}

/// Whether [id] is inside a [rolloutPercent] rollout for experiment [salt].
///
/// [rolloutPercent] is clamped to `[0, 100]`: 0 disables the feature for
/// everyone, 100 enables it for everyone.
bool isInRollout(String id, int rolloutPercent, {String salt = ''}) {
  if (rolloutPercent <= 0) return false;
  if (rolloutPercent >= 100) return true;
  return bucketFor(id, salt: salt) < rolloutPercent;
}

/// 32-bit FNV-1a hash. Cheap, dependency-free, and well-distributed enough for
/// cohort assignment (this is not a security hash).
int _fnv1a(String input) {
  const offsetBasis = 0x811c9dc5;
  const prime = 0x01000193;
  const mask = 0xffffffff;

  var hash = offsetBasis;
  for (final unit in input.codeUnits) {
    hash = (hash ^ unit) & mask;
    hash = (hash * prime) & mask;
  }
  return hash;
}
