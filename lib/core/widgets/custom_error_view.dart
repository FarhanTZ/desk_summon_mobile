import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum ErrorType {
  network,
  server,
  timeout,
  general,
}

class CustomErrorView extends StatelessWidget {
  final dynamic error;
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final bool isCompact;

  const CustomErrorView({
    super.key,
    this.error,
    this.title,
    this.message,
    this.onRetry,
    this.isCompact = false,
  });

  static ErrorType classifyError(dynamic err) {
    if (err == null) return ErrorType.general;
    final str = err.toString().toLowerCase();
    if (err is SocketException ||
        str.contains('socketexception') ||
        str.contains('failed host lookup') ||
        str.contains('network') ||
        str.contains('no internet') ||
        str.contains('offline') ||
        str.contains('connection refused') ||
        str.contains('clientexception')) {
      return ErrorType.network;
    }
    if (str.contains('timeout') || str.contains('timed out')) {
      return ErrorType.timeout;
    }
    if (str.contains('500') || str.contains('502') || str.contains('503') || str.contains('postgrest')) {
      return ErrorType.server;
    }
    return ErrorType.general;
  }

  static String getDefaultTitle(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return 'Koneksi Internet Terputus';
      case ErrorType.timeout:
        return 'Waktu Permintaan Habis';
      case ErrorType.server:
        return 'Gangguan Server';
      case ErrorType.general:
        return 'Gagal Memuat Data';
    }
  }

  static String getDefaultMessage(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return 'Tidak dapat terhubung ke server. Periksa koneksi Wi-Fi atau data seluler Anda, lalu coba lagi.';
      case ErrorType.timeout:
        return 'Server membutuhkan waktu terlalu lama untuk merespons. Silakan coba kembali.';
      case ErrorType.server:
        return 'Terjadi kendala saat menyinkronkan data dengan database. Silakan muat ulang.';
      case ErrorType.general:
        return 'Terjadi kesalahan saat memproses data. Silakan coba muat ulang halaman.';
    }
  }

  static IconData getDefaultIcon(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off_rounded;
      case ErrorType.timeout:
        return Icons.hourglass_disabled_rounded;
      case ErrorType.server:
        return Icons.cloud_off_rounded;
      case ErrorType.general:
        return Icons.error_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = classifyError(error);
    final displayTitle = title ?? getDefaultTitle(type);
    final displayMessage = message ?? getDefaultMessage(type);
    final iconData = getDefaultIcon(type);

    if (isCompact) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFECACA)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x080F172A),
              blurRadius: 8,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(iconData, color: const Color(0xFFDC2626), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayTitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.titleText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    displayMessage,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.mutedText,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryBlue, size: 22),
                onPressed: onRetry,
                tooltip: 'Coba Lagi',
              ),
            ],
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFDBEAFE)),
              ),
              child: Icon(iconData, color: AppColors.primaryBlue, size: 32),
            ),
            const SizedBox(height: 18),
            Text(
              displayTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.titleText,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              displayMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.mutedText,
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                height: 42,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text(
                    'Coba Lagi',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
