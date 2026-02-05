import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

/// Service for detecting shake gestures using accelerometer
class ShakeService {
  StreamSubscription<AccelerometerEvent>? _subscription;
  DateTime? _lastShakeTime;

  static const double shakeThreshold = 15.0;
  static const Duration shakeCooldown = Duration(milliseconds: 500);

  /// Start listening for shake gestures
  /// [onShake] callback is called when shake is detected
  void startListening(void Function() onShake) {
    _subscription?.cancel();
    _subscription = accelerometerEventStream().listen((event) {
      final now = DateTime.now();

      // Check cooldown to prevent multiple triggers
      if (_lastShakeTime != null &&
          now.difference(_lastShakeTime!) < shakeCooldown) {
        return;
      }

      // Check if any axis exceeds threshold
      if (event.x.abs() > shakeThreshold ||
          event.y.abs() > shakeThreshold ||
          event.z.abs() > shakeThreshold) {
        _lastShakeTime = now;
        onShake();
      }
    });
  }

  /// Stop listening for shake gestures
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Dispose resources
  void dispose() {
    stopListening();
  }
}
