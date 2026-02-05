import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../widgets/prayer_tile.dart';

/// Full Prayer Times screen with live countdown and Islamic date
class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  Timer? _timer;
  Duration _timeUntilNextPrayer = Duration.zero;
  int _currentPrayerIndex = 0;
  final String _location = 'Karachi';
  final String _madhab = AppStrings.prayerHanafi;

  // Mock prayer times (will be replaced with actual prayer times API)
  final List<_PrayerData> _prayers = [
    _PrayerData(AppStrings.prayerFajr, const TimeOfDay(hour: 5, minute: 30)),
    _PrayerData(AppStrings.prayerDhuhr, const TimeOfDay(hour: 12, minute: 45)),
    _PrayerData(AppStrings.prayerAsr, const TimeOfDay(hour: 15, minute: 30)),
    _PrayerData(AppStrings.prayerMaghrib, const TimeOfDay(hour: 18, minute: 15)),
    _PrayerData(AppStrings.prayerIsha, const TimeOfDay(hour: 19, minute: 45)),
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

    for (int i = 0; i < _prayers.length; i++) {
      final prayer = _prayers[i];
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
      hours: _prayers.first.time.hour,
      minutes: _prayers.first.time.minute,
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
    final nextIndex = (_currentPrayerIndex + 1) % _prayers.length;
    return _prayers[nextIndex].name;
  }

  PrayerTileState _getTileState(int index) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final prayerDateTime = today.add(Duration(
      hours: _prayers[index].time.hour,
      minutes: _prayers[index].time.minute,
    ));

    if (index == _currentPrayerIndex) {
      return PrayerTileState.current;
    } else if (prayerDateTime.isBefore(now)) {
      return PrayerTileState.completed;
    } else {
      return PrayerTileState.upcoming;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hijriDate = HijriCalendar.now();
    final gregorianDate = DateTime.now();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Column(
            children: [
              // Date header
              _buildDateHeader(hijriDate, gregorianDate),
              const SizedBox(height: AppConstants.spacingLg),
              // Main prayer card
              Expanded(
                child: _buildPrayerCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateHeader(HijriCalendar hijri, DateTime gregorian) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final gregorianStr = '${gregorian.day} ${months[gregorian.month - 1]} ${gregorian.year}';
    final hijriStr = '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} AH';

    return Column(
      children: [
        Text(
          hijriStr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          gregorianStr,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppConstants.radius2xl),
      ),
      child: Column(
        children: [
          // Location and Madhab row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    _location,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _madhab,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Upcoming label
          Text(
            AppStrings.prayerUpcoming,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          // Current prayer name
          Text(
            _prayers[_currentPrayerIndex].name,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          // Countdown timer
          Text(
            _formatCountdown(_timeUntilNextPrayer),
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 8),
          // Until next prayer
          Text(
            '${AppStrings.prayerUntil} ${_getNextPrayerName()}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const Spacer(),
          // Prayer tiles row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_prayers.length, (index) {
              return PrayerTile(
                name: _prayers[index].name,
                time: _formatTime(_prayers[index].time),
                state: _getTileState(index),
              );
            }),
          ),
          const SizedBox(height: AppConstants.spacingMd),
        ],
      ),
    );
  }
}

class _PrayerData {
  final String name;
  final TimeOfDay time;

  _PrayerData(this.name, this.time);
}
