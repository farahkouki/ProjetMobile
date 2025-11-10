import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html show window; // web only guard with kIsWeb

class RiskEngine {
  /// Returns 0.0 (low) .. 1.0 (high)
  static double compute({
    required int currentHour,        // 0..23
    required double meanHour,        // user profile
    required double hourStd,         // user profile (>=1 to avoid div by zero)
    required bool deviceChanged,     // compare stored UA hash
    required int failedAttempts,     // since last successful login
    required Duration idleDuration,  // since last login
  }) {
    final hStd = max(1.0, hourStd);
    final z = (currentHour - meanHour).abs() / hStd; // hour anomaly
    final hourScore = max(0.0, min(1.0, z / 3.0));   // cap z at ~3

    final deviceScore = deviceChanged ? 0.6 : 0.0;
    final failScore = max(0.0, min(1.0, failedAttempts / 5.0));
    final idleScore = max(0.0, min(1.0, idleDuration.inDays / 14.0)); // >2 weeks => high

    // Weighted sum (tweakable)
    final score = (0.35 * hourScore) + (0.35 * deviceScore) + (0.2 * failScore) + (0.1 * idleScore);
    return max(0.0, min(1.0, score));
  }

  /// Browser fingerprint (simple)
  static String currentUaHash() {
    if (!kIsWeb) return 'native';
    final ua = html.window.navigator.userAgent;
    return ua.hashCode.toString();
  }
}
