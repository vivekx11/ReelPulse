import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/stats_repository.dart';
import '../models/daily_stats_model.dart';
import 'auth_provider.dart';

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  return StatsRepository();
});

/// Today's stats stream for the current user
final todayStatsProvider = StreamProvider<DailyStatsModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return const Stream.empty();
      return ref.read(statsRepositoryProvider).watchTodayStats(user.uid);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

/// Last 7 days stats for charts
final weeklyStatsProvider =
    FutureProvider<List<DailyStatsModel>>((ref) async {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) async {
      if (user == null) return [];
      return ref.read(statsRepositoryProvider).getLastNDaysStats(user.uid, 7);
    },
    loading: () async => [],
    error: (_, __) async => [],
  );
});

/// Last 30 days stats for monthly chart
final monthlyStatsProvider =
    FutureProvider<List<DailyStatsModel>>((ref) async {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) async {
      if (user == null) return [];
      return ref.read(statsRepositoryProvider).getLastNDaysStats(user.uid, 30);
    },
    loading: () async => [],
    error: (_, __) async => [],
  );
});
