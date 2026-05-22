import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/daily_stats_model.dart';

/// Bar chart showing reels + shorts per day for the last 7 days
class WeeklyBarChart extends StatelessWidget {
  final List<DailyStatsModel> stats;

  const WeeklyBarChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxY = stats
            .map((s) => (s.reelsCount + s.shortsCount).toDouble())
            .fold(0.0, (a, b) => a > b ? a : b) *
        1.3;

    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          maxY: maxY < 10 ? 10 : maxY,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppTheme.surfaceVariant,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  rod.toY.toInt().toString(),
                  const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= stats.length) {
                    return const SizedBox.shrink();
                  }
                  // Parse day of week from dateKey
                  final dateKey = stats[idx].dateKey;
                  final parts = dateKey.split('-');
                  if (parts.length == 3) {
                    final dt = DateTime(
                      int.parse(parts[0]),
                      int.parse(parts[1]),
                      int.parse(parts[2]),
                    );
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        days[dt.weekday - 1],
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppTheme.divider,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(stats.length, (i) {
            final s = stats[i];
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: s.reelsCount.toDouble(),
                  color: AppTheme.neonPink,
                  width: 8,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4)),
                ),
                BarChartRodData(
                  toY: s.shortsCount.toDouble(),
                  color: AppTheme.neonRed,
                  width: 8,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4)),
                ),
              ],
              barsSpace: 3,
            );
          }),
        ),
      ),
    );
  }
}
