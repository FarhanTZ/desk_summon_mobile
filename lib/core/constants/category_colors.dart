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
      case 'development':
      case 'coding':
      case 'code':
        return const CategoryColorTheme(
          solidBg: Color(0xFF7C3AED), // Solid Purple / Violet
          textColor: Colors.white,
          subTextColor: Color(0xFFDDD6FE),
          badgeBg: Color(0xFF6D28D9),
          badgeText: Colors.white,
          buttonBg: Colors.white,
          buttonText: Color(0xFF6D28D9),
        );
      case 'ai & research':
      case 'research':
      case 'ai':
        return const CategoryColorTheme(
          solidBg: Color(0xFF2563EB), // Solid Electric / Royal Blue
          textColor: Colors.white,
          subTextColor: Color(0xFFBFDBFE),
          badgeBg: Color(0xFF1D4ED8),
          badgeText: Colors.white,
          buttonBg: Colors.white,
          buttonText: Color(0xFF1D4ED8),
        );
      case 'design & ui/ux':
      case 'design':
      case 'ui/ux':
        return const CategoryColorTheme(
          solidBg: Color(0xFFDB2777), // Solid Pink / Rose
          textColor: Colors.white,
          subTextColor: Color(0xFFFBCFE8),
          badgeBg: Color(0xFFBE185D),
          badgeText: Colors.white,
          buttonBg: Colors.white,
          buttonText: Color(0xFFBE185D),
        );
      case 'writing & journal':
      case 'writing':
      case 'journal':
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
      case 'learning & course':
      case 'learning':
      case 'course':
      case 'youtube':
        return const CategoryColorTheme(
          solidBg: Color(0xFFDC2626), // Solid Crimson Red
          textColor: Colors.white,
          subTextColor: Color(0xFFFECACA),
          badgeBg: Color(0xFFB91C1C),
          badgeText: Colors.white,
          buttonBg: Colors.white,
          buttonText: Color(0xFFB91C1C),
        );
      case 'planning (trello)':
      case 'planning (notion)':
      case 'planning & review':
      case 'planning':
      case 'trello':
      case 'notion':
      case 'review':
        return const CategoryColorTheme(
          solidBg: Color(0xFF0D9488), // Solid Teal
          textColor: Colors.white,
          subTextColor: Color(0xFF99F6E4),
          badgeBg: Color(0xFF0F766E),
          badgeText: Colors.white,
          buttonBg: Colors.white,
          buttonText: Color(0xFF0F766E),
        );
      case 'chill & ambient':
      case 'chill':
      case 'ambient':
        return const CategoryColorTheme(
          solidBg: Color(0xFF4F46E5), // Solid Indigo
          textColor: Colors.white,
          subTextColor: Color(0xFFC7D2FE),
          badgeBg: Color(0xFF4338CA),
          badgeText: Colors.white,
          buttonBg: Colors.white,
          buttonText: Color(0xFF4338CA),
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

  // Map kategori ke IconData Material Design (menghindari emoji)
  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'development':
      case 'coding':
      case 'code':
        return Icons.code_rounded;
      case 'ai & research':
      case 'research':
      case 'ai':
        return Icons.psychology_rounded;
      case 'design & ui/ux':
      case 'design':
      case 'ui/ux':
        return Icons.palette_rounded;
      case 'writing & journal':
      case 'writing':
      case 'journal':
      case 'document':
      case 'docs':
        return Icons.edit_note_rounded;
      case 'learning & course':
      case 'learning':
      case 'course':
      case 'youtube':
        return Icons.play_lesson_rounded;
      case 'planning & review':
      case 'planning':
      case 'review':
      case 'trello':
      case 'notion':
        return Icons.dashboard_customize_rounded;
      case 'chill & ambient':
      case 'chill':
      case 'ambient':
        return Icons.coffee_rounded;
      case 'custom':
      default:
        return Icons.layers_rounded;
    }
  }
}
