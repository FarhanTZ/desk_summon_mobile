import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../core/constants/app_colors.dart';
import '../models/diary_model.dart';
import '../models/diary_parser.dart';

class DiaryDetailPage extends StatefulWidget {
  final DiaryModel diary;

  const DiaryDetailPage({super.key, required this.diary});

  @override
  State<DiaryDetailPage> createState() => _DiaryDetailPageState();
}

class _DiaryDetailPageState extends State<DiaryDetailPage> {
  bool _showRawMarkdown = false;

  @override
  Widget build(BuildContext context) {
    final parsed = DiaryParsedData.fromMarkdown(
      widget.diary.contentMarkdown,
      focusMinutes: widget.diary.totalFocusMinutes,
      completedSessions: widget.diary.completedSessions,
      missedCount: widget.diary.distractionCount,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.titleText, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'AI Evaluation Report',
          style: TextStyle(
            color: AppColors.titleText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded, color: AppColors.mutedText, size: 20),
            tooltip: 'Copy Markdown',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.diary.contentMarkdown));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('Diary copied to clipboard!'),
                    ],
                  ),
                  backgroundColor: AppColors.titleText,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Hero AI Analytics Header Banner
              _buildHeroHeader(widget.diary),

              const SizedBox(height: 20),

              // 2. Section: 📊 The Reality (Fakta Angka Dashboard Grid)
              _buildRealityDashboardSection(parsed),

              const SizedBox(height: 20),

              // 3. Section: 🧠 Honest Diagnosis (Analisis & Pola Prokrastinasi)
              _buildDiagnosisSection(parsed),

              const SizedBox(height: 20),

              // 4. Section: 🎯 Tomorrow's Single Target (Misi 5 Menit Penyelamat)
              _buildTomorrowTargetSection(parsed),

              const SizedBox(height: 24),

              // 5. Expandable Raw AI Transcript
              _buildRawMarkdownToggle(parsed),

              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader(DiaryModel diary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A8A), // Navy 900
            Color(0xFF1D4ED8), // Royal Blue 700
            Color(0xFF2563EB), // Vibrant Blue 600
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D4ED8).withValues(alpha: 0.32),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 13),
                      SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          'AI ACCOUNTABILITY',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF047857),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'EVALUATED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            diary.formattedDate,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildTopMetricPill(
                icon: Icons.timer_outlined,
                value: '${diary.totalFocusMinutes} min',
                label: 'Deep Work',
              ),
              const SizedBox(width: 8),
              _buildTopMetricPill(
                icon: Icons.check_circle_outline,
                value: '${diary.completedSessions}',
                label: 'Tuntas',
              ),
              const SizedBox(width: 8),
              if (diary.gaveUp)
                _buildTopMetricPill(
                  icon: Icons.flag_outlined,
                  value: 'Ada',
                  label: 'Menyerah',
                )
              else
                _buildTopMetricPill(
                  icon: Icons.warning_amber_rounded,
                  value: '${diary.distractionCount}',
                  label: 'Habit Lewat',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopMetricPill({required IconData icon, required String value, required String label}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: const Color(0xFF93C5FD)),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Section: 📊 The Reality Dashboard Bento Grid
  Widget _buildRealityDashboardSection(DiaryParsedData parsed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF059669).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.analytics_rounded, size: 18, color: Color(0xFF059669)),
            ),
            const SizedBox(width: 10),
            const Text(
              '1. The Reality — Fakta Angka & Rasio',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.titleText,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Grid Metric Cards
        ...parsed.realityMetrics.map((m) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.titleText.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: m.bgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(m.icon, color: m.color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.mutedText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          m.value,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.titleText,
                          ),
                        ),
                        if (m.detail.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            m.detail,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: m.color,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            )),

        if (parsed.realitySummary.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              parsed.realitySummary,
              style: const TextStyle(fontSize: 12.5, color: AppColors.bodyText, height: 1.45),
            ),
          ),
        ],
      ],
    );
  }

  // 3. Section: 🧠 Honest Diagnosis
  Widget _buildDiagnosisSection(DiaryParsedData parsed) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.psychology_rounded, size: 20, color: Color(0xFFD97706)),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  '2. Honest Diagnosis',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.titleText,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: const Text(
                  'AI ANALYSIS',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFD97706),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Main Diagnosis Intro
          if (parsed.diagnosisText.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: const Border(left: BorderSide(color: Color(0xFFD97706), width: 3.5)),
              ),
              child: Text(
                parsed.diagnosisText,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF78350F),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Diagnosis Sub-points
          ...parsed.diagnosisPoints.map((point) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.arrow_right_rounded, color: Color(0xFFD97706), size: 22),
                  const SizedBox(width: 6),
                  Expanded(
                    child: MarkdownBody(
                      data: point,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: AppColors.bodyText, height: 1.45),
                        strong: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.titleText),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // 4. Section: 🎯 Tomorrow's Single Target
  Widget _buildTomorrowTargetSection(DiaryParsedData parsed) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF065F46), // Emerald 800
            Color(0xFF059669), // Emerald 600
            Color(0xFF10B981), // Emerald 500
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.rocket_launch_rounded, size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "3. Tomorrow's Target",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '5-MIN MISSION',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Mission Container Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flag_rounded, size: 16, color: Color(0xFF6EE7B7)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        parsed.targetMissionTitle,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF6EE7B7),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                MarkdownBody(
                  data: parsed.targetMissionDescription,
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.95),
                      height: 1.5,
                    ),
                    strong: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
                    em: TextStyle(fontStyle: FontStyle.italic, color: Colors.white.withValues(alpha: 0.85)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 5. Expandable Full Markdown Toggle
  Widget _buildRawMarkdownToggle(DiaryParsedData parsed) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          ListTile(
            title: const Text(
              'View Raw AI Transcript',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.titleText),
            ),
            subtitle: const Text(
              'Original text evaluation output',
              style: TextStyle(fontSize: 11, color: AppColors.mutedText),
            ),
            trailing: Icon(
              _showRawMarkdown ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
              color: AppColors.mutedText,
            ),
            onTap: () => setState(() => _showRawMarkdown = !_showRawMarkdown),
          ),
          if (_showRawMarkdown) ...[
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(16),
              child: MarkdownBody(
                data: parsed.fullMarkdown,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(fontSize: 12.5, color: AppColors.bodyText, height: 1.5),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
