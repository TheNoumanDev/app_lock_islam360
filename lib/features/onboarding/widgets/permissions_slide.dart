import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/permissions_provider.dart';

/// Onboarding slide for granting app permissions
class PermissionsSlide extends ConsumerStatefulWidget {
  const PermissionsSlide({super.key});

  @override
  ConsumerState<PermissionsSlide> createState() => _PermissionsSlideState();
}

class _PermissionsSlideState extends ConsumerState<PermissionsSlide>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Check permissions on init
    Future.microtask(() {
      ref.read(permissionsProvider.notifier).checkAllPermissions();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check permissions when user returns from settings
    if (state == AppLifecycleState.resumed) {
      ref.read(permissionsProvider.notifier).checkAllPermissions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissions = ref.watch(permissionsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: AppConstants.spacingLg),
          // Icon circle
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.security,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingLg),
          // Title
          Text(
            AppStrings.onboardingTitlePermissions,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingMd),
          // Description
          Text(
            AppStrings.onboardingDescPermissions,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingLg),
          // Permission cards
          _PermissionCard(
            icon: Icons.accessibility_new,
            title: AppStrings.permissionAccessibility,
            description: AppStrings.permissionAccessibilityDesc,
            isGranted: permissions.accessibilityEnabled,
            isRequired: true,
            onTap: () {
              ref.read(permissionsProvider.notifier).requestAccessibility();
            },
          ),
          const SizedBox(height: AppConstants.spacingMd),
          _PermissionCard(
            icon: Icons.layers_outlined,
            title: AppStrings.permissionOverlay,
            description: AppStrings.permissionOverlayDesc,
            isGranted: permissions.overlayEnabled,
            isRequired: true,
            onTap: () {
              ref.read(permissionsProvider.notifier).requestOverlay();
            },
          ),
          const SizedBox(height: AppConstants.spacingMd),
          _PermissionCard(
            icon: Icons.notifications_outlined,
            title: AppStrings.permissionNotification,
            description: AppStrings.permissionNotificationDesc,
            isGranted: permissions.notificationEnabled,
            isRequired: false,
            onTap: () {
              ref.read(permissionsProvider.notifier).requestNotification();
            },
          ),
          const SizedBox(height: AppConstants.spacingLg),
        ],
      ),
    );
  }
}

/// Individual permission card with checkbox
class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isGranted,
    required this.isRequired,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool isGranted;
  final bool isRequired;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isGranted ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      child: InkWell(
        onTap: isGranted ? null : onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            border: Border.all(
              color: isGranted ? AppColors.primary : Colors.grey.shade200,
              width: isGranted ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isGranted
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
                child: Icon(
                  icon,
                  color: isGranted ? AppColors.primary : Colors.grey.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isGranted ? AppColors.primary : Colors.black87,
                            ),
                          ),
                        ),
                        if (!isGranted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isRequired
                                  ? AppColors.error.withValues(alpha: 0.1)
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isRequired
                                  ? AppStrings.permissionRequired
                                  : AppStrings.permissionOptional,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isRequired
                                    ? AppColors.error
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isGranted ? AppStrings.permissionGranted : description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isGranted
                            ? AppColors.success
                            : Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spacingSm),
              // Checkbox / Chevron
              if (isGranted)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  ),
                )
              else
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
