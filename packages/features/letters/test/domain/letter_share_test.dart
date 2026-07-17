import 'package:feature_letters/feature_letters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SharePlatform (SM-016 BR-04 / AC-07)', () {
    test('has exactly the eight spec platforms in spec order', () {
      // AC-07: Facebook Messenger, Instagram DM, TikTok DM, Threads, Zalo,
      // WhatsApp, iMessage, Twitter/X DM — exactly eight, no extras.
      expect(SharePlatform.values, hasLength(8));
      expect(SharePlatform.values, [
        SharePlatform.messenger,
        SharePlatform.instagram,
        SharePlatform.tiktok,
        SharePlatform.threads,
        SharePlatform.zalo,
        SharePlatform.whatsapp,
        SharePlatform.imessage,
        SharePlatform.twitter,
      ]);
    });

    test('wire value is the enum name (stable stats label)', () {
      expect(SharePlatform.tiktok.wire, 'tiktok');
      expect(SharePlatform.twitter.wire, 'twitter');
    });
  });

  group('LetterShare.dmUri', () {
    const share = LetterShare();
    const url = 'https://stampmail.app/letter/abc?x=1';

    test('platforms with a documented scheme prefill the encoded url', () {
      final wa = share.dmUri(SharePlatform.whatsapp, url)!;
      expect(wa.host, 'wa.me');
      expect(wa.query, contains(Uri.encodeComponent(url)));

      final x = share.dmUri(SharePlatform.twitter, url)!;
      expect(x.host, 'twitter.com');
      expect(x.query, contains(Uri.encodeComponent(url)));

      final ims = share.dmUri(SharePlatform.imessage, url)!;
      expect(ims.scheme, 'sms');
      expect(ims.toString(), contains(Uri.encodeComponent(url)));
    });

    test('platforms without a reliable scheme return null (share-sheet path)', () {
      for (final p in [
        SharePlatform.messenger,
        SharePlatform.instagram,
        SharePlatform.tiktok,
        SharePlatform.threads,
        SharePlatform.zalo,
      ]) {
        expect(share.dmUri(p, url), isNull, reason: '$p should fall back');
      }
    });
  });
}
