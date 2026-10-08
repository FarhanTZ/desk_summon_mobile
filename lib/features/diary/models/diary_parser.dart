import 'package:flutter/material.dart';

class RealityMetric {
  final String title;
  final String value;
  final String detail;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final double? progress; // 0.0 - 1.0

  RealityMetric({
    required this.title,
    required this.value,
    required this.detail,
    required this.icon,
    required this.color,
    required this.bgColor,
    this.progress,
  });
}

class DiaryParsedData {
  final List<RealityMetric> realityMetrics;
  final String realitySummary;
  final String diagnosisText;
  final List<String> diagnosisPoints;
  final String targetMissionTitle;
  final String targetMissionDescription;
  final String fullMarkdown;

  DiaryParsedData({
    required this.realityMetrics,
    required this.realitySummary,
    required this.diagnosisText,
    required this.diagnosisPoints,
    required this.targetMissionTitle,
    required this.targetMissionDescription,
    required this.fullMarkdown,
  });

  factory DiaryParsedData.fromMarkdown(String markdown, {int focusMinutes = 0, int completedSessions = 0, int missedCount = 0}) {
    // 1. Split sections by header ### 1., ### 2., ### 3.
    String section1 = '';
    String section2 = '';
    String section3 = '';

    final lower = markdown.toLowerCase();
    final idx1 = lower.indexOf('### 1.');
    final idx2 = lower.indexOf('### 2.');
    final idx3 = lower.indexOf('### 3.');

    if (idx1 != -1 && idx2 != -1 && idx3 != -1 && idx1 < idx2 && idx2 < idx3) {
      section1 = markdown.substring(idx1, idx2).trim();
      section2 = markdown.substring(idx2, idx3).trim();
      section3 = markdown.substring(idx3).trim();
    } else {
      // Fallback
      section1 = markdown;
      section2 = '';
      section3 = '';
    }

    // Clean headers from section texts
    section1 = _stripSectionHeader(section1);
    section2 = _stripSectionHeader(section2);
    section3 = _stripSectionHeader(section3);

    // 2. Parse Section 1 (The Reality) Metrics
    final List<RealityMetric> metrics = [];
    final s1Lines = section1.split('\n');
    final s1RemainingLines = <String>[];

    for (final line in s1Lines) {
      final trimmed = line.trim();
      final lowerLine = trimmed.toLowerCase();

      if (lowerLine.contains('rasio habit') || lowerLine.contains('habit:')) {
        final val = _extractBoldOrAfterColon(trimmed);
        double? prog;
        if (val.contains('100%')) prog = 1.0;
        metrics.add(
          RealityMetric(
            title: 'Rasio Habit & Rutinitas',
            value: val.isNotEmpty ? val : '100% Selesai',
            detail: 'Disiplin rutinitas harian',
            icon: Icons.repeat_rounded,
            color: const Color(0xFF059669), // Emerald
            bgColor: const Color(0xFFECFDF5),
            progress: prog ?? 1.0,
          ),
        );
      } else if (lowerLine.contains('target kerja') || lowerLine.contains('task:')) {
        final val = _extractBoldOrAfterColon(trimmed);
        metrics.add(
          RealityMetric(
            title: 'Target Kerja Laptop',
            value: val.isNotEmpty ? val : 'Tuntas',
            detail: 'Workspace task & project',
            icon: Icons.laptop_chromebook_rounded,
            color: const Color(0xFF2563EB), // Royal Blue
            bgColor: const Color(0xFFEFF6FF),
            progress: 1.0,
          ),
        );
      } else if (lowerLine.contains('durasi deep work') || lowerLine.contains('deep work:')) {
        final val = _extractBoldOrAfterColon(trimmed);
        final isZero = val.contains('0 menit') || val.contains('0 min') || focusMinutes == 0;
        metrics.add(
          RealityMetric(
            title: 'Durasi Deep Work',
            value: val.isNotEmpty ? val : '$focusMinutes Menit Fokus',
            detail: isZero ? 'Belum ada waktu tercatat' : '$completedSessions sesi tuntas',
            icon: Icons.timer_outlined,
            color: isZero ? const Color(0xFFD97706) : const Color(0xFF7C3AED), // Amber or Purple
            bgColor: isZero ? const Color(0xFFFFFBEB) : const Color(0xFFF5F3FF),
            progress: isZero ? 0.05 : 1.0,
          ),
        );
      } else if (trimmed.isNotEmpty && !trimmed.startsWith('---')) {
        s1RemainingLines.add(trimmed);
      }
    }

    // Default metrics if none matched
    if (metrics.isEmpty) {
      metrics.add(
        RealityMetric(
          title: 'Durasi Fokus Deep Work',
          value: '$focusMinutes Menit',
          detail: '$completedSessions Sesi Selesai',
          icon: Icons.timer_outlined,
          color: const Color(0xFF2563EB),
          bgColor: const Color(0xFFEFF6FF),
          progress: focusMinutes > 0 ? 1.0 : 0.05,
        ),
      );
      metrics.add(
        RealityMetric(
          title: 'Habit & Rutinitas',
          value: missedCount == 0 ? 'Semua Selesai' : '$missedCount Terlewat',
          detail: missedCount == 0 ? '100% On Track' : 'Perlu diperbaiki',
          icon: Icons.check_circle_outline,
          color: missedCount == 0 ? const Color(0xFF059669) : const Color(0xFFDC2626),
          bgColor: missedCount == 0 ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
          progress: missedCount == 0 ? 1.0 : 0.5,
        ),
      );
    }

    // 3. Parse Section 2 (Honest Diagnosis)
    final diagnosisLines = section2.split('\n');
    final diagPoints = <String>[];
    final diagMainTextBuffer = StringBuffer();

    for (final line in diagnosisLines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('---')) continue;
      if (RegExp(r'^\d+\.|\*|\-').hasMatch(trimmed)) {
        diagPoints.add(trimmed.replaceFirst(RegExp(r'^\d+\.\s*|\*\s*|\-\s*'), '').trim());
      } else {
        diagMainTextBuffer.writeln(trimmed);
      }
    }

