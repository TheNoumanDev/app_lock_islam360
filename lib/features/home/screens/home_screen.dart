import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../widgets/prayer_card.dart';
import '../widgets/noor_streak_card.dart';
import '../widgets/quick_actions_row.dart';
import '../widgets/continue_reading_card.dart';

/// Home screen matching Figma HomeScreen design
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.homeGreeting,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.appTagline,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => context.push(RoutePaths.profile),
                    child: const CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingLg),
              // Next prayer card
              const PrayerCard(),
              const SizedBox(height: AppConstants.spacingMd),
              // Continue reading
              const ContinueReadingCard(),
              const SizedBox(height: AppConstants.spacingLg),
              // Noor Streak section
              Text(
                AppStrings.homeNoorStreak,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppConstants.spacingMd),
              const NoorStreakCard(),
              const SizedBox(height: AppConstants.spacingLg),
              // Quick Actions
              Text(
                AppStrings.homeQuickActions,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppConstants.spacingMd),
              const QuickActionsRow(),
            ],
          ),
        ),
      ),
    );
  }
}
