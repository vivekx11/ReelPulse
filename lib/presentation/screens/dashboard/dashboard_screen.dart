import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/score_utils.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/stats_provider.dart';
import '../../../services/native/tracking_service.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/stat_chip.dart';
import '../../widgets/charts/weekly_bar_chart.dart';
import '../../widgets/common/addiction_score_ring.dart';
import '../../widgets/common/permission_banner.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final tracking = ref.read(trackingServiceProvider);
    final hasAccess = await tracking.isAccessibilityEnabled();
    final hasUsage = await tracking.isUsageStatsPermissionGranted();
    if (hasAccess && hasUsage) {
      final user = ref.read(authStateProvider).value;
      if (user != null) {
        await tracking.startTrackingService(user.uid);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final todayStats = ref.watch(todayStatsProvider);
    final weeklyStats = ref.watch(weeklyStatsProvider);
    final user = ref.watch(currentUserProvider).value;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(todayStatsProvider);
              ref.invalidate(weeklyStatsProvider);
            },
            color: AppTheme.neonPurple,
            backgroundColor: AppTheme.surface,
            child: CustomScrollView(
              slivers: [
                // App bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good ${_greeting()},',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              user?.name.split(' ').first ?? 'Scroller',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.copyWith(
                                    foreground: Paint()
                                      ..shader = const LinearGradient(
                                        colors: [
                                          AppTheme.neonPurple,
                                          AppTheme.neonCyan
                                        ],
                                      ).createShader(
                                          const Rect.fromLTWH(0, 0, 200, 30)),
                                  ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (user?.photoUrl.isNotEmpty == true)
                          CircleAvatar(
                            radius: 22,
                            backgroundImage: NetworkImage(user!.photoUrl),
                          ),
                      ],
                    ),
                  ),
                ),

                // Permission banner
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: PermissionBanner(),
                  ),
                ),

                // Today's stats
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: todayStats.when(
                      data: (stats) {
                        final reels = stats?.reelsCount ?? 0;
                        final shorts = stats?.shortsCount ?? 0;
                        final secs = stats?.totalSeconds ?? 0;
                        final score = ScoreUtils.addictionScore(
                          reels: reels,
                          shorts: shorts,
                          totalSeconds: secs,
                        );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Today · ${AppDateUtils.todayKey()}",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 12),

                            // Score ring + stats row
                            Row(
                              children: [
                                AddictionScoreRing(score: score),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    children: [
                                      StatChip(
                                        icon: '🎬',
                                        label: 'Reels',
                                        value: '$reels',
                                        color: AppTheme.neonPink,
                                      ),
                                      const SizedBox(height: 8),
                                      StatChip(
                                        icon: '▶️',
                                        label: 'Shorts',
                                        value: '$shorts',
                                        color: AppTheme.neonRed,
                                      ),
                                      const SizedBox(height: 8),
                                      StatChip(
                                        icon: '⏱️',
                                        label: 'Screen Time',
                                        value: AppDateUtils.formatDuration(secs),
                                        color: AppTheme.neonOrange,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Warning banner
                            if (reels + shorts >=
                                50) // warning threshold
                              _WarningBanner(
                                  total: reels + shorts)
                                  .animate()
                                  .shake(duration: 600.ms),
                          ],
                        );
                      },
                      loading: () => const Center(
                          child: CircularProgressIndicator()),
                      error: (e, _) => Text('Error: $e'),
                    ),
                  ),
                ),

                // Weekly chart
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Weekly Trend',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            weeklyStats.when(
                              data: (stats) => WeeklyBarChart(stats: stats),
                              loading: () => const SizedBox(
                                height: 150,
                                child: Center(
                                    child: CircularProgressIndicator()),
                              ),
                              error: (e, _) => Text('Error: $e'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Streak & badges
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            _StreakCard(streak: user?.streakDays ?? 0),
                            const SizedBox(width: 12),
                            _BadgesCard(badges: user?.badges ?? []),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}

class _WarningBanner extends StatelessWidget {
  final int total;
  const _WarningBanner({required this.total});

  @override
  Widget build(BuildContext context) {
    final isDanger = total >= 100;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: isDanger ? AppTheme.dangerGradient : const LinearGradient(
          colors: [AppTheme.neonOrange, AppTheme.neonPink],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(isDanger ? '💀' : '⚠️', style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isDanger
                  ? 'You\'ve watched $total videos today. Time to touch grass!'
                  : 'You\'ve watched $total videos. Slow down!',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final int streak;
  const _StreakCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Text('🔥', style: TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(
              '$streak',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AppTheme.neonOrange,
                    fontFamily: 'Orbitron',
                  ),
            ),
            Text(
              'Day Streak',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgesCard extends StatelessWidget {
  final List<String> badges;
  const _BadgesCard({required this.badges});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Text('🏅', style: TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(
              '${badges.length}',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AppTheme.neonPurple,
                    fontFamily: 'Orbitron',
                  ),
            ),
            Text(
              'Badges',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
