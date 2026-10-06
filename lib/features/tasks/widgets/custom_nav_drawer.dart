import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CustomNavDrawer extends StatelessWidget {
  final VoidCallback onResetSession;

  const CustomNavDrawer({super.key, required this.onResetSession});

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
              leading: const Icon(Icons.history_toggle_off, color: AppColors.mutedText),
              title: const Text('Auto-Diary History', style: TextStyle(fontSize: 14)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: AppColors.mutedText),
              title: const Text('Settings & Supabase', style: TextStyle(fontSize: 14)),
              onTap: () => Navigator.pop(context),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.power_settings_new, color: AppColors.dangerRed, size: 18),
                  label: const Text(
                    'Reset Laptop Session',
                    style: TextStyle(color: AppColors.dangerRed, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.dangerRedBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    onResetSession();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
