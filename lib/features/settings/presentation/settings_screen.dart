import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers/history_provider.dart';
import '../../../app/providers/library_provider.dart';
import '../../../app/providers/settings_provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/permissions/permission_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        title: Text('Settings', style: AppTypography.screenTitle),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        children: [
          // Section 1: Library & System Permissions
          _buildSectionHeader('Library & Permissions'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.elevatedSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.sync_rounded, color: AppColors.secondaryAccent),
                  title: const Text('Rescan Music Library'),
                  subtitle: const Text('Scan device storage and MediaStore for new tracks'),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.subtleText),
                  onTap: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Scanning device storage...')),
                    );
                    await ref.read(libraryProvider.notifier).scanLibrary();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Library scan completed!')),
                    );
                  },
                ),
                const Divider(color: AppColors.divider),
                ListTile(
                  leading: Icon(
                    settings.permissionGranted ? Icons.check_circle_rounded : Icons.warning_rounded,
                    color: settings.permissionGranted ? AppColors.success : AppColors.warning,
                  ),
                  title: const Text('Audio Storage Permissions'),
                  subtitle: Text(
                    settings.permissionGranted ? 'Granted (READ_MEDIA_AUDIO)' : 'Permission Required',
                  ),
                  trailing: TextButton(
                    onPressed: () {
                      PermissionService.instance.openAppSettingsPage();
                    },
                    child: const Text('System Info', style: TextStyle(color: AppColors.secondaryAccent)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section 2: Experience & Motion
          _buildSectionHeader('Visuals & Motion'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.elevatedSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  activeColor: AppColors.secondaryAccent,
                  secondary: const Icon(Icons.motion_photos_off_rounded, color: AppColors.primaryAccent),
                  title: const Text('Reduced Motion'),
                  subtitle: const Text('Disables 3D perspective tilt and floating orb animation'),
                  value: settings.reducedMotion,
                  onChanged: (val) {
                    ref.read(settingsProvider.notifier).toggleReducedMotion(val);
                  },
                ),
                const Divider(color: AppColors.divider),
                SwitchListTile(
                  activeColor: AppColors.secondaryAccent,
                  secondary: const Icon(Icons.history_toggle_off_rounded, color: AppColors.secondaryAccent),
                  title: const Text('Auto-Resume Last Session'),
                  subtitle: const Text('Restores previous queue and playback timestamp upon reopening'),
                  value: settings.autoResume,
                  onChanged: (val) {
                    ref.read(settingsProvider.notifier).toggleAutoResume(val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section 3: Data Management & Privacy
          _buildSectionHeader('Data Management & Privacy'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.elevatedSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.file_download_outlined, color: AppColors.secondaryAccent),
                  title: const Text('Export Listening History (JSON)'),
                  subtitle: const Text('Back up your listening events and completion stats'),
                  onTap: () async {
                    final json = await ref.read(historyProvider.notifier).exportHistoryJson();
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Listening History Export'),
                        content: SingleChildScrollView(
                          child: SelectableText(json, style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(color: AppColors.divider),
                ListTile(
                  leading: const Icon(Icons.delete_forever_rounded, color: AppColors.error),
                  title: const Text('Clear Song History', style: TextStyle(color: AppColors.error)),
                  subtitle: const Text('Erase all listening analytics from device'),
                  onTap: () => _confirmClearHistory(context, ref),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section 4: Privacy Statement & About
          _buildSectionHeader('Privacy Policy & About'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.elevatedSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.security_rounded, color: AppColors.success, size: 20),
                    const SizedBox(width: 8),
                    Text('Local Privacy Guarantee', style: AppTypography.songTitleMedium),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'VYBE 3D is strictly an offline-first personal music player. No accounts, no external tracking, no cloud metrics, and no uploading of your private songs or listening logs.',
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 14),
                const Divider(color: AppColors.divider),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Version', style: AppTypography.metadata),
                    Text('${AppConstants.appName} v${AppConstants.appVersion}', style: AppTypography.metadata),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 36),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.badgeText.copyWith(
          color: AppColors.secondaryAccent,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  void _confirmClearHistory(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear History?'),
        content: const Text('Are you sure you want to permanently erase all listening records? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.secondaryText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(historyProvider.notifier).clearAllHistory();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Listening history cleared')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
