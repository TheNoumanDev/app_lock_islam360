import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/onboarding_provider.dart';
import '../../../core/router/app_router.dart';
import '../widgets/onboarding_page.dart';
import '../widgets/permissions_slide.dart';

/// Onboarding screen with 6 slides (matching Figma design + permissions)
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _slides = [
    _SlideData(
      icon: Icons.shield_outlined,
      iconColor: AppColors.primary,
      iconBgColor: Color(0xFFE3F2FD),
      title: AppStrings.onboardingTitle1,
      description: AppStrings.onboardingDesc1,
    ),
    _SlideData(
      icon: Icons.menu_book_outlined,
      iconColor: AppColors.purple,
      iconBgColor: AppColors.purpleLight,
      title: AppStrings.onboardingTitle2,
      description: AppStrings.onboardingDesc2,
    ),
    _SlideData(
      icon: Icons.alarm,
      iconColor: AppColors.orange,
      iconBgColor: AppColors.orangeLight,
      title: AppStrings.onboardingTitle3,
      description: AppStrings.onboardingDesc3,
    ),
    _SlideData(
      icon: Icons.menu_book,
      iconColor: AppColors.green,
      iconBgColor: AppColors.greenLight,
      title: AppStrings.onboardingTitle4,
      description: AppStrings.onboardingDesc4,
    ),
    // Permissions slide (index 4)
    _SlideData(
      icon: Icons.security,
      iconColor: AppColors.primary,
      iconBgColor: Color(0xFFE3F2FD),
      title: AppStrings.onboardingTitlePermissions,
      description: AppStrings.onboardingDescPermissions,
      isPermissionsSlide: true,
    ),
    _SlideData(
      icon: Icons.favorite_outline,
      iconColor: Color(0xFFC2185B),
      iconBgColor: Color(0xFFFCE4EC),
      title: AppStrings.onboardingTitle5,
      description: AppStrings.onboardingDesc5,
      hasSubscription: true,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.animationNormal,
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    ref.read(onboardingCompleteProvider.notifier).completeOnboarding();
    context.go(RoutePaths.home);
  }

  @override
  Widget build(BuildContext context) {
    final isLastSlide = _currentPage == _slides.length - 1;
    final slide = _slides[_currentPage];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingMd),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    AppStrings.skip,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
            ),
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final s = _slides[index];
                  // Use custom widget for permissions slide
                  if (s.isPermissionsSlide) {
                    return const PermissionsSlide();
                  }
                  return OnboardingPage(
                    icon: s.icon,
                    iconColor: s.iconColor,
                    iconBackgroundColor: s.iconBgColor,
                    title: s.title,
                    description: s.description,
                    bottomWidget: s.hasSubscription
                        ? _buildSubscriptionCard(context)
                        : null,
                  );
                },
              ),
            ),
            // Bottom section
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spacingXl,
                0,
                AppConstants.spacingXl,
                AppConstants.spacing2xl,
              ),
              child: Column(
                children: [
                  // Dot indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: AppConstants.animationFast,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppConstants.spacingLg),
                  // Next / Get Started / Continue free
                  if (slide.hasSubscription)
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: const Text(
                        AppStrings.onboardingContinueFree,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: _onNext,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusXl,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isLastSlide
                                  ? AppStrings.onboardingGetStarted
                                  : AppStrings.next,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right, size: 20),
                          ],
                        ),
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

  Widget _buildSubscriptionCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE3F2FD), AppColors.purpleLight],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radius2xl),
        border: Border.all(color: const Color(0xFFBBDEFB), width: 2),
      ),
      child: Column(
        children: [
          const Text(
            AppStrings.onboardingPrice,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: () {
                // TODO: Implement subscription
              },
              child: const Text(AppStrings.onboardingSubscribeNow),
            ),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            AppStrings.onboardingCancelAnytime,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _SlideData {
  const _SlideData({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.description,
    this.hasSubscription = false,
    this.isPermissionsSlide = false,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String description;
  final bool hasSubscription;
  final bool isPermissionsSlide;
}
