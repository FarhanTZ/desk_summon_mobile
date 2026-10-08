import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/diary_model.dart';
import '../repositories/diary_repository.dart';
import 'diary_story_recap_page.dart';

class DiaryHistoryPage extends StatefulWidget {
  final DiaryRepository? diaryRepository;

  const DiaryHistoryPage({super.key, this.diaryRepository});

  @override
  State<DiaryHistoryPage> createState() => _DiaryHistoryPageState();
}

class _DiaryHistoryPageState extends State<DiaryHistoryPage> {
  late final DiaryRepository _diaryRepository;

  @override
  void initState() {
    super.initState();
    _diaryRepository = widget.diaryRepository ?? DiaryRepository();
  }

  String _cleanPreview(String markdown) {
    // Strip markdown headers and get clean first paragraph
    final lines = markdown.split('\n');
    final buffer = StringBuffer();
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      buffer.write(trimmed.replaceAll('*', '').replaceAll('-', '').trim());
      buffer.write(' ');
      if (buffer.length > 140) break;
    }
    final text = buffer.toString().trim();
    if (text.length > 130) {
      return '${text.substring(0, 130)}...';
    }
    return text.isEmpty ? 'Tap to view daily interactive story recap...' : text;
  }

  @override
  Widget build(BuildContext context) {
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
          'Auto-Diary History',
          style: TextStyle(
            color: AppColors.titleText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<DiaryModel>>(
          stream: _diaryRepository.getDiariesStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final diaries = snapshot.data ?? [];

            if (diaries.isEmpty) {
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
                          color: AppColors.primaryBlue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.menu_book_rounded, color: AppColors.primaryBlue, size: 34),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No Diary Entries Yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.titleText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your daily evaluations from Gemini Flash will appear here automatically every midnight (00:00).',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppColors.mutedText, height: 1.4),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              itemCount: diaries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final diary = diaries[index];
                final preview = _cleanPreview(diary.contentMarkdown);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DiaryStoryRecapPage(diary: diary),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.titleText.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Date & Status Tag
                        Row(
                          children: [
                            const Icon(Icons.event_note_rounded, size: 16, color: AppColors.primaryBlue),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                diary.formattedDate,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.titleText,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (diary.gaveUp)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFFECACA)),
                                ),
                                child: const Text(
                                  'Gave Up',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFDC2626),
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFA7F3D0)),
                                ),
                                child: const Text(
                                  'Completed',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF059669),
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Stats Badges Wrap
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _buildStatBadge(
                              icon: Icons.timer_outlined,
                              label: '${diary.totalFocusMinutes} min focus',
                              color: AppColors.primaryBlue,
                              bgColor: AppColors.softBlueTint,
                            ),
                            _buildStatBadge(
                              icon: Icons.check_circle_outline,
                              label: '${diary.completedSessions} deep work',
                              color: const Color(0xFF059669),
                              bgColor: const Color(0xFFECFDF5),
                            ),
                            if (diary.distractionCount > 0)
                              _buildStatBadge(
                                icon: Icons.warning_amber_rounded,
                                label: '${diary.distractionCount} missed',
                                color: const Color(0xFFD97706),
                                bgColor: const Color(0xFFFFFBEB),
                              ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Preview Text
                        Text(
                          preview,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.bodyText,
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Footer: Read Full Entry Link
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Read Full Diary',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded, size: 13, color: AppColors.primaryBlue),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatBadge({
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
}
