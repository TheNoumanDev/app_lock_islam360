import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'service_providers.dart';

/// Provider that tracks whether onboarding has been completed
final onboardingCompleteProvider =
    AsyncNotifierProvider<OnboardingNotifier, bool>(OnboardingNotifier.new);

class OnboardingNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final storage = await ref.watch(storageServiceProvider.future);
    return storage.loadOnboardingComplete();
  }

  /// Mark onboarding as complete and persist
  Future<void> completeOnboarding() async {
    final storage = await ref.read(storageServiceProvider.future);
    await storage.saveOnboardingComplete(true);
    state = const AsyncData(true);
  }
}
