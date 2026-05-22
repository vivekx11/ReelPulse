import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leaderboard_entry_model.dart';
import '../models/daily_stats_model.dart';
import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/score_utils.dart';

class LeaderboardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Build leaderboard entries for a list of UIDs for a given date range
  Future<List<LeaderboardEntry>> buildLeaderboard({
    required List<String> uids,
    required String dateKey,
    bool leastFirst = true,
  }) async {
    if (uids.isEmpty) return [];

    // Fetch user profiles and stats in parallel
    final userFutures = uids.map((uid) => _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get());
    final statsFutures = uids.map((uid) => _firestore
        .collection(AppConstants.dailyStatsCollection)
        .doc('${uid}_$dateKey')
        .get());

    final userDocs = await Future.wait(userFutures);
    final statsDocs = await Future.wait(statsFutures);

    final entries = <LeaderboardEntry>[];
    for (int i = 0; i < uids.length; i++) {
      if (!userDocs[i].exists) continue;
      final user = UserModel.fromFirestore(userDocs[i]);
      DailyStatsModel stats;
      if (statsDocs[i].exists) {
        stats = DailyStatsModel.fromFirestore(statsDocs[i]);
      } else {
        stats = DailyStatsModel(
          id: '${uids[i]}_$dateKey',
          uid: uids[i],
          dateKey: dateKey,
          updatedAt: DateTime.now(),
        );
      }

      entries.add(LeaderboardEntry(
        uid: user.uid,
        name: user.name,
        photoUrl: user.photoUrl,
        instagramUsername: user.instagramUsername,
        totalScrolls: stats.totalScrolls,
        reels: stats.reelsCount,
        shorts: stats.shortsCount,
        totalSeconds: stats.totalSeconds,
        addictionScore: ScoreUtils.addictionScore(
          reels: stats.reelsCount,
          shorts: stats.shortsCount,
          totalSeconds: stats.totalSeconds,
        ),
        rank: 0, // assigned below
      ));
    }

    // Sort
    entries.sort((a, b) => leastFirst
        ? a.totalScrolls.compareTo(b.totalScrolls)
        : b.totalScrolls.compareTo(a.totalScrolls));

    // Assign ranks
    return entries
        .asMap()
        .entries
        .map((e) => LeaderboardEntry(
              uid: e.value.uid,
              name: e.value.name,
              photoUrl: e.value.photoUrl,
              instagramUsername: e.value.instagramUsername,
              totalScrolls: e.value.totalScrolls,
              reels: e.value.reels,
              shorts: e.value.shorts,
              totalSeconds: e.value.totalSeconds,
              addictionScore: e.value.addictionScore,
              rank: e.key + 1,
            ))
        .toList();
  }

  /// Get global leaderboard (top 50 users by today's scrolls)
  Future<List<LeaderboardEntry>> getGlobalLeaderboard({
    bool leastFirst = true,
  }) async {
    final snap = await _firestore
        .collection(AppConstants.dailyStatsCollection)
        .where('dateKey', isEqualTo: AppDateUtils.todayKey())
        .orderBy('reelsCount', descending: !leastFirst)
        .limit(50)
        .get();

    final uids = snap.docs
        .map((d) => (d.data())['uid'] as String)
        .toSet()
        .toList();

    return buildLeaderboard(
      uids: uids,
      dateKey: AppDateUtils.todayKey(),
      leastFirst: leastFirst,
    );
  }
}
