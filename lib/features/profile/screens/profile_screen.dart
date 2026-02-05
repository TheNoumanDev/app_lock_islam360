import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';

/// Profile screen with achievements and settings (Figma: ProfileScreen)
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          children: [
            // Avatar
            const CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, size: 48, color: Colors.white),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              'User',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            // Achievements section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppStrings.profileAchievements,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            _buildAchievementsGrid(),
            const SizedBox(height: AppConstants.spacingLg),
            // Settings list
            _buildSettingsTile(
              context,
              icon: Icons.notifications_outlined,
              label: AppStrings.profileNotifications,
            ),
            _buildSettingsTile(
              context,
              icon: Icons.palette_outlined,
              label: AppStrings.profileAppearance,
            ),
            _buildSettingsTile(
              context,
              icon: Icons.info_outline,
              label: AppStrings.profileAbout,
            ),
            _buildSettingsTile(
              context,
              icon: Icons.privacy_tip_outlined,
              label: AppStrings.profilePrivacy,
            ),
            _buildSettingsTile(
              context,
              icon: Icons.description_outlined,
              label: AppStrings.profileTerms,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _AchievementBadge(
          icon: Icons.local_fire_department,
          label: '0 Days',
          color: AppColors.orange,
        ),
        _AchievementBadge(
          icon: Icons.menu_book,
          label: '0 Ayat',
          color: AppColors.green,
        ),
        _AchievementBadge(
          icon: Icons.shield,
          label: '0 Locks',
          color: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        // Placeholder - settings actions will be added later
      },
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
