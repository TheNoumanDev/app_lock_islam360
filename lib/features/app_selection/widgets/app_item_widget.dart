import 'package:flutter/material.dart';
import '../../../core/models/app_info.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_fonts.dart';

/// Widget for displaying a single app in the app selection list
class AppItemWidget extends StatelessWidget {
  final AppInfo app;
  final bool isSelected;
  final VoidCallback onTap;

  const AppItemWidget({
    super.key,
    required this.app,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMd,
          vertical: AppConstants.spacingSm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
        child: Row(
          children: [
            // App Icon (placeholder - will be enhanced later with actual app icons)
            Container(
              width: AppConstants.iconSizeLg,
              height: AppConstants.iconSizeLg,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                color: AppColors.border,
              ),
              child: Icon(
                Icons.android,
                size: AppConstants.iconSizeMd,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppConstants.spacingMd),
            // App Name
            Expanded(
              child: Text(
                app.appName,
                style: TextStyle(
                  fontSize: AppFonts.sizeBase,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  fontFamily: AppFonts.primary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Selection Indicator
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: AppConstants.iconSizeMd,
              )
            else
              Icon(
                Icons.circle_outlined,
                color: AppColors.border,
                size: AppConstants.iconSizeMd,
              ),
          ],
        ),
      ),
    );
  }
}
