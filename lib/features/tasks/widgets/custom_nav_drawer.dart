import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../diary/pages/diary_history_page.dart';
import '../../settings/pages/settings_page.dart';
import '../models/habit_model.dart';
import '../pages/all_tasks_page.dart';
import '../repositories/habit_repository.dart';
import '../repositories/session_repository.dart';
import '../utils/streak_calculator.dart';

class CustomNavDrawer extends StatelessWidget {
  final VoidCallback? onResetSession;

  const CustomNavDrawer({super.key, this.onResetSession});

  @override
  Widget build(BuildContext context) {
    final sessionRepository = SessionRepository();
    final habitRepository = HabitRepository();

    return Drawer(
      backgroundColor: AppColors.surface,
      elevation: 0,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. User Profile Header Card with Realtime Habit Progress
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryBlue.withValues(alpha: 0.25),
                              width: 1.5,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'F',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Farhan',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.titleText,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'PRO',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF059669),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Text(
                                    'AI Sync Connected',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF059669),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Daily Habit Progress & Streak Consistency Tracker
                    StreamBuilder<List<HabitModel>>(
                      stream: habitRepository.getHabitsStream(),
                      builder: (context, snapshot) {
                        final habits = snapshot.data ?? [];
                        final now = DateTime.now();
                        final scheduledHabits = habits.where((h) => h.isScheduledFor(now)).toList();
                        final totalDaily = scheduledHabits.length;
                        final completedCount = scheduledHabits.where((h) => h.isCompletedOn(now)).length;
                        final progressRatio = totalDaily > 0 ? (completedCount / totalDaily) : 0.0;
                        final summary = StreakCalculator.getSummary(habits);
                        final todayStr = DateFormat('yyyy-MM-dd').format(now);

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Today's Routines Progress
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Today's Routines",
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.titleText,
                                    ),
                                  ),
                                  Text(
                                    '$completedCount/$totalDaily (${(progressRatio * 100).toInt()}%)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: progressRatio >= 1.0
                                          ? const Color(0xFF059669)
                                          : AppColors.primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: progressRatio,
                                  minHeight: 5,
                                  backgroundColor: const Color(0xFFE2E8F0),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    progressRatio >= 1.0
                                        ? const Color(0xFF059669)
                                        : AppColors.primaryBlue,
                                  ),
                                ),
                              ),

                              if (habits.isNotEmpty) ...[
                                const Divider(height: 16, color: AppColors.border),

                                // 2. Streak Badge & Weekly Consistency Score
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.local_fire_department_rounded,
                                          color: Color(0xFFD97706),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${summary.currentStreak}d Streak',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.titleText,
                                          ),
                                        ),
                                        if (summary.currentStreak > 0) ...[
                                          const SizedBox(width: 5),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF059669).withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'ACTIVE',
                                              style: TextStyle(
                                                fontSize: 8,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF059669),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    Text(
                                      '${summary.weeklyScore.toInt()}% Week',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                // 3. Mini 7-Day Weekday Dot Matrix
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: summary.weekDaysStatus.entries.map((entry) {
                                    final date = entry.key;
                                    final rate = entry.value;
                                    final dateStr = DateFormat('yyyy-MM-dd').format(date);
                                    final isToday = dateStr == todayStr;
                                    final isPast = date.isBefore(DateTime(now.year, now.month, now.day));
                                    final dayLabel = DateFormat('E').format(date).substring(0, 1);

                                    Color dotBg;
                                    Widget innerWidget;

                                    if (rate >= 1.0) {
                                      dotBg = const Color(0xFF059669);
                                      innerWidget = const Icon(Icons.check_rounded, color: Colors.white, size: 10);
                                    } else if (rate > 0.0) {
                                      dotBg = AppColors.primaryBlue;
                                      innerWidget = Container(
                                        width: 4,
                                        height: 4,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      );
                                    } else if (isPast) {
                                      dotBg = const Color(0xFFE2E8F0);
                                      innerWidget = Container(
                                        width: 3,
                                        height: 3,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF94A3B8),
                                          shape: BoxShape.circle,
                                        ),
                                      );
                                    } else {
                                      dotBg = const Color(0xFFF1F5F9);
                                      innerWidget = const SizedBox();
                                    }

                                    return Column(
                                      children: [
                                        Text(
                                          dayLabel,
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
                                            color: isToday ? AppColors.primaryBlue : AppColors.mutedText,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            color: dotBg,
                                            shape: BoxShape.circle,
                                            border: isToday
                                                ? Border.all(color: AppColors.primaryBlue, width: 1.5)
                                                : null,
                                          ),
                                          child: Center(child: innerWidget),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(color: AppColors.border, height: 1),
            ),

            const SizedBox(height: 10),

            // 2. Navigation Items List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                physics: const BouncingScrollPhysics(),
                children: [
                  // Section: Workspace & Tracking
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Text(
                      'WORKSPACE & TRACKING',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.mutedText,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  _DrawerPillItem(
                    icon: Icons.dashboard_rounded,
                    iconBgColor: AppColors.primaryBlue.withValues(alpha: 0.12),
                    iconColor: AppColors.primaryBlue,
                    title: 'Workspace Dashboard',
                    subtitle: 'Overview, tasks & quick summon',
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 4),
                  _DrawerPillItem(
                    icon: Icons.checklist_rtl_rounded,
                    iconBgColor: const Color(0xFF059669).withValues(alpha: 0.12),
                    iconColor: const Color(0xFF059669),
                    title: 'All Tasks & Routines',
                    subtitle: 'Manage all habits & project tasks',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AllTasksPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  _DrawerPillItem(
                    icon: Icons.auto_stories_rounded,
                    iconBgColor: const Color(0xFF6366F1).withValues(alpha: 0.12),
                    iconColor: const Color(0xFF6366F1),
                    title: 'Auto-Diary History',
                    subtitle: 'AI daily logs & work summaries',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DiaryHistoryPage()),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Section: Preferences
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Text(
                      'PREFERENCES',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.mutedText,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  _DrawerPillItem(
                    icon: Icons.tune_rounded,
                    iconBgColor: const Color(0xFF64748B).withValues(alpha: 0.12),
                    iconColor: const Color(0xFF64748B),
                    title: 'Settings',
                    subtitle: 'Notification audio & preferences',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsPage()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // 3. Interactive Live Laptop Workstation Status Card at Bottom
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: sessionRepository.getSessionStream(),
                builder: (context, snapshot) {
                  final data = (snapshot.hasData && snapshot.data!.isNotEmpty)
                      ? snapshot.data!.first
                      : null;
                  final state = (data?['state'] ?? 'IDLE').toString().toUpperCase();
                  final isFocusing = state == 'FOCUSING';
                  final topic = data?['topic']?.toString() ?? 'Ready to summon task';

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isFocusing
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isFocusing
                            ? const Color(0xFFA7F3D0)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isFocusing
                                    ? const Color(0xFF059669).withValues(alpha: 0.15)
                                    : AppColors.primaryBlue.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isFocusing
                                    ? Icons.laptop_chromebook_rounded
                                    : Icons.power_settings_new_rounded,
                                size: 18,
                                color: isFocusing
                                    ? const Color(0xFF059669)
                                    : AppColors.primaryBlue,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        isFocusing ? 'Active Laptop Focus' : 'Laptop Workstation',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: isFocusing
                                              ? const Color(0xFF065F46)
                                              : AppColors.titleText,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: isFocusing
                                              ? const Color(0xFF059669)
                                              : const Color(0xFF94A3B8),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isFocusing ? topic : 'Standby & ready for summon',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isFocusing
                                          ? const Color(0xFF047857)
                                          : AppColors.mutedText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (isFocusing) ...[
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    final messenger = ScaffoldMessenger.of(context);
                                    Navigator.pop(context);
                                    await sessionRepository.concludeSession(surrender: false);
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text('Sesi laptop berhasil diselesaikan.'),
                                        backgroundColor: Color(0xFF059669),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF059669),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Complete Focus',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    final messenger = ScaffoldMessenger.of(context);
                                    Navigator.pop(context);
                                    await sessionRepository.resetSession(surrender: true);
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text('Sesi laptop dihentikan.'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: AppColors.dangerRedBorder),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'End Session',
                                      style: TextStyle(
                                        color: AppColors.dangerRed,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ] else ...[
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    final messenger = ScaffoldMessenger.of(context);
                                    await sessionRepository.concludeSession(surrender: false);
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text('Status laptop diperbarui ke Standby.'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: const Color(0xFFCBD5E1)),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.refresh_rounded, size: 14, color: AppColors.primaryBlue),
                                        SizedBox(width: 4),
                                        Text(
                                          'Reset Standby State',
                                          style: TextStyle(
                                            color: AppColors.primaryBlue,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerPillItem extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DrawerPillItem({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      splashColor: AppColors.primaryBlue.withValues(alpha: 0.08),
      highlightColor: AppColors.primaryBlue.withValues(alpha: 0.04),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.titleText,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.mutedText,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFCBD5E1),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
