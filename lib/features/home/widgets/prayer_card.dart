import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';

/// Compact prayer card with all prayer times for home screen
class PrayerCard extends StatefulWidget {
  const PrayerCard({super.key});

  @override
  State<PrayerCard> createState() => _PrayerCardState();
}

class _PrayerCardState extends State<PrayerCard> {
  Timer? _timer;
  Duration _timeUntilNextPrayer = Duration.zero;
  int _currentPrayerIndex = 0;
  final String _location = 'Karachi';
  final String _madhab = AppStrings.prayerHanafi;

  // Mock prayer times (will be replaced with actual prayer times service)
  final List<_PrayerTime> _prayerTimes = [
    _PrayerTime(AppStrings.prayerFajr, const TimeOfDay(hour: 5, minute: 30)),
    _PrayerTime(AppStrings.prayerDhuhr, const TimeOfDay(hour: 12, minute: 45)),
    _PrayerTime(AppStrings.prayerAsr, const TimeOfDay(hour: 15, minute: 30)),
    _PrayerTime(AppStrings.prayerMaghrib, const TimeOfDay(hour: 18, minute: 15)),
    _PrayerTime(AppStrings.prayerIsha, const TimeOfDay(hour: 19, minute: 45)),
  ];

  @override
  void initState() {
    super.initState();
    _calculateCurrentPrayer();
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdownTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (_timeUntilNextPrayer.inSeconds > 0) {
          _timeUntilNextPrayer -= const Duration(seconds: 1);
        } else {
          _calculateCurrentPrayer();
        }
      });
    });
  }

  void _calculateCurrentPrayer() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (int i = 0; i < _prayerTimes.length; i++) {
      final prayer = _prayerTimes[i];
      final prayerDateTime = today.add(Duration(
        hours: prayer.time.hour,
        minutes: prayer.time.minute,
      ));

      if (prayerDateTime.isAfter(now)) {
        _currentPrayerIndex = i;
        _timeUntilNextPrayer = prayerDateTime.difference(now);
        return;
      }
    }

    // If all prayers passed, show tomorrow's Fajr
    final tomorrowFajr = today.add(Duration(
      days: 1,
      hours: _prayerTimes.first.time.hour,
      minutes: _prayerTimes.first.time.minute,
    ));
    _currentPrayerIndex = 0;
    _timeUntilNextPrayer = tomorrowFajr.difference(now);
  }

  String _formatCountdown(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getNextPrayerName() {
    final nextIndex = (_currentPrayerIndex + 1) % _prayerTimes.length;
    return _prayerTimes[nextIndex].name;
  }

  _TileState _getTileState(int index) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final prayerDateTime = today.add(Duration(
      hours: _prayerTimes[index].time.hour,
      minutes: _prayerTimes[index].time.minute,
    ));

    if (index == _currentPrayerIndex) {
      return _TileState.current;
    } else if (prayerDateTime.isBefore(now)) {
      return _TileState.completed;
    } else {
      return _TileState.upcoming;
    }
  }

  Widget _buildDatesRow() {
    final hijri = HijriCalendar.now();
    final gregorian = DateTime.now();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final gregorianStr = '${gregorian.day} ${months[gregorian.month - 1]} ${gregorian.year}';
    final hijriStr = '${hijri.hDay} ${hijri.shortMonthName} ${hijri.hYear}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          hijriStr,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        Text(
          '  •  ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade400,
          ),
        ),
        Text(
          gregorianStr,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppConstants.radius2xl),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Location and Madhab row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    _location,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _madhab,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSm),
          // Dates row
          _buildDatesRow(),
          const SizedBox(height: AppConstants.spacingMd),
          // Next Prayer label
          Text(
            AppStrings.homeNextPrayer.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          // Current prayer name
          Text(
            _prayerTimes[_currentPrayerIndex].name,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          // Large countdown timer
          Text(
            _formatCountdown(_timeUntilNextPrayer),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          // Until next prayer
          Text(
            '${AppStrings.prayerUntil} ${_getNextPrayerName()}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          // Compact prayer tiles row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_prayerTimes.length, (index) {
              final state = _getTileState(index);
              return _CompactPrayerTile(
                name: _prayerTimes[index].name,
                time: _formatTime(_prayerTimes[index].time),
                state: state,
              );
            }),
          ),
        ],
      ),
    );
  }
}

enum _TileState { completed, current, upcoming }

class _CompactPrayerTile extends StatelessWidget {
  const _CompactPrayerTile({
    required this.name,
    required this.time,
    required this.state,
  });

  final String name;
  final String time;
  final _TileState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(10),
        border: state == _TileState.current
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _getTextColor(),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: _getTextColor(),
            ),
          ),
          if (state == _TileState.completed) ...[
            const SizedBox(height: 2),
            const Icon(Icons.check, size: 12, color: Colors.white),
          ],
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (state) {
      case _TileState.completed:
        return AppColors.primary;
      case _TileState.current:
        return Colors.transparent;
      case _TileState.upcoming:
        return Colors.grey.shade100;
    }
  }

  Color _getTextColor() {
    switch (state) {
      case _TileState.completed:
        return Colors.white;
      case _TileState.current:
        return AppColors.primary;
      case _TileState.upcoming:
        return Colors.grey.shade600;
    }
  }
}

class _PrayerTime {
  final String name;
  final TimeOfDay time;

  _PrayerTime(this.name, this.time);
}
