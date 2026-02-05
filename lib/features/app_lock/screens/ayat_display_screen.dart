import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/shake_service.dart';
import '../data/islamic_content.dart';

/// Screen that displays Quranic verse or Hadith based on user's feeling
/// Includes countdown timer and shake-to-skip functionality
class AyatDisplayScreen extends StatefulWidget {
  const AyatDisplayScreen({
    super.key,
    required this.feeling,
    required this.appName,
    required this.packageName,
    required this.onComplete,
    required this.onSkip,
  });

  final String feeling;
  final String appName;
  final String packageName;
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  @override
  State<AyatDisplayScreen> createState() => _AyatDisplayScreenState();
}

class _AyatDisplayScreenState extends State<AyatDisplayScreen>
    with TickerProviderStateMixin {
  late final IslamicContent _content;
  late final ShakeService _shakeService;
  int _countdown = 3;
  bool _canContinue = false;
  Timer? _countdownTimer;

  // Animation controllers
  late final AnimationController _arabicAnimController;
  late final AnimationController _translationAnimController;
  late final AnimationController _countdownAnimController;

  late final Animation<double> _arabicFadeAnimation;
  late final Animation<Offset> _arabicSlideAnimation;
  late final Animation<double> _translationFadeAnimation;
  late final Animation<Offset> _translationSlideAnimation;

  @override
  void initState() {
    super.initState();
    _content = getContentForFeeling(widget.feeling);
    _shakeService = ShakeService();

    // Initialize animation controllers
    _arabicAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _translationAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _countdownAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Arabic text animations
    _arabicFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _arabicAnimController, curve: Curves.easeOut),
    );
    _arabicSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _arabicAnimController, curve: Curves.easeOut),
    );

    // Translation card animations (delayed by 200ms)
    _translationFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _translationAnimController, curve: Curves.easeOut),
    );
    _translationSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _translationAnimController, curve: Curves.easeOut),
    );

    // Start animations
    _arabicAnimController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _translationAnimController.forward();
      }
    });

    // Start countdown
    _startCountdown();

    // Start shake detection
    _shakeService.startListening(_onShake);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _arabicAnimController.dispose();
    _translationAnimController.dispose();
    _countdownAnimController.dispose();
    _shakeService.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() => _countdown--);
        _countdownAnimController.forward(from: 0);
      } else {
        timer.cancel();
        setState(() {
          _countdown = 0;
          _canContinue = true;
        });
      }
    });
  }

  void _onShake() {
    // Skip via shake - emergency bypass
    // Navigate to home first to clear the lock screen from navigation stack
    // This ensures reopening the app shows home, not stale lock screen
    context.go(RoutePaths.home);
    widget.onSkip();
  }

  void _handleComplete() {
    // Navigate to home first to clear the lock screen from navigation stack
    // This ensures reopening the app shows home, not stale lock screen
    context.go(RoutePaths.home);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withValues(alpha: 0.1),
              Colors.white,
              Colors.white,
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLg),
            child: Column(
              children: [
                const SizedBox(height: AppConstants.spacingXl),
                // Header
                _buildHeader(),
                const Spacer(),
                // Arabic Text
                _buildArabicText(),
                const SizedBox(height: AppConstants.spacingXl),
                // Translation Card
                _buildTranslationCard(),
                const Spacer(),
                // Countdown or Done section
                _buildCountdownSection(),
                const SizedBox(height: AppConstants.spacingMd),
                // Status Text
                Text(
                  _canContinue ? 'Reflection complete' : 'Take a moment to reflect...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingLg),
                // Done Button
                _buildDoneButton(),
                const SizedBox(height: AppConstants.spacingMd),
                // Skip Hint
                Text(
                  'Shake device to skip in emergencies',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingLg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.menu_book_outlined,
          size: 24,
          color: AppColors.primary,
        ),
        const SizedBox(width: AppConstants.spacingSm),
        Text(
          _content.type == ContentType.ayat ? 'QURANIC VERSE' : 'HADITH',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildArabicText() {
    return FadeTransition(
      opacity: _arabicFadeAnimation,
      child: SlideTransition(
        position: _arabicSlideAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
          child: Text(
            _content.arabic,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w500,
              height: 1.8,
              color: Colors.black87,
              fontFamily: 'serif',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTranslationCard() {
    return FadeTransition(
      opacity: _translationFadeAnimation,
      child: SlideTransition(
        position: _translationSlideAnimation,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(AppConstants.radiusXl),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.6,
                    color: Colors.grey.shade700,
                  ),
                  children: [
                    TextSpan(
                      text: '"',
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    TextSpan(text: _content.translation),
                    TextSpan(
                      text: '"',
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacingMd),
              Text(
                _content.reference,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownSection() {
    if (_canContinue) {
      return const SizedBox(height: 80);
    }

    return AnimatedBuilder(
      animation: _countdownAnimController,
      builder: (context, child) {
        final scale = 1.0 + (_countdownAnimController.value * 0.3);
        return Transform.scale(
          scale: 2.0 - scale,
          child: child,
        );
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '$_countdown',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoneButton() {
    return SizedBox(
      width: double.infinity,
      height: AppConstants.buttonHeightLg,
      child: ElevatedButton(
        onPressed: _canContinue ? _handleComplete : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade500,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Done',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
