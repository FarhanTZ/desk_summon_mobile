import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/diary_model.dart';
import '../models/diary_parser.dart';
import 'diary_detail_page.dart';

class DiaryStoryRecapPage extends StatefulWidget {
  final DiaryModel diary;

  const DiaryStoryRecapPage({super.key, required this.diary});

  @override
  State<DiaryStoryRecapPage> createState() => _DiaryStoryRecapPageState();
}

class _DiaryStoryRecapPageState extends State<DiaryStoryRecapPage> with TickerProviderStateMixin {
  late final DiaryParsedData _parsed;
  int _currentIndex = 0;
  static const int _totalCards = 3;

  // ValueNotifier for zero-rebuild drag performance (120 FPS)
  final ValueNotifier<double> _dragNotifier = ValueNotifier<double>(0.0);

  // High-performance animation controllers
  late AnimationController _animController;
  late Animation<double> _animCurve;
  double _animStart = 0.0;
  double _animEnd = 0.0;

  // Cached card widgets with RepaintBoundaries for GPU texture caching
  late final List<Widget> _cachedCards;

  @override
  void initState() {
    super.initState();
    _parsed = DiaryParsedData.fromMarkdown(
      widget.diary.contentMarkdown,
      focusMinutes: widget.diary.totalFocusMinutes,
      completedSessions: widget.diary.completedSessions,
      missedCount: widget.diary.distractionCount,
    );

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    _animCurve = CurvedAnimation(
      parent: _animController,
      curve: Curves.fastOutSlowIn,
    );

    _animController.addListener(() {
      _dragNotifier.value = _animStart + (_animEnd - _animStart) * _animCurve.value;
    });

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_animEnd < -300) {
          // Card flew off the top
          if (_currentIndex < _totalCards - 1) {
            setState(() {
              _currentIndex++;
              _dragNotifier.value = 0.0;
            });
          } else {
            _goToDashboard();
          }
        }
      }
    });

    // Build cached cards once to prevent repeated rebuilds
    _cachedCards = [
      _buildCardFrame(0, _buildRealityCardContent()),
      _buildCardFrame(1, _buildDiagnosisCardContent()),
      _buildCardFrame(2, _buildTargetCardContent()),
    ];
  }

  @override
  void dispose() {
    _animController.dispose();
    _dragNotifier.dispose();
    super.dispose();
  }

  void _goToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DiaryDetailPage(diary: widget.diary),
      ),
    );
  }

  void _flyOutTop() {
    if (_animController.isAnimating) return;
    
    if (_currentIndex == _totalCards - 1) {
      _goToDashboard();
      return;
    }

    _animStart = _dragNotifier.value;
    _animEnd = -850.0; // Fly high off screen
    _animController.duration = const Duration(milliseconds: 240);
    _animController.forward(from: 0.0);
  }

  void _springBack() {
    if (_animController.isAnimating) return;
    _animStart = _dragNotifier.value;
    _animEnd = 0.0;
    _animController.duration = const Duration(milliseconds: 200);
    _animController.forward(from: 0.0);
  }

  void _swipeDownPrevious() {
    if (_currentIndex > 0 && !_animController.isAnimating) {
      setState(() {
        _currentIndex--;
      });
      _animStart = -700.0;
      _animEnd = 0.0;
      _animController.duration = const Duration(milliseconds: 260);
      _animController.forward(from: 0.0);
    }
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    if (_animController.isAnimating) return;
    double nextVal = _dragNotifier.value + details.delta.dy;
    if (nextVal > 60 && _currentIndex == 0) {
      nextVal = 60; // Resistance at first card
    }
    _dragNotifier.value = nextVal;
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    if (_animController.isAnimating) return;

    final velocity = details.primaryVelocity ?? 0;
    final currentOffset = _dragNotifier.value;

    if (currentOffset < -70 || velocity < -400) {
      _flyOutTop();
    } else if (currentOffset > 70 && _currentIndex > 0) {
      _swipeDownPrevious();
    } else {
      _springBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Clean Light Desk canvas
      body: SafeArea(
        child: Column(
          children: [
            // Top Clean Minimal Header (Close and Skip)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.titleText, size: 24),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    onPressed: () => Navigator.pop(context),
                  ),

                  // Skip to Dashboard
                  GestureDetector(
                    onTap: _goToDashboard,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.titleText.withValues(alpha: 0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          )
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'SKIP',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.fast_forward_rounded, color: AppColors.primaryBlue, size: 14),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Center Area: High Performance Stack of Sticky Notes
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragUpdate: _handleVerticalDragUpdate,
                onVerticalDragEnd: _handleVerticalDragEnd,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: AnimatedBuilder(
                    animation: _dragNotifier,
                    builder: (context, _) {
                      final dragVal = _dragNotifier.value;

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          for (int i = _totalCards - 1; i >= _currentIndex; i--)
                            _buildAnimatedCardLayer(i, dragVal),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            // Bottom Area: Simple Swipe Up Instruction or Final Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
              child: _currentIndex == _totalCards - 1
                  ? SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _goToDashboard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'BUKA FULL DASHBOARD',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: _flyOutTop,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.titleText.withValues(alpha: 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.keyboard_double_arrow_up_rounded, size: 18, color: AppColors.primaryBlue),
                            SizedBox(width: 6),
                            Text(
                              'Tarik ke atas untuk lembar berikutnya',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.mutedText,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // BUTTERY SMOOTH TRANSFORM LAYER FOR EACH STACKED CARD
  // ==========================================================
  Widget _buildAnimatedCardLayer(int cardIndex, double currentDragOffset) {
    final bool isTopCard = cardIndex == _currentIndex;
    final int positionFromTop = cardIndex - _currentIndex;

    // Static depth offsets for background cards
    final double baseScale = math.max(0.86, 1.0 - (positionFromTop * 0.05));
    final double baseYOffset = positionFromTop * 14.0;
    
    final List<double> rotations = [-0.015, 0.02, -0.01];
    final double baseRotation = rotations[cardIndex % rotations.length];

    double activeYOffset = baseYOffset;
    double activeRotation = baseRotation;
    double cardOpacity = 1.0;

    if (isTopCard) {
      activeYOffset = currentDragOffset;
      activeRotation = baseRotation + (currentDragOffset / 1800.0);
      if (currentDragOffset < 0) {
        cardOpacity = (1.0 - (currentDragOffset.abs() / 700.0)).clamp(0.0, 1.0);
      }
    } else if (positionFromTop == 1 && currentDragOffset < 0) {
      // Smoothly scale up the 2nd card as top card is dragged away
      final double progress = (currentDragOffset.abs() / 300.0).clamp(0.0, 1.0);
      activeYOffset = baseYOffset * (1.0 - progress);
    }

    return Transform.translate(
      offset: Offset(0, activeYOffset),
      child: Transform.rotate(
        angle: activeRotation,
        child: Transform.scale(
          scale: isTopCard ? 1.0 : baseScale,
          child: Opacity(
            opacity: cardOpacity,
            child: _cachedCards[cardIndex],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // STICKY NOTE FRAME (RepaintBoundary for Hardware Acceleration)
  // ==========================================================
  Widget _buildCardFrame(int cardIndex, Widget childContent) {
    final List<Color> headerTapeColors = [
      const Color(0xFF60A5FA), // Blue tape for Reality
      const Color(0xFFFBBF24), // Amber tape for Diagnosis
      const Color(0xFF34D399), // Emerald tape for Target
    ];
    final Color tapeColor = headerTapeColors[cardIndex % headerTapeColors.length];

    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 520),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x120F172A),
              blurRadius: 16,
              spreadRadius: 1,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Sticky Note Paper Top Tape Accent
            Positioned(
              top: -6,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 84,
                  height: 12,
                  decoration: BoxDecoration(
                    color: tapeColor.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),

            // Note Content
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'STICKY NOTE ${cardIndex + 1} / $_totalCards',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.mutedText,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const Icon(Icons.push_pin_rounded, size: 16, color: Color(0xFF94A3B8)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: childContent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 1. Reality Note Content
  Widget _buildRealityCardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.military_tech_rounded, color: AppColors.primaryBlue, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The Reality',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.titleText,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'Fakta & Angka Harian',
                    style: TextStyle(fontSize: 12, color: AppColors.mutedText, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        ..._parsed.realityMetrics.map((m) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: m.bgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(m.icon, color: m.color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.title,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.mutedText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          m.value,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppColors.titleText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),

        if (_parsed.realitySummary.isNotEmpty) ...[
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Text(
              _parsed.realitySummary,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF1E40AF),
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // 2. Diagnosis Note Content
  Widget _buildDiagnosisCardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.psychology_rounded, color: Color(0xFFD97706), size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Honest Diagnosis',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.titleText,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'Penyebab & Pola Prokrastinasi',
                    style: TextStyle(fontSize: 12, color: AppColors.mutedText, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (_parsed.diagnosisText.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFCD34D)),
            ),
            child: Text(
              _parsed.diagnosisText,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF78350F),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        ..._parsed.diagnosisPoints.map((point) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD97706),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    point.replaceAll('*', ''),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.bodyText,
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // 3. Single Target Mission Content
  Widget _buildTargetCardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF059669).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.rocket_launch_rounded, color: Color(0xFF059669), size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tomorrow’s Target',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.titleText,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'Misi 5 Menit Penyelamat',
                    style: TextStyle(fontSize: 12, color: AppColors.mutedText, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF065F46),
                Color(0xFF047857),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33059669),
                blurRadius: 12,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.flag_rounded, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _parsed.targetMissionTitle,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _parsed.targetMissionDescription.replaceAll('*', ''),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFECFDF5),
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Row(
            children: [
              Icon(Icons.bolt_rounded, color: AppColors.primaryBlue, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Siap melanjutkan esok hari? Buka analitik penuh di dashboard!',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.bodyText,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
