import 'package:url_launcher/url_launcher.dart';

class LauncherHelper {
  LauncherHelper._();

  /* --------------------------------------------------
   * INTERNAL UTILS
   * -------------------------------------------------- */

  /// Clean phone number:
  /// - keep digits and "+"
  /// - remove spaces, -, ()
  static String _cleanPhone(String phone) {
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }

  static Future<void> _launch(Uri uri) async {
    final success = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!success) {
      throw Exception('Unable to open the requested application');
    }
  }

  /* --------------------------------------------------
   * URL (GENERAL)
   * -------------------------------------------------- */

  /// Launch any URL (http, https, mailto, tel, custom schemes)
  ///
  /// Example:
  /// https://example.com
  /// mailto:test@mail.com
  static Future<void> launchURL(String url) async {
    final uri = Uri.parse(url);
    await _launch(uri);
  }

  /* --------------------------------------------------
   * WHATSAPP
   * -------------------------------------------------- */

  static Future<void> openWhatsApp({required String phoneNumber}) async {
    final phone = _cleanPhone(phoneNumber);
    final uri = Uri.parse('https://wa.me/$phone');

    await _launch(uri);
  }

  static Future<void> openWhatsAppWithMessage({required String phoneNumber, required String message}) async {
    final phone = _cleanPhone(phoneNumber);
    final encodedMessage = Uri.encodeComponent(message);

    final uri = Uri.parse('https://wa.me/$phone?text=$encodedMessage');

    await _launch(uri);
  }

  /* --------------------------------------------------
   * TELEGRAM
   * -------------------------------------------------- */

  static Future<void> openTelegram({required String username}) async {
    final cleanUsername = username.replaceAll('@', '');
    final uri = Uri.parse('https://t.me/$cleanUsername');

    await _launch(uri);
  }

  static Future<void> openTelegramWithMessage({required String username, required String message}) async {
    final cleanUsername = username.replaceAll('@', '');
    final encodedMessage = Uri.encodeComponent(message);

    final uri = Uri.parse('https://t.me/$cleanUsername?text=$encodedMessage');

    await _launch(uri);
  }

  /* --------------------------------------------------
   * PHONE CALL
   * -------------------------------------------------- */

  static Future<void> callPhone({required String phoneNumber}) async {
    final phone = _cleanPhone(phoneNumber);
    final uri = Uri.parse('tel:$phone');

    await _launch(uri);
  }
}
