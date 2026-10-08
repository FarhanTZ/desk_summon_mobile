import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/notification_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _routineRemindersEnabled = true;
  bool _accountabilityAlertsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.titleText, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppColors.titleText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          physics: const BouncingScrollPhysics(),
          children: [
            // Section 1: Notifications
            const Text(
              'NOTIFICATIONS & REMINDERS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.mutedText,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    activeColor: const Color(0xFF059669),
                    value: _routineRemindersEnabled,
                    onChanged: (val) {
                      setState(() => _routineRemindersEnabled = val);
                      if (!val) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pengingat rutinitas dinonaktifkan.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.alarm_rounded, color: Color(0xFF059669), size: 22),
                    ),
                    title: const Text(
                      'Daily Routine Reminders',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.titleText),
                    ),
                    subtitle: const Text(
                      'Pengingat otomatis 10 menit sebelum rutinitas dimulai',
                      style: TextStyle(fontSize: 12, color: AppColors.mutedText),
                    ),
                  ),
                  const Divider(height: 1, indent: 64, color: AppColors.border),
                  SwitchListTile(
                    activeColor: AppColors.primaryBlue,
                    value: _accountabilityAlertsEnabled,
                    onChanged: (val) {
                      setState(() => _accountabilityAlertsEnabled = val);
                    },
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.laptop_chromebook_rounded, color: AppColors.primaryBlue, size: 22),
                    ),
                    title: const Text(
                      'AI Accountability Alerts',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.titleText),
                    ),
                    subtitle: const Text(
                      'Pemberitahuan realtime sesi laptop dan summon task',
                      style: TextStyle(fontSize: 12, color: AppColors.mutedText),
                    ),
                  ),
                  const Divider(height: 1, indent: 64, color: AppColors.border),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.volume_up_rounded, color: Color(0xFF6366F1), size: 22),
                    ),
                    title: const Text(
                      'Test Notifikasi Suara',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.titleText),
                    ),
                    subtitle: const Text(
                      'Uji pemutaran nada dering custom dan getaran',
                      style: TextStyle(fontSize: 12, color: AppColors.mutedText),
                    ),
                    trailing: const Icon(Icons.play_arrow_rounded, color: Color(0xFF6366F1), size: 24),
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final notif = NotificationService();
                      final success = await notif.showInstantNotification(
                        title: 'KaryaFlow: Notifikasi Aktif',
                        body: 'Notifikasi suara dan getar berhasil beroperasi dengan normal.',
                      );
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(success ? 'Notifikasi tes berhasil dikirim! Periksa bar notifikasi HP Anda.' : 'Gagal mengirim notifikasi. Pastikan izin notifikasi aktif.'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: success ? AppColors.titleText : AppColors.dangerRed,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Section 2: Application Info
            const Text(
              'APPLICATION & SYNC',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.mutedText,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.info_outline_rounded, color: AppColors.primaryBlue, size: 22),
                    ),
                    title: const Text(
                      'App Name & Version',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.titleText),
                    ),
                    trailing: const Text(
                      'KaryaFlow v1.0.0',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.mutedText),
                    ),
                  ),
                  const Divider(height: 1, indent: 64, color: AppColors.border),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.cloud_done_rounded, color: Color(0xFF059669), size: 22),
                    ),
                    title: const Text(
                      'Sync Status',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.titleText),
                    ),
                    trailing: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, color: Color(0xFF059669), size: 10),
                        SizedBox(width: 6),
                        Text(
                          'Online',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF059669)),
                        ),
                      ],
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
}
