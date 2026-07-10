/// A permanently unlockable item bought with seals (SM-033 BR-11/12/13).
enum UnlockType {
  stickerPack('sticker_pack'),
  border('border'),
  templateStamp('template_stamp');

  const UnlockType(this.wire);

  /// Wire value sent to the server as `item_type`.
  final String wire;
}

/// The outcome of a spend attempt (SM-033 BR-14).
class SpendOutcome {
  const SpendOutcome({
    required this.unlocked,
    required this.newBalance,
    this.shortfall = 0,
  });

  final bool unlocked;
  final int newBalance;

  /// Seals still needed when the balance was insufficient (0 on success).
  final int shortfall;
}

/// The outcome of a "share to earn" attempt (SM-033 BR-05/06).
class ShareReward {
  const ShareReward({required this.awarded, required this.newBalance});

  /// `false` when the weekly cap was already reached — the share still happens,
  /// but no seals are credited.
  final bool awarded;
  final int newBalance;
}
