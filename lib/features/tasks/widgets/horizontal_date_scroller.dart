import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';

class HorizontalDateScroller extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const HorizontalDateScroller({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<HorizontalDateScroller> createState() => _HorizontalDateScrollerState();
}

class _HorizontalDateScrollerState extends State<HorizontalDateScroller> {
  late ScrollController _scrollController;
  late List<DateTime> _dates;
  final int _pastDays = 30;
  final int _futureDays = 60;
  final double _itemWidth = 64.0;
  final double _itemSpacing = 8.0;

  @override
  void initState() {
    super.initState();
    _initDates();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToInitialDate());
  }

  void _initDates() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _dates = List.generate(
      _pastDays + _futureDays + 1,
      (index) => today.add(Duration(days: index - _pastDays)),
    );
  }

  void _scrollToInitialDate() {
    if (!_scrollController.hasClients) return;
    final index = _dates.indexWhere((d) => _isSameDay(d, widget.selectedDate));
    if (index != -1) {
      final targetOffset = (index * (_itemWidth + _itemSpacing)) - 120;
      _scrollController.animateTo(
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  void didUpdateWidget(covariant HorizontalDateScroller oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isSameDay(oldWidget.selectedDate, widget.selectedDate)) {
      _scrollToInitialDate();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentMonthYear = DateFormat('MMMM yyyy').format(widget.selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: Month & Year Indicator with Quick Jump Buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.primaryBlue),
                  const SizedBox(width: 6),
                  Text(
                    currentMonthYear,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.titleText,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  final today = DateTime.now();
                  widget.onDateSelected(DateTime(today.year, today.month, today.day));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Horizontal Date Card Carousel
        SizedBox(
          height: 74,
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _dates.length,
            separatorBuilder: (_, __) => SizedBox(width: _itemSpacing),
            itemBuilder: (context, index) {
              final date = _dates[index];
              final isSelected = _isSameDay(date, widget.selectedDate);
              final isToday = _isSameDay(date, DateTime.now());

              return GestureDetector(
                onTap: () => widget.onDateSelected(date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _itemWidth,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : isToday
                            ? AppColors.primaryBlue.withValues(alpha: 0.08)
                            : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : isToday
                              ? AppColors.primaryBlue.withValues(alpha: 0.3)
                              : AppColors.border,
                      width: isSelected || isToday ? 1.5 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primaryBlue.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Day Name (e.g., Mon, Tue)
                      Text(
                        DateFormat('EEE').format(date).toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: isSelected
                              ? Colors.white70
                              : isToday
                                  ? AppColors.primaryBlue
                                  : AppColors.mutedText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Day Number (e.g., 08, 15)
                      Text(
                        DateFormat('d').format(date),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isSelected
                              ? Colors.white
                              : isToday
                                  ? AppColors.primaryBlue
                                  : AppColors.titleText,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
