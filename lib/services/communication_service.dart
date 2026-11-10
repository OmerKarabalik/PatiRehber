import 'package:url_launcher/url_launcher.dart';

class CommunicationService {
  static const String developerPhone = '905079314513';
  static const String developerEmail = 'eyer259@gmail.com';

  /// WhatsApp üzerinden doğrudan geliştiriciye mesaj atma
  static Future<bool> sendViaWhatsApp({
    required String category,
    required String name,
    required String message,
  }) async {
    final senderName = name.trim().isNotEmpty ? name.trim() : 'PatiRehber Kullanıcısı';
    final text = 'Merhaba Ömer Bey,\nPatiRehber uygulamasından yazıyorum.\n\n📌 Konu: $category\n👤 Gönderen: $senderName\n\n💬 Mesajım:\n${message.trim()}';

    final uri = Uri.parse('https://wa.me/$developerPhone?text=${Uri.encodeComponent(text)}');
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        return await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      return false;
    }
  }

  /// Gmail / E-posta üzerinden doğrudan geliştiriciye mail atma
  static Future<bool> sendViaEmail({
    required String category,
    required String name,
    required String message,
  }) async {
    final senderName = name.trim().isNotEmpty ? name.trim() : 'PatiRehber Kullanıcısı';
    final subject = 'PatiRehber Geri Bildirim - $category';
    final body = 'Merhaba Ömer Bey,\n\nGönderen: $senderName\nKonu: $category\n\nMesaj:\n${message.trim()}\n\n---\nPatiRehber Mobil Uygulaması';

    final uri = Uri.parse('mailto:$developerEmail?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}');
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        return await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      return false;
    }
  }

  /// Geliştiricinin gelen bir mesaja WhatsApp ile cevap yazması
  static Future<bool> replyViaWhatsApp({
    required String phone,
    required String message,
  }) async {
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.startsWith('0')) {
      cleanPhone = '9$cleanPhone';
    } else if (!cleanPhone.startsWith('90') && cleanPhone.length == 10) {
      cleanPhone = '90$cleanPhone';
    }

    final uri = Uri.parse('https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}');
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  /// Geliştiricinin gelen bir mesaja e-posta ile cevap yazması
  static Future<bool> replyViaEmail({
    required String email,
    required String subject,
    required String message,
  }) async {
    final uri = Uri.parse('mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(message)}');
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
