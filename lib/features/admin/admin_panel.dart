import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../models/app_settings.dart';
import '../../core/constants.dart';

class AdminPanel extends ConsumerWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appSettingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Panel', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(color: AppColors.border, height: 0.5),
        ),
      ),
      body: settingsAsync.when(
        data: (settings) => ListView(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Feature Toggles',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            _buildToggle(
              context,
              ref,
              title: 'Reaction',
              value: settings.showReaction,
              onChanged: (val) => ref.read(firestoreServiceProvider).updateAppSettings(settings.copyWith(showReaction: val)),
            ),
            _buildToggle(
              context,
              ref,
              title: 'Comment',
              value: settings.showComment,
              onChanged: (val) => ref.read(firestoreServiceProvider).updateAppSettings(settings.copyWith(showComment: val)),
            ),
            _buildToggle(
              context,
              ref,
              title: 'Share',
              value: settings.showShare,
              onChanged: (val) => ref.read(firestoreServiceProvider).updateAppSettings(settings.copyWith(showShare: val)),
            ),
            _buildToggle(
              context,
              ref,
              title: 'My Profile',
              value: settings.showFullProfile,
              onChanged: (val) => ref.read(firestoreServiceProvider).updateAppSettings(settings.copyWith(showFullProfile: val)),
            ),
            _buildToggle(
              context,
              ref,
              title: 'Use Perspective API',
              value: settings.usePerspectiveApi,
              onChanged: (val) => ref.read(firestoreServiceProvider).updateAppSettings(settings.copyWith(usePerspectiveApi: val)),
            ),
            _buildToggle(
              context,
              ref,
              title: 'Show Word Counter',
              value: settings.showWordCounter,
              onChanged: (val) => ref.read(firestoreServiceProvider).updateAppSettings(settings.copyWith(showWordCounter: val)),
            ),
            const Divider(height: 32, thickness: 0.5, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Close Admin Panel', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildToggle(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }
}
