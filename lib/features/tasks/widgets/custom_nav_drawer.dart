import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../diary/pages/diary_history_page.dart';
import '../../settings/pages/settings_page.dart';

class CustomNavDrawer extends StatelessWidget {
  final VoidCallback? onResetSession;

  const CustomNavDrawer({super.key, this.onResetSession});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: AppColors.softBlueTint,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: AppColors.primaryBlue, size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Farhan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.titleText,
                        ),
                      ),
                      Text(
                        'Focus & Accountability',
                        style: TextStyle(fontSize: 12, color: AppColors.mutedText),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const Divider(color: AppColors.border),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined, color: AppColors.primaryBlue),
              title: const Text(
                'Workspace Dashboard',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.menu_book_rounded, color: AppColors.primaryBlue),
              title: const Text(
                'Auto-Diary History',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.titleText),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DiaryHistoryPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: AppColors.primaryBlue),
              title: const Text(
                'Settings',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.titleText),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'KaryaFlow v1.0.0',
                    style: TextStyle(fontSize: 12, color: AppColors.mutedText, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
