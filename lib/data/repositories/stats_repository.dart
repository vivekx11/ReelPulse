import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/daily_stats_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';

class StatsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _col =>
      _firestore.collection(AppConstants.dailyStatsCollection);

  String _docId(String uid, String dateKey) => '${uid}_$dateKey';

  /// Get today's stats for a user (real-time stream)
  Stream<DailyStatsModel?> watchTodayStats(String uid) {
    final id = _docId(uid, AppDateUtils.todayKey());
    return _col.doc(id).snapshots().map((snap) {
      if (!snap.exists) return null;
      return DailyStatsModel.fromFirestore(snap);
    });
  }

  /// Get stats for a specific date
  Future<DailyStatsModel?> getStats(String uid, String dateKey) async {
    final doc = await _col.doc(_docId(uid, dateKey)).get();
    if (!doc.exists) return null;
    return DailyStatsModel.fromFirestore(doc);
  }

  /// Get stats for last N days
  Future<List<DailyStatsModel>> getLastNDaysStats(String uid, int n) async {
    final keys = AppDateUtils.lastNDays(n);
    final futures = keys.map((k) => getStats(uid, k));
    final results = await Future.wait(futures);
    return results
        .asMap()
        .entries
        .map((e) =>
            e.value ??
            DailyStatsModel(
              id: _docId(uid, keys[e.key]),
              uid: uid,
              dateKey: keys[e.key],
              updatedAt: DateTime.now(),
            ))
        .toList();
  }

  /// Increment reel count (called from native service via method channel)
  Future<void> incrementReels(String uid, {int by = 1}) async {
    final id = _docId(uid, AppDateUtils.todayKey());
    await _col.doc(id).set(
      {
        'uid': uid,
        'dateKey': AppDateUtils.todayKey(),
        'reelsCount': FieldValue.increment(by),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Increment shorts count
  Future<void> incrementShorts(String uid, {int by = 1}) async {
    final id = _docId(uid, AppDateUtils.todayKey());
    await _col.doc(id).set(
      {
        'uid': uid,
        'dateKey': AppDateUtils.todayKey(),
        'shortsCount': FieldValue.increment(by),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Update watch time in seconds
  Future<void> updateWatchTime(
      String uid, int instagramSecs, int youtubeSecs) async {
    final id = _docId(uid, AppDateUtils.todayKey());
    await _col.doc(id).set(
      {
        'uid': uid,
        'dateKey': AppDateUtils.todayKey(),
        'instagramSeconds': instagramSecs,
        'youtubeSeconds': youtubeSecs,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
