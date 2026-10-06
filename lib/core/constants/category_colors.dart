import 'package:flutter/material.dart';

class CategoryColorTheme {
  final Color solidBg;       // Warna solid pekat untuk background card
  final Color textColor;     // Warna teks judul & teks utama (putih)
  final Color subTextColor;  // Warna teks sekunder/muted di atas solid bg
  final Color badgeBg;       // Warna background badge kontras di atas solid bg
  final Color badgeText;     // Warna teks badge
  final Color buttonBg;      // Warna tombol Summon (putih/kontras)
  final Color buttonText;    // Warna teks tombol Summon

  const CategoryColorTheme({
    required this.solidBg,
    required this.textColor,
    required this.subTextColor,
    required this.badgeBg,
    required this.badgeText,
    required this.buttonBg,
    required this.buttonText,
  });

  // Map kategori ke palet warna solid pekat / non-transparan
  static CategoryColorTheme fromCategory(String category) {
    switch (category.toLowerCase()) {
      case 'ielts prep':
      case 'ielts':
        return const CategoryColorTheme(
          solidBg: Color(0xFF2563EB), // Solid Royal Blue
          textColor: Colors.white,
          subTextColor: Color(0xFFBFDBFE),
          badgeBg: Color(0xFF1D4ED8),
          badgeText: Colors.white,
          buttonBg: Colors.white,
          buttonText: Color(0xFF1D4ED8),
        );
      case 'development':
      case 'coding':
        return const CategoryColorTheme(
          solidBg: Color(0xFF7C3AED), // Solid Purple / Violet
          textColor: Colors.white,
          subTextColor: Color(0xFFDDD6FE),
          badgeBg: Color(0xFF6D28D9),
          badgeText: Colors.white,
          buttonBg: Colors.white,
          buttonText: Color(0xFF6D28D9),
        );
      case 'document':
      case 'docs':
        return const CategoryColorTheme(
          solidBg: Color(0xFF059669), // Solid Emerald Green
          textColor: Colors.white,
          subTextColor: Color(0xFFA7F3D0),
          badgeBg: Color(0xFF047857),
          badgeText: Colors.white,
          buttonBg: Colors.white,
          buttonText: Color(0xFF047857),
        );
      case 'learning':
      case 'youtube':
        return const CategoryColorTheme(
          solidBg: Color(0xFFDC2626), // Solid Coral Red
          textColor: Colors.white,
          subTextColor: Color(0xFFFECACA),
          badgeBg: Color(0xFFB91C1C),
          badgeText: Colors.white,
          buttonBg: Colors.white,
          buttonText: Color(0xFFB91C1C),
        );
      case 'custom':
      default:
        return const CategoryColorTheme(
          solidBg: Color(0xFFD97706), // Solid Amber / Orange
          textColor: Colors.white,
          subTextColor: Color(0xFFFDE68A),
          badgeBg: Color(0xFFB45309),
          badgeText: Colors.white,
          buttonBg: Colors.white,
          buttonText: Color(0xFFB45309),
        );
    }
  }
}
