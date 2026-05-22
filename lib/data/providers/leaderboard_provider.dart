import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/leaderboard_repository.dart';
import '../models/leaderboard_entry_model.dart';
import 'auth_provider.dart';
import 'friends_provider.dart';

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  return LeaderboardRepository();
});

/// Global leaderboard (least scrolling first)
final globalLeaderboardProvider =
    FutureProvider<List<LeaderboardEntry>>((ref) async {
  return ref
      .read(leaderboardRepositoryProvider)
      .getGlobalLeaderboard(leastFirst: true);
});

/// Global leaderboard (most scrolling first)
final globalMostLeaderboardProvider =
    FutureProvider<List<LeaderboardEntry>>((ref) async {
  return ref
      .read(leaderboardRepositoryProvider)
      .getGlobalLeaderboard(leastFirst: false);
});

/// Friends leaderboard
final friendsLeaderboardProvider =
    FutureProvider<List<LeaderboardEntry>>((ref) async {
  final authState = ref.watch(authStateProvider);
  final friendUids = ref.watch(friendUidsProvider).value ?? [];

  return authState.when(
    data: (user) async {
      if (user == null) return [];
      final uids = [user.uid, ...friendUids];
      return ref.read(leaderboardRepositoryProvider).buildLeaderboard(
            uids: uids,
            dateKey: DateTime.now().toIso8601String().substring(0, 10),
            leastFirst: true,
          );
    },
    loading: () async => [],
    error: (_, __) async => [],
  );
});
