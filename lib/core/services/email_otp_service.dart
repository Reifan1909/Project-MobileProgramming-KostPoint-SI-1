import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

/// Hasil status pengiriman Email OTP
class EmailOtpResult {
  final bool isRealEmailSent;
  final String statusDescription;

  const EmailOtpResult({
    required this.isRealEmailSent,
    required this.statusDescription,
  });
}

/// Layanan Pengiriman Email OTP Menggunakan SMTP Resmi (Gmail / Custom SMTP).
class EmailOtpService {
  EmailOtpService._();

  /// Alamat Gmail pengirim notifikasi OTP.
  /// Contoh: 'kostpoint.service@gmail.com'
  static const String senderEmail = 'reifanmardatilla@gmail.com';

  /// Sandi Aplikasi 16-karakter dari akun Google (bisa dengan atau tanpa spasi).
  /// Didapat dari: Akun Google -> Keamanan -> Verifikasi 2 Langkah -> Sandi Aplikasi
  /// Contoh: 'abcd efgh ijkl mnop' atau 'abcdefghijklmnop'
  static const String senderAppPassword = 'uiwj evvn dabl wqfs';

  /// Apakah kredensial SMTP Gmail pengirim sudah diisi
  static bool get isConfigured =>
      senderEmail.trim().isNotEmpty && senderAppPassword.trim().isNotEmpty;

  /// Mengirimkan pesan email OTP asli ke inbox email pengguna
  static Future<EmailOtpResult> sendOtpEmail({
    required String targetEmail,
    required String otpCode,
    required String recipientName,
  }) async {
    debugPrint('====================================================');
    debugPrint('📧 [EMAIL OTP DISPATCH] Mengirim kode OTP ke: $targetEmail');
    debugPrint('🔑 KODE OTP: $otpCode (Masa berlaku 10 menit)');
    debugPrint('====================================================');

    if (!isConfigured) {
      debugPrint(
        'ℹ️ [SMTP INFO] Kredensial senderEmail & senderAppPassword belum diisi di email_otp_service.dart.',
      );
      debugPrint(
        'ℹ️ Masukkan email & Sandi Aplikasi Gmail (16 digit) di email_otp_service.dart agar email terkirim nyata ke inbox.',
      );
      return const EmailOtpResult(
        isRealEmailSent: false,
        statusDescription: 'Kredensial Gmail pengirim belum diisi di email_otp_service.dart. Kode OTP sementara dicetak di Debug Console.',
      );
    }

    try {
      // Hapus spasi jika pengguna menempelkan format 4x4 'xxxx xxxx xxxx xxxx'
      final cleanPassword = senderAppPassword.trim().replaceAll(' ', '');
      final smtpServer = gmail(senderEmail.trim(), cleanPassword);

      final message = Message()
        ..from = Address(senderEmail.trim(), 'Kost Point Verification')
        ..recipients.add(targetEmail.trim())
        ..subject = '[$otpCode] Kode Verifikasi Pendaftaran Kost Point'
        ..html =
            '''
          <div style="font-family: Arial, sans-serif; max-width: 500px; margin: auto; padding: 24px; border: 1px solid #E2E2EC; border-radius: 12px; background-color: #ffffff;">
            <h2 style="color: #7EAAEE; margin-top: 0; margin-bottom: 8px;">Kost Point</h2>
            <p style="font-size: 14px; color: #323335;">Halo <b>$recipientName</b>,</p>
            <p style="font-size: 13px; color: #555555; line-height: 1.5;">Terima kasih telah mendaftar di Kost Point. Gunakan kode verifikasi di bawah ini untuk mengonfirmasi pendaftaran akun Anda:</p>
            <div style="background-color: #F5F8FA; border: 1.5px dashed #7EAAEE; border-radius: 10px; padding: 18px; text-align: center; margin: 24px 0;">
              <span style="font-size: 32px; font-weight: 800; letter-spacing: 8px; color: #323335;">$otpCode</span>
            </div>
            <p style="font-size: 12px; color: #878788; line-height: 1.4;">Kode verifikasi ini berlaku selama 10 menit. Jika Anda tidak merasa melakukan pendaftaran, abaikan email ini.</p>
            <hr style="border: none; border-top: 1px solid #E2E2EC; margin: 24px 0 16px;" />
            <p style="font-size: 11px; color: #878788; text-align: center; margin: 0;">Kost Point Mobile • Pencarian Kos Fleksibel Berbasis Peta Dinamis</p>
          </div>
        ''';

      await send(message, smtpServer).timeout(const Duration(seconds: 15));
      debugPrint(
        '✅ [EMAIL OTP SUCCESS] Email berhasil terkirim ke $targetEmail!',
      );
      return const EmailOtpResult(
        isRealEmailSent: true,
        statusDescription: 'Email OTP berhasil dikirimkan ke kotak masuk Anda.',
      );
    } catch (e) {
      debugPrint('⚠️ [EMAIL OTP SMTP ERROR]: $e');
      return EmailOtpResult(
        isRealEmailSent: false,
        statusDescription:
            'Gagal mengirim email: $e. Pastikan koneksi internet aktif dan Sandi Aplikasi Google 16-karakter benar.',
      );
    }
  }