    // 4. Parse Section 3 (Tomorrow's Target)
    String missionTitle = 'Misi 5 Menit Penyelamat';
    String missionDesc = section3;
    final s3Lines = section3.split('\n');
    final s3DescBuffer = StringBuffer();

    for (final line in s3Lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('---')) continue;
      if (trimmed.toLowerCase().contains('misi') && trimmed.contains(':')) {
        missionTitle = trimmed.replaceAll('*', '').trim();
      } else {
        s3DescBuffer.writeln(trimmed);
      }
    }
    if (s3DescBuffer.isNotEmpty) {
      missionDesc = s3DescBuffer.toString().trim();
    }

    return DiaryParsedData(
      realityMetrics: metrics,
      realitySummary: s1RemainingLines.join('\n'),
      diagnosisText: diagMainTextBuffer.toString().trim(),
      diagnosisPoints: diagPoints,
      targetMissionTitle: missionTitle,
      targetMissionDescription: missionDesc,
      fullMarkdown: markdown,
    );
  }

  static String _stripSectionHeader(String section) {
    final lines = section.split('\n');
    if (lines.isEmpty) return section;
    final firstLine = lines.first.trim();
    if (firstLine.startsWith('#')) {
      return lines.sublist(1).join('\n').trim();
    }
    return section.trim();
  }

  static String _extractBoldOrAfterColon(String line) {
    // Check if there is a colon
    final colonIdx = line.indexOf(':');
    if (colonIdx != -1) {
      return line.substring(colonIdx + 1).replaceAll('*', '').trim();
    }
    return line.replaceAll('*', '').trim();
  }
}
