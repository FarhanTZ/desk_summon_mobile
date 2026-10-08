import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class LaptopStatusCard extends StatelessWidget {
  final Stream<List<Map<String, dynamic>>> sessionStream;

  const LaptopStatusCard({super.key, required this.sessionStream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: sessionStream,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final state = (data != null && data.isNotEmpty)
            ? data.first['state'] ?? 'IDLE'
            : 'IDLE';
        final topic = (data != null && data.isNotEmpty)
            ? data.first['topic'] ?? '-'
            : '-';

        Color badgeBg = AppColors.slateTint;
        Color badgeText = AppColors.mutedText;

        if (state == 'FOCUSING') {
          badgeBg = AppColors.doneGreenBg;
          badgeText = AppColors.doneGreen;
        } else if (state == 'SURRENDERED') {
          badgeBg = const Color(0xFFFFF7ED);
          badgeText = const Color(0xFFD97706);
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.titleText.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: state == 'FOCUSING'
                          ? AppColors.doneGreen
                          : AppColors.placeholderText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'LAPTOP WORKSPACE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.mutedText,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        state == 'FOCUSING' ? topic : 'Laptop on Standby',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.titleText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  state,
                  style: TextStyle(
                    color: badgeText,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
