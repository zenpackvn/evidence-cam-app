/// The social platforms a letter link can be shared to (SM-016 BR-04). Exactly
/// the eight platforms the spec lists, in spec order (AC-07). The link itself is
/// platform-agnostic; the enum only drives which DM composer the sender opens
/// and the `platform` label recorded for stats.
enum SharePlatform {
  messenger,
  instagram,
  tiktok,
  threads,
  zalo,
  whatsapp,
  imessage,
  twitter;

  /// Wire value sent to the server as the link's `platform` (stats only).
  String get wire => name;
}

/// Builds the deep link that opens a given platform's share/DM composer with
/// the letter URL, and knows when to fall back to copying the link.
///
/// Only the fallback (copy) is guaranteed; per-platform URL schemes change and
/// the app may not be installed, so callers should try [dmUri] and fall back to
/// the native share sheet or clipboard (SM-016 section 5: copy the link and tell
/// the user to paste it into any messenger).
class LetterShare {
  const LetterShare();

  /// A best-effort URI that opens [platform]'s composer prefilled with
  /// [letterUrl]. Returns null when the platform exposes no reliable public
  /// prefill scheme — the caller then uses the native share sheet / clipboard.
  ///
  /// Only WhatsApp, Twitter/X and iMessage publish a documented URL scheme that
  /// prefills text. Messenger, Instagram DM, TikTok DM, Threads and Zalo have no
  /// reliable public DM-prefill scheme, so they fall back to copy/share.
  Uri? dmUri(SharePlatform platform, String letterUrl) {
    final encoded = Uri.encodeComponent(letterUrl);
    return switch (platform) {
      SharePlatform.whatsapp => Uri.parse('https://wa.me/?text=$encoded'),
      SharePlatform.twitter => Uri.parse(
        'https://twitter.com/intent/tweet?text=$encoded',
      ),
      SharePlatform.imessage => Uri.parse('sms:&body=$encoded'),
      SharePlatform.messenger ||
      SharePlatform.instagram ||
      SharePlatform.tiktok ||
      SharePlatform.threads ||
      SharePlatform.zalo => null,
    };
  }
}
