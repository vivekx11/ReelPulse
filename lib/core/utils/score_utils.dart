//score 

import '../constants/app_constants.dart';

/// Calculates addiction and productivity scores
class ScoreUtils {
  ScoreUtils._();

  /// Addiction score: higher = more addicted (0–100 capped)
  static double addictionScore({
    required int reels,
    required int shorts,
    required int totalSeconds,
  }) {
    final raw = (reels * AppConstants.reelWeight) +
        (shorts * AppConstants.shortWeight) +
        ((totalSeconds / 60) * AppConstants.timeWeight);
    // Normalise: 200 raw = score 100
    return (raw / 200 * 100).clamp(0, 100);
  }

  /// Productivity score: inverse of addiction (0–100)
  static double productivityScore({
    required int reels,
    required int shorts,
    required int totalSeconds,
  }) {
    return 100 - addictionScore(
      reels: reels,
      shorts: shorts,
      totalSeconds: totalSeconds,
    );
  }

  /// Returns a label for the addiction level
  static String addictionLabel(double score) {
    if (score < 20) return 'Clean 🌿';
    if (score < 40) return 'Mild 😌';
    if (score < 60) return 'Moderate 😬';
    if (score < 80) return 'Heavy 🔥';
    return 'Addicted 💀';
  }

  /// Returns a colour hex string for the score
  static String addictionColor(double score) {
    if (score < 20) return '#10B981'; // green
    if (score < 40) return '#06B6D4'; // cyan
    if (score < 60) return '#F59E0B'; // orange
    if (score < 80) return '#EC4899'; // pink
    return '#EF4444'; // red
  }
}
