import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit_model.dart';

class HabitProgressDashboardCard extends StatelessWidget {
  final List<HabitModel> habits;
  final Stream<List<Map<String, dynamic>>>? sessionStream;
  final VoidCallback? onTap;
  final Function(Map<String, dynamic>)? onTapSession;

  const HabitProgressDashboardCard({
    super.key,
    required this.habits,
    this.sessionStream,
    this.onTap,
    this.onTapSession,
  });

  HabitModel? _getNextUpcomingHabit() {
    final uncompleted = habits.where((h) => !h.isCompletedOn()).toList();
    if (uncompleted.isEmpty) return null;

    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;

    // 1. Cari yang sedang berlangsung atau berikutnya hari ini
    HabitModel? nextHabit;
    int minDiff = 999999;

    for (final h in uncompleted) {
      if (h.startTime != null) {
        final startMinutes = h.startTime!.hour * 60 + h.startTime!.minute;
        final diff = startMinutes - nowMinutes;
        if (diff >= -30 && diff < minDiff) {
          minDiff = diff;
          nextHabit = h;
        }
      }
    }

    return nextHabit ?? uncompleted.first;
  }

  String _getMotivationText(double progress, int completed, int total) {
    if (total == 0) return 'Atur rutinitas harian untuk memulai hari.';
    if (progress >= 1.0) return 'Semua rutinitas selesai. Performa luar biasa!';
    if (progress >= 0.8) return 'Hampir selesai. Tuntaskan target hari ini.';
    if (progress >= 0.5) return 'Lebih dari separuh selesai, jaga momentum.';
    if (progress > 0) return 'Awal yang baik, terus lanjutkan.';
    return 'Siap memulai hari dengan produktif?';
  }

  @override
  Widget build(BuildContext context) {
    final total = habits.length;
    final completed = habits.where((h) => h.isCompletedOn()).length;
    final progress = total > 0 ? (completed / total) : 0.0;
    final percentage = (progress * 100).toInt();
    final nextHabit = _getNextUpcomingHabit();
    final motivation = _getMotivationText(progress, completed, total);
    final dateStr = DateFormat('EEEE, d MMM').format(DateTime.now());

    final isAllDone = total > 0 && completed == total;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isAllDone
                ? [
                    const Color(0xFF1E3A8A), // Deep Navy
                    const Color(0xFF1D4ED8), // Royal Blue
                    const Color(0xFF2563EB), // Vibrant Blue
                  ]
                : [
                    const Color(0xFF1E40AF), // Blue 800
                    const Color(0xFF2563EB), // Blue 600
                    const Color(0xFF3B82F6), // Blue 500
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF60A5FA).withValues(alpha: 0.35),
            width: 1.2,
          ),
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
            // Row 1: Header Tag & Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isAllDone ? Icons.military_tech_rounded : Icons.bolt_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 3.5),
                          Text(
                            isAllDone ? 'PERFECT SCORE' : 'DAILY PROGRESS',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Row 2: Circular Ring & Main Stats
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Custom Circular Progress Ring
                SizedBox(
                  width: 68,
                  height: 68,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 68,
                        height: 68,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 6.5,
                          strokeCap: StrokeCap.round,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$percentage%',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'DONE',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: Colors.white.withValues(alpha: 0.75),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Text Information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        total > 0 ? '$completed of $total Completed' : 'No Habits Scheduled',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        motivation,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Row 3: Next Routine Pill
            if (nextHabit != null && !isAllDone) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.alarm_on_rounded, size: 14, color: Color(0xFF93C5FD)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          style: const TextStyle(fontSize: 11, color: Colors.white70),
                          children: [
                            const TextSpan(text: 'Next: '),
                            TextSpan(
                              text: nextHabit.title,
                              style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                            if (nextHabit.startTime != null) ...[
                              TextSpan(
                                text: ' (${HabitModel.formatTime(nextHabit.startTime!)})',
                                style: const TextStyle(color: Color(0xFF93C5FD), fontWeight: FontWeight.w700),
                              ),
                            ],
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Colors.white60),
                  ],
                ),
              ),
            ],

            // Row 4: Live Laptop Workspace Pill (Merged)
            if (sessionStream != null) ...[
              const SizedBox(height: 10),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: sessionStream,
                builder: (context, snapshot) {
                  final data = snapshot.data;
                  final state = (data != null && data.isNotEmpty)
                      ? data.first['state'] ?? 'IDLE'
                      : 'IDLE';
                  final topic = (data != null && data.isNotEmpty)
                      ? data.first['topic'] ?? '-'
                      : '-';

                  final isFocusing = state == 'FOCUSING';
                  final isSurrendered = state == 'SURRENDERED';

                  final Color pillBg = isFocusing
                      ? const Color(0xFF047857).withValues(alpha: 0.45)
                      : (isSurrendered
                          ? const Color(0xFFD97706).withValues(alpha: 0.4)
                          : Colors.black.withValues(alpha: 0.2));
                  final Color dotColor = isFocusing
                      ? const Color(0xFF34D399)
                      : (isSurrendered ? const Color(0xFFFBBF24) : Colors.white60);

                  return GestureDetector(
                    onTap: () {
                      if (onTapSession != null && data != null && data.isNotEmpty) {
                        onTapSession!(data.first);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7.5),
                      decoration: BoxDecoration(
                        color: pillBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isFocusing
                              ? const Color(0xFF34D399).withValues(alpha: 0.4)
                              : Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: dotColor,
                              shape: BoxShape.circle,
                              boxShadow: isFocusing
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF34D399).withValues(alpha: 0.6),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      )
                                    ]
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isFocusing
                                  ? 'LAPTOP ACTIVE: "$topic"'
                                  : (isSurrendered
                                      ? 'LAPTOP: Focus Session Ended'
                                      : 'LAPTOP ON STANDBY (Ready to summon)'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isFocusing ? FontWeight.w800 : FontWeight.w600,
                                color: isFocusing ? const Color(0xFFECFDF5) : Colors.white70,
                                letterSpacing: isFocusing ? 0.2 : 0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isFocusing
                                  ? const Color(0xFF059669)
                                  : Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              state,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
