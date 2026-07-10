/// The social platforms a letter link can be shared to (SM-016). Names are the
/// commercial platforms the sender picks; the link itself is platform-agnostic.
enum SharePlatform {
  zalo,
  messenger,
  facebook,
  instagram,
  telegram,
  whatsapp,
  sms,
  copyLink;

  /// Wire value sent to the server as the link's `platform` (stats only).
  String get wire => name;
}

/// Builds the deep link that opens a given platform's share/DM composer with
/// the letter URL, and knows when to fall back to copying the link.
///
/// Only the fallback (copy) is guaranteed; per-platform URL schemes change and
/// the app may not be installed, so callers should try [dmUri] and fall back to
/// the native share sheet or clipboard (SM-016 section 5).
class LetterShare {
  const LetterShare();

  /// A best-effort URI that opens [platform]'s composer prefilled with
  /// [letterUrl]. Returns null when there is no scheme (use the native share
  /// sheet / clipboard instead) — e.g. [SharePlatform.copyLink].
  Uri? dmUri(SharePlatform platform, String letterUrl) {
    final encoded = Uri.encodeComponent(letterUrl);
    return switch (platform) {
      SharePlatform.telegram => Uri.parse('https://t.me/share/url?url=$encoded'),
      SharePlatform.whatsapp => Uri.parse('https://wa.me/?text=$encoded'),
      SharePlatform.sms => Uri.parse('sms:?body=$encoded'),
      SharePlatform.facebook => Uri.parse(
        'https://www.facebook.com/sharer/sharer.php?u=$encoded',
      ),
      // Zalo / Messenger / Instagram have no reliable public prefill scheme;
      // fall back to the native share sheet or clipboard.
      SharePlatform.zalo ||
      SharePlatform.messenger ||
      SharePlatform.instagram ||
      SharePlatform.copyLink => null,
    };
  }
}