  /// Mengirimkan pesan email OTP khusus untuk Reset Kata Sandi
  static Future<EmailOtpResult> sendPasswordResetOtp({
    required String targetEmail,
    required String otpCode,
    required String recipientName,
  }) async {
    debugPrint('====================================================');
    debugPrint('🔑 [EMAIL RESET PASSWORD DISPATCH] Mengirim kode OTP ke: $targetEmail');
    debugPrint('🔑 KODE OTP RESET: $otpCode (Masa berlaku 10 menit)');
    debugPrint('====================================================');

    if (!isConfigured) {
      debugPrint('ℹ️ [SMTP INFO] Kredensial belum diisi di email_otp_service.dart.');
      return const EmailOtpResult(
        isRealEmailSent: false,
        statusDescription: 'Kredensial Gmail pengirim belum diisi di email_otp_service.dart. Kode OTP dicetak di Debug Console.',
      );
    }

    try {
      final cleanPassword = senderAppPassword.trim().replaceAll(' ', '');
      final smtpServer = gmail(senderEmail.trim(), cleanPassword);

      final message = Message()
        ..from = Address(senderEmail.trim(), 'Kost Point Keamanan')
        ..recipients.add(targetEmail.trim())
        ..subject = '[$otpCode] Kode Verifikasi Reset Kata Sandi Kost Point'
        ..html = '''
          <div style="font-family: Arial, sans-serif; max-width: 500px; margin: auto; padding: 24px; border: 1px solid #E2E2EC; border-radius: 12px; background-color: #ffffff;">
            <h2 style="color: #7EAAEE; margin-top: 0; margin-bottom: 8px;">Kost Point</h2>
            <p style="font-size: 14px; color: #323335;">Halo <b>$recipientName</b>,</p>
            <p style="font-size: 13px; color: #555555; line-height: 1.5;">Kami menerima permintaan untuk mereset kata sandi akun Kost Point Anda. Gunakan kode verifikasi di bawah ini untuk membuat kata sandi baru:</p>
            <div style="background-color: #F5F8FA; border: 1.5px dashed #7EAAEE; border-radius: 10px; padding: 18px; text-align: center; margin: 24px 0;">
              <span style="font-size: 32px; font-weight: 800; letter-spacing: 8px; color: #323335;">$otpCode</span>
            </div>
            <p style="font-size: 12px; color: #878788; line-height: 1.4;">Kode verifikasi ini berlaku selama 10 menit. Jika Anda tidak pernah meminta reset kata sandi, amankan akun Anda dan abaikan email ini.</p>
            <hr style="border: none; border-top: 1px solid #E2E2EC; margin: 24px 0 16px;" />
            <p style="font-size: 11px; color: #878788; text-align: center; margin: 0;">Kost Point Mobile • Layanan Keamanan Akun</p>
          </div>
        ''';

      await send(message, smtpServer).timeout(const Duration(seconds: 15));
      debugPrint('✅ [EMAIL RESET OTP SUCCESS] Email berhasil terkirim ke $targetEmail!');
      return const EmailOtpResult(
        isRealEmailSent: true,
        statusDescription: 'Email OTP reset kata sandi berhasil dikirimkan ke kotak masuk Anda.',
      );
    } catch (e) {
      debugPrint('⚠️ [EMAIL RESET OTP ERROR]: $e');
      return EmailOtpResult(
        isRealEmailSent: false,
        statusDescription: 'Gagal mengirim email: $e. Pastikan koneksi internet aktif.',
      );
    }
  }
}
