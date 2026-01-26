import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_fonts.dart';

/// Simple lock screen overlay
/// This is a basic implementation - will be enhanced in Phase 5
class LockScreen extends StatelessWidget {
  final String lockedAppName;

  const LockScreen({
    super.key,
    required this.lockedAppName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lockScreenBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock,
              size: AppConstants.iconSizeXl,
              color: AppColors.lockScreenAccent,
            ),
            const SizedBox(height: AppConstants.spacingLg),
            Text(
              AppStrings.appLocked,
              style: TextStyle(
                fontSize: AppFonts.size3xl,
                fontWeight: FontWeight.bold,
                color: AppColors.lockScreenText,
                fontFamily: AppFonts.primary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              AppStrings.testLockScreen,
              style: TextStyle(
                fontSize: AppFonts.sizeBase,
                color: AppColors.lockScreenText,
                fontFamily: AppFonts.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingXl),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement unlock logic in Phase 5
                Navigator.of(context).pop();
              },
              child: Text(AppStrings.unlock),
            ),
          ],
        ),
      ),
    );
  }
}
