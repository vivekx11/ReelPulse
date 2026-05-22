import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/score_utils.dart';

/// Circular ring showing addiction score
class AddictionScoreRing extends StatelessWidget {
  final double score;
  final double size;

  const AddictionScoreRing({super.key, required this.score, this.size = 110});

  @override
  Widget build(BuildContext context) {
    final colorHex = ScoreUtils.addictionColor(score);
    final color = _hexToColor(colorHex);

    return CircularPercentIndicator(
      radius: size / 2,
      lineWidth: 8,
      percent: score / 100,
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            score.toStringAsFixed(0),
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: size * 0.22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            'score',
            style: TextStyle(
              fontSize: size * 0.1,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
      progressColor: color,
      backgroundColor: color.withOpacity(0.15),
      circularStrokeCap: CircularStrokeCap.round,
      animation: true,
      animationDuration: 800,
    );
  }

  Color _hexToColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}
