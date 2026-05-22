import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/score_utils.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/stats_provider.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/addiction_score_ring.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final todayStats = ref.watch(todayStatsProvider).value;

    final reels = todayStats?.reelsCount ?? 0;
    final shorts = todayStats?.shortsCount ?? 0;
    final secs = todayStats?.totalSeconds ?? 0;
    final score = ScoreUtils.addictionScore(
        reels: reels, shorts: shorts, totalSeconds: secs);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Text(
                        'Profile',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: AppTheme.surface,
                              title: const Text('Sign Out?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: Text('Sign Out',
                                      style: TextStyle(
                                          color: AppTheme.neonRed)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await ref
                                .read(authNotifierProvider.notifier)
                                .signOut();
                          }
                        },
                        icon: const Icon(Icons.logout_rounded),
                        color: AppTheme.textMuted,
                      ),
                    ],
                  ),
                ),
              ),

              // Avatar + name
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppTheme.primaryGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.neonPurple.withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(3),
                            child: CircleAvatar(
                              radius: 48,
                              backgroundImage: user?.photoUrl.isNotEmpty == true
                                  ? NetworkImage(user!.photoUrl)
                                  : null,
                              backgroundColor: AppTheme.surfaceVariant,
                              child: user?.photoUrl.isEmpty == true
                                  ? Text(
                                      user?.name[0].toUpperCase() ?? '?',
                                      style: const TextStyle(fontSize: 36),
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      )
                          .animate()
                          .scale(duration: 500.ms, curve: Curves.elasticOut),

                      const SizedBox(height: 16),

                      Text(
                        user?.name ?? '',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (user?.instagramUsername != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: AppTheme.dangerGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '@${user!.instagramUsername}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Score ring
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          AddictionScoreRing(score: score, size: 100),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Addiction Score',
                                  style:
                                      Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ScoreUtils.addictionLabel(score),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: AppTheme.neonPurple,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Productivity: ${ScoreUtils.productivityScore(reels: reels, shorts: shorts, totalSeconds: secs).toStringAsFixed(0)}%',
                                  style:
                                      Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Stats grid
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'All-Time Stats',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _StatBox(
                                label: 'Total Reels',
                                value: '${user?.totalReels ?? 0}',
                                color: AppTheme.neonPink,
                              ),
                              const SizedBox(width: 12),
                              _StatBox(
                                label: 'Total Shorts',
                                value: '${user?.totalShorts ?? 0}',
                                color: AppTheme.neonRed,
                              ),
                              const SizedBox(width: 12),
                              _StatBox(
                                label: 'Streak',
                                value: '${user?.streakDays ?? 0}d',
                                color: AppTheme.neonOrange,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Badges
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Badges',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          if (user?.badges.isEmpty ?? true)
                            Text(
                              'No badges yet. Keep scrolling less!',
                              style: Theme.of(context).textTheme.bodyMedium,
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: (user?.badges ?? [])
                                  .map((b) => Chip(
                                        label: Text(b),
                                        backgroundColor:
                                            AppTheme.neonPurple.withOpacity(0.2),
                                        side: const BorderSide(
                                            color: AppTheme.neonPurple),
                                      ))
                                  .toList(),
                            ),
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
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
