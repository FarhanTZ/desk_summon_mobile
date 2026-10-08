import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_error_view.dart';
import '../models/diary_model.dart';
import '../repositories/diary_repository.dart';
import 'diary_story_recap_page.dart';
import 'diary_detail_page.dart';

class DiaryHistoryPage extends StatefulWidget {
  final DiaryRepository? diaryRepository;

  const DiaryHistoryPage({super.key, this.diaryRepository});

  @override
  State<DiaryHistoryPage> createState() => _DiaryHistoryPageState();
}

class _DiaryHistoryPageState extends State<DiaryHistoryPage> {
  late final DiaryRepository _diaryRepository;
  late Stream<List<DiaryModel>> _diariesStream;
  List<DiaryModel> _cachedDiaries = [];
  String _selectedFilter = 'all'; // 'all', 'focus', 'surrender'
  final String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _diaryRepository = widget.diaryRepository ?? DiaryRepository();
    _diariesStream = _diaryRepository.getDiariesStream();
  }

  void _refresh() {
    setState(() {
      _diariesStream = _diaryRepository.getDiariesStream();
    });
  }

  String _cleanPreview(String markdown) {
    final lines = markdown.split('\n');
    final buffer = StringBuffer();
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      buffer.write(trimmed.replaceAll('*', '').replaceAll('-', '').trim());
      buffer.write(' ');
      if (buffer.length > 130) break;
    }
    final text = buffer.toString().trim();
    if (text.length > 120) {
      return '${text.substring(0, 120)}...';
    }
    return text.isEmpty ? 'Ketuk untuk membuka rekap interaktif harian...' : text;
  }

  List<DiaryModel> _filterDiaries(List<DiaryModel> diaries) {
    return diaries.where((d) {
      if (_selectedFilter == 'focus' && d.totalFocusMinutes == 0) return false;
      if (_selectedFilter == 'surrender' && !d.gaveUp) return false;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesDate = d.formattedDate.toLowerCase().contains(query) || d.entryDate.toLowerCase().contains(query);
        final matchesContent = d.contentMarkdown.toLowerCase().contains(query);
        return matchesDate || matchesContent;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.titleText, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'AI Auto-Diary History',
          style: TextStyle(
            color: AppColors.titleText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<DiaryModel>>(
          stream: _diariesStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _cachedDiaries = snapshot.data!;
            }

            if (snapshot.connectionState == ConnectionState.waiting && _cachedDiaries.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError && _cachedDiaries.isEmpty) {
              return CustomErrorView(
                error: snapshot.error,
                onRetry: _refresh,
              );
            }

            final allDiaries = _cachedDiaries;
            final filteredDiaries = _filterDiaries(allDiaries);

            return RefreshIndicator(
              onRefresh: () async {
                _refresh();
              },
              color: AppColors.primaryBlue,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                slivers: [
                  // 1. Top Summary Banner
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: _buildHeaderSummaryCard(allDiaries),
                    ),
                  ),

                  // 2. Filter Chips
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: _buildFilterTabs(allDiaries),
                    ),
                  ),

                  // 3. Diary Entries List or Empty State
                  if (filteredDiaries.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(allDiaries.isEmpty),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final diary = filteredDiaries[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _buildDiaryCard(diary),
                            );
                          },
                          childCount: filteredDiaries.length,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ==========================================================
  // TOP SUMMARY HEADER
  // ==========================================================
  Widget _buildHeaderSummaryCard(List<DiaryModel> diaries) {
    int totalFocus = 0;
    int daysWithFocus = 0;
    for (final d in diaries) {
      totalFocus += d.totalFocusMinutes;
      if (d.totalFocusMinutes > 0) daysWithFocus++;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A8A), // Blue 900
            Color(0xFF2563EB), // Blue 600
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                    SizedBox(width: 5),
                    Text(
                      'AI DIARY RECAP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${diaries.length} Hari Evaluasi',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Evaluasi & Kedisiplinan Kerja',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Laporan harian otomatis dibuat setiap jam 00:00',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFFDBEAFE),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          // Mini Stat Row
          Row(
            children: [
              _buildHeaderStatItem(
                label: 'Total Deep Work',
                value: '$totalFocus m',
                icon: Icons.timer_outlined,
              ),
              Container(width: 1, height: 28, color: Colors.white.withValues(alpha: 0.2)),
              _buildHeaderStatItem(
                label: 'Hari Aktif Fokus',
                value: '$daysWithFocus / ${diaries.length}',
                icon: Icons.track_changes_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStatItem({required String label, required String value, required IconData icon}) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF93C5FD), size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFBFDBFE),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FILTER TABS
  // ==========================================================
  Widget _buildFilterTabs(List<DiaryModel> diaries) {
    final focusCount = diaries.where((d) => d.totalFocusMinutes > 0).length;
    final surrenderCount = diaries.where((d) => d.gaveUp).length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildFilterChip('Semua (${diaries.length})', 'all'),
          const SizedBox(width: 8),
          _buildFilterChip('Ada Deep Work ($focusCount)', 'focus'),
          const SizedBox(width: 8),
          _buildFilterChip('Ada Sesi Menyerah ($surrenderCount)', 'surrender'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryBlue.withValues(alpha: 0.2)
                  : const Color(0xFF0F172A).withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            )
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.mutedText,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // MODERN TIMELINE DIARY CARD
  // ==========================================================
  Widget _buildDiaryCard(DiaryModel diary) {
    final preview = _cleanPreview(diary.contentMarkdown);
    final dateParts = _parseDateParts(diary.entryDate);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DiaryStoryRecapPage(diary: diary),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Calendar Badge + Date + Evaluated Pill
                Row(
                  children: [
                    // Calendar Day Box
                    Container(
                      width: 44,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dateParts.day,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.titleText,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            dateParts.month,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.mutedText,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Date & Year text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            diary.formattedDate,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.titleText,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Dievaluasi oleh AI Gemini',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.mutedText.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Evaluated Status Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: const Text(
                        'EVALUATED',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryBlue,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(color: Color(0xFFF1F5F9), height: 1),
                const SizedBox(height: 12),

                // Metrics Tag Row (Specific per-task / per-session stats)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildStatTag(
                      icon: Icons.timer_outlined,
                      label: '${diary.totalFocusMinutes} Menit Fokus',
                      color: AppColors.primaryBlue,
                      bgColor: const Color(0xFFEFF6FF),
                    ),
                    _buildStatTag(
                      icon: Icons.task_alt_rounded,
                      label: '${diary.completedSessions} Sesi Tuntas',
                      color: const Color(0xFF059669),
                      bgColor: const Color(0xFFECFDF5),
                    ),
                    if (diary.gaveUp)
                      _buildStatTag(
                        icon: Icons.flag_outlined,
                        label: 'Ada Sesi Menyerah',
                        color: const Color(0xFFDC2626),
                        bgColor: const Color(0xFFFEF2F2),
                      ),
                    if (diary.distractionCount > 0)
                      _buildStatTag(
                        icon: Icons.warning_amber_rounded,
                        label: '${diary.distractionCount} Habit Lewat',
                        color: const Color(0xFFD97706),
                        bgColor: const Color(0xFFFFFBEB),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Markdown Clean Preview
                Text(
                  preview,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.bodyText,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 14),

                // Action Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DiaryDetailPage(diary: diary),
                          ),
                        );
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.dashboard_outlined, size: 14, color: AppColors.mutedText),
                          SizedBox(width: 4),
                          Text(
                            'Buka Dashboard',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Buka Sticky Recap',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 13, color: AppColors.primaryBlue),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatTag({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // EMPTY STATE
  // ==========================================================
  Widget _buildEmptyState(bool isCompletelyEmpty) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFDBEAFE)),
              ),
              child: const Icon(Icons.menu_book_rounded, color: AppColors.primaryBlue, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              isCompletelyEmpty ? 'Belum Ada Catatan Diary' : 'Tidak Ada Hasil yang Cocok',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.titleText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isCompletelyEmpty
                  ? 'Evaluasi harian dari AI akan dibuat otomatis setiap tengah malam (jam 00:00).'
                  : 'Coba pilih filter lain untuk melihat riwayat evaluasi.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12.5, color: AppColors.mutedText, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }

  _DateParts _parseDateParts(String dateStr) {
    try {
      final parsed = DateTime.parse(dateStr);
      final monthNames = [
        'JAN', 'FEB', 'MAR', 'APR', 'MEI', 'JUN',
        'JUL', 'AGU', 'SEP', 'OKT', 'NOV', 'DES'
      ];
      return _DateParts(
        day: parsed.day.toString().padLeft(2, '0'),
        month: monthNames[parsed.month - 1],
      );
    } catch (_) {
      return _DateParts(day: '01', month: 'HARI');
    }
  }
}

class _DateParts {
  final String day;
  final String month;
  _DateParts({required this.day, required this.month});
}
