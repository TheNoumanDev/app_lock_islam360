import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';

/// Quick action buttons row (Figma: Quick Actions)
class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _ActionButton(
          icon: Icons.shield_outlined,
          label: 'Lock Apps',
          color: AppColors.primary,
          onTap: () => context.go(RoutePaths.apps),
        ),
        _ActionButton(
          icon: Icons.alarm,
          label: 'Alarms',
          color: AppColors.orange,
          onTap: () => context.go(RoutePaths.alarms),
        ),
        _ActionButton(
          icon: Icons.mosque_outlined,
          label: 'Prayer',
          color: AppColors.green,
          onTap: () => context.go(RoutePaths.prayer),
        ),
        _ActionButton(
          icon: Icons.menu_book_outlined,
          label: 'Quran',
          color: AppColors.purple,
          onTap: () => context.go(RoutePaths.quran),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
