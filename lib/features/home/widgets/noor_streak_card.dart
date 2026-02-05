import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';

/// 2x2 grid showing streak stats (Figma: Noor Streaks)
class NoorStreakCard extends StatelessWidget {
  const NoorStreakCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppConstants.spacingMd,
      crossAxisSpacing: AppConstants.spacingMd,
      childAspectRatio: 1.4,
      children: const [
        _StreakTile(
          label: AppStrings.homeAppLockReflections,
          value: '0',
          icon: Icons.shield_outlined,
          color: AppColors.primary,
          bgColor: Color(0xFFE3F2FD),
        ),
        _StreakTile(
          label: AppStrings.homeNamazStreak,
          value: '0',
          icon: Icons.mosque_outlined,
          color: AppColors.green,
          bgColor: AppColors.greenLight,
        ),
        _StreakTile(
          label: AppStrings.homeAyatReadings,
          value: '0',
          icon: Icons.menu_book_outlined,
          color: AppColors.purple,
          bgColor: AppColors.purpleLight,
        ),
        _StreakTile(
          label: AppStrings.homeDailyEngagement,
          value: '0',
          icon: Icons.trending_up,
          color: AppColors.orange,
          bgColor: AppColors.orangeLight,
        ),
      ],
    );
  }
}

class _StreakTile extends StatelessWidget {
  const _StreakTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
