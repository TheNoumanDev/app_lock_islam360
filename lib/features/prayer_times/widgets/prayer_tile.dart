import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Prayer tile states
enum PrayerTileState {
  completed,  // Blue fill with checkmark
  current,    // Blue border only
  upcoming,   // Gray/light background
}

/// Individual prayer time tile widget
class PrayerTile extends StatelessWidget {
  const PrayerTile({
    super.key,
    required this.name,
    required this.time,
    required this.state,
  });

  final String name;
  final String time;
  final PrayerTileState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        border: state == PrayerTileState.current
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getTextColor(),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _getTextColor(),
            ),
          ),
          if (state == PrayerTileState.completed) ...[
            const SizedBox(height: 4),
            Icon(
              Icons.check,
              size: 16,
              color: Colors.white,
            ),
          ],
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (state) {
      case PrayerTileState.completed:
        return AppColors.primary;
      case PrayerTileState.current:
        return Colors.transparent;
      case PrayerTileState.upcoming:
        return Colors.grey.shade100;
    }
  }

  Color _getTextColor() {
    switch (state) {
      case PrayerTileState.completed:
        return Colors.white;
      case PrayerTileState.current:
        return AppColors.primary;
      case PrayerTileState.upcoming:
        return Colors.grey.shade600;
    }
  }
}
