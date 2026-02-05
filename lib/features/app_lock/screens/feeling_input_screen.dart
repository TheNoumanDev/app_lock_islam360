import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../data/islamic_content.dart';

/// Screen shown when a locked app is opened
/// Asks user how they are feeling before showing Islamic content
class FeelingInputScreen extends StatefulWidget {
  const FeelingInputScreen({
    super.key,
    required this.appName,
    required this.packageName,
  });

  final String appName;
  final String packageName;

  @override
  State<FeelingInputScreen> createState() => _FeelingInputScreenState();
}

class _FeelingInputScreenState extends State<FeelingInputScreen> {
  final TextEditingController _feelingController = TextEditingController();
  bool _hasInput = false;

  @override
  void initState() {
    super.initState();
    _feelingController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _feelingController.removeListener(_onInputChanged);
    _feelingController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    final hasInput = _feelingController.text.trim().isNotEmpty;
    if (hasInput != _hasInput) {
      setState(() => _hasInput = hasInput);
    }
  }

  void _submitFeeling(String feeling) {
    context.push(
      '/lock/ayat',
      extra: {
        'feeling': feeling,
        'appName': widget.appName,
        'packageName': widget.packageName,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLg),
          child: Column(
            children: [
              const SizedBox(height: AppConstants.spacing2xl),
              // Lock Icon
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppConstants.spacingLg),
              // App Name
              Text(
                widget.appName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingSm),
              // Question
              Text(
                'How are you feeling right now?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingXl),
              // Text Input
              TextField(
                controller: _feelingController,
                decoration: InputDecoration(
                  hintText: 'Why am I reaching for this app?',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingMd,
                    vertical: AppConstants.spacingMd,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusXl),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusXl),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusXl),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    _submitFeeling(value.trim());
                  }
                },
              ),
              const SizedBox(height: AppConstants.spacingMd),
              // Continue Button
              SizedBox(
                width: double.infinity,
                height: AppConstants.buttonHeightLg,
                child: ElevatedButton(
                  onPressed: _hasInput
                      ? () => _submitFeeling(_feelingController.text.trim())
                      : null,
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
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingLg),
              // Divider with text
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade200)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
                    child: Text(
                      'or choose from below',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade200)),
                ],
              ),
              const SizedBox(height: AppConstants.spacingLg),
              // Predefined Feelings Grid
              Wrap(
                spacing: AppConstants.spacingSm,
                runSpacing: AppConstants.spacingSm,
                alignment: WrapAlignment.center,
                children: predefinedFeelings.map((feeling) {
                  return _FeelingChip(
                    label: feeling,
                    onTap: () => _submitFeeling(feeling),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppConstants.spacingXl),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pill-shaped feeling chip
class _FeelingChip extends StatelessWidget {
  const _FeelingChip({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }
}
