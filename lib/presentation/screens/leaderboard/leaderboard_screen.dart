import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/leaderboard_entry_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/leaderboard_provider.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _leastFirst = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final globalLeast = ref.watch(globalLeaderboardProvider);
    final globalMost = ref.watch(globalMostLeaderboardProvider);
    final friendsBoard = ref.watch(friendsLeaderboardProvider);
    final currentUid = ref.watch(authStateProvider).value?.uid;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Text(
                      'Leaderboard',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const Spacer(),
                    // Toggle least/most
                    GestureDetector(
                      onTap: () => setState(() => _leastFirst = !_leastFirst),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _leastFirst
                                  ? Icons.arrow_downward_rounded
                                  : Icons.arrow_upward_rounded,
                              size: 14,
                              color: AppTheme.neonPurple,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _leastFirst ? 'Least' : 'Most',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Tabs
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: AppTheme.textMuted,
                    tabs: const [
                      Tab(text: '🌍 Global'),
                      Tab(text: '👥 Friends'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Tab views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Global
                    RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(globalLeaderboardProvider);
                        ref.invalidate(globalMostLeaderboardProvider);
                      },
                      color: AppTheme.neonPurple,
                      backgroundColor: AppTheme.surface,
                      child: (_leastFirst ? globalLeast : globalMost).when(
                        data: (entries) => _LeaderboardList(
                          entries: entries,
                          currentUid: currentUid,
                        ),
                        loading: () => const Center(
                            child: CircularProgressIndicator()),
                        error: (e, _) => Center(child: Text('Error: $e')),
                      ),
                    ),

                    // Friends
                    RefreshIndicator(
                      onRefresh: () async =>
                          ref.invalidate(friendsLeaderboardProvider),
                      color: AppTheme.neonPurple,
                      backgroundColor: AppTheme.surface,
                      child: friendsBoard.when(
                        data: (entries) => entries.isEmpty
                            ? const _EmptyFriends()
                            : _LeaderboardList(
                                entries: entries,
                                currentUid: currentUid,
                              ),
                        loading: () => const Center(
                            child: CircularProgressIndicator()),
                        error: (e, _) => Center(child: Text('Error: $e')),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeaderboardList extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final String? currentUid;

  const _LeaderboardList({required this.entries, this.currentUid});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final entry = entries[i];
        final isMe = entry.uid == currentUid;
        return _LeaderboardTile(entry: entry, isMe: isMe)
            .animate(delay: Duration(milliseconds: i * 60))
            .fadeIn(duration: 300.ms)
            .slideX(begin: 0.1, end: 0);
      },
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isMe;

  const _LeaderboardTile({required this.entry, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final rankEmoji = entry.rank == 1
        ? '🥇'
        : entry.rank == 2
            ? '🥈'
            : entry.rank == 3
                ? '🥉'
                : '#${entry.rank}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: isMe
            ? LinearGradient(
                colors: [
                  AppTheme.neonPurple.withOpacity(0.2),
                  AppTheme.neonBlue.withOpacity(0.1),
                ],
              )
            : null,
        color: isMe ? null : AppTheme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMe ? AppTheme.neonPurple : AppTheme.divider,
          width: isMe ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 32,
              child: Text(
                rankEmoji,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 20,
              backgroundImage: entry.photoUrl.isNotEmpty
                  ? NetworkImage(entry.photoUrl)
                  : null,
              backgroundColor: AppTheme.surfaceVariant,
              child: entry.photoUrl.isEmpty
                  ? Text(entry.name[0].toUpperCase())
                  : null,
            ),
          ],
        ),
        title: Row(
          children: [
            Text(
              entry.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isMe ? AppTheme.neonPurple : AppTheme.textPrimary,
                    fontWeight:
                        isMe ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
            if (isMe) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.neonPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'You',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.neonPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          '${entry.reels} reels · ${entry.shorts} shorts · ${AppDateUtils.formatDuration(entry.totalSeconds)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${entry.totalScrolls}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: entry.rank <= 3
                        ? AppTheme.neonOrange
                        : AppTheme.textPrimary,
                    fontFamily: 'Orbitron',
                    fontSize: 18,
                  ),
            ),
            Text(
              'scrolls',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFriends extends StatelessWidget {
  const _EmptyFriends();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('👥', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            'No friends yet',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Add friends to compete on the leaderboard',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
