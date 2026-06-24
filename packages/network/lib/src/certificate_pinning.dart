import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// Pins the server certificate by SHA-256 fingerprint.
///
/// When [pins] is non-empty, every TLS connection is accepted only if the
/// leaf certificate's DER SHA-256 is in the list; any other certificate — even
/// one the OS trust store would accept — is rejected, which defeats a
/// man-in-the-middle that presents a validly-signed-but-different cert. When
/// [pins] is empty this is a no-op and normal OS validation applies (the right
/// default for dev against a tunnel/self-signed server).
///
/// Pins the leaf cert, not its SPKI: simpler (no ASN.1 parsing) but it must be
/// rotated whenever the cert is reissued. For rotation-resilient pinning, pin
/// the public-key SPKI of an intermediate instead — see
/// docs/system-design-coverage.
// ponytail: leaf-cert SHA-256; switch to SPKI pinning if cert rotation churn
// becomes a problem.
void applyCertificatePinning(Dio dio, List<String> pins) {
  if (pins.isEmpty) return;
  final allowed = pins.map((p) => p.toLowerCase()).toSet();

  final adapter = dio.httpClientAdapter;
  if (adapter is! IOHttpClientAdapter) return;

  adapter.createHttpClient = () {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) {
      // Reaching here means default validation already failed OR we are asked
      // to vet the cert; either way only an explicitly pinned cert passes.
      return allowed.contains(_fingerprint(cert));
    };
    return client;
  };

  // badCertificateCallback only fires for certs the OS rejects. To also pin
  // certs the OS *accepts*, validate on every connection via the approve hook.
  adapter.validateCertificate = (cert, host, port) =>
      cert != null && allowed.contains(_fingerprint(cert));
}

String _fingerprint(X509Certificate cert) =>
    sha256.convert(cert.der).toString().toLowerCase();
