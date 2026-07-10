/// Why a seal amount was credited or debited (SM-033). Mirrors the server's
/// ledger `reason`.
enum SealReason {
  share,
  send,
  opened,
  install,
  unlockSticker,
  unlockBorder,
  unlockTemplateStamp,
  purchase,
  unknown;

  static SealReason fromWire(String value) => switch (value) {
    'share' => SealReason.share,
    'send' => SealReason.send,
    'opened' => SealReason.opened,
    'install' => SealReason.install,
    'unlock_sticker' => SealReason.unlockSticker,
    'unlock_border' => SealReason.unlockBorder,
    'unlock_template_stamp' => SealReason.unlockTemplateStamp,
    'purchase' => SealReason.purchase,
    _ => SealReason.unknown,
  };
}

/// One append-only ledger entry (SM-033). Positive credits, negative debits.
class SealEntry {
  const SealEntry({
    required this.amount,
    required this.reason,
    required this.createdAt,
    this.refId,
  });

  final int amount;
  final SealReason reason;
  final String? refId;
  final DateTime createdAt;

  bool get isCredit => amount >= 0;
}

/// The user's current seal balance plus recent history (SM-033).
class SealBalance {
  const SealBalance({required this.balance, this.history = const []});

  final int balance;
  final List<SealEntry> history;
}
