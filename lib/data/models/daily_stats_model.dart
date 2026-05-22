import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class DailyStatsModel extends Equatable {
  final String id; // uid_dateKey
  final String uid;
  final String dateKey; // "2024-05-21"
  final int reelsCount;
  final int shortsCount;
  final int instagramSeconds;
  final int youtubeSeconds;
  final DateTime updatedAt;

  const DailyStatsModel({
    required this.id,
    required this.uid,
    required this.dateKey,
    this.reelsCount = 0,
    this.shortsCount = 0,
    this.instagramSeconds = 0,
    this.youtubeSeconds = 0,
    required this.updatedAt,
  });

  int get totalSeconds => instagramSeconds + youtubeSeconds;
  int get totalScrolls => reelsCount + shortsCount;

  factory DailyStatsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DailyStatsModel(
      id: doc.id,
      uid: data['uid'] ?? '',
      dateKey: data['dateKey'] ?? '',
      reelsCount: data['reelsCount'] ?? 0,
      shortsCount: data['shortsCount'] ?? 0,
      instagramSeconds: data['instagramSeconds'] ?? 0,
      youtubeSeconds: data['youtubeSeconds'] ?? 0,
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'uid': uid,
        'dateKey': dateKey,
        'reelsCount': reelsCount,
        'shortsCount': shortsCount,
        'instagramSeconds': instagramSeconds,
        'youtubeSeconds': youtubeSeconds,
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  DailyStatsModel copyWith({
    int? reelsCount,
    int? shortsCount,
    int? instagramSeconds,
    int? youtubeSeconds,
  }) {
    return DailyStatsModel(
      id: id,
      uid: uid,
      dateKey: dateKey,
      reelsCount: reelsCount ?? this.reelsCount,
      shortsCount: shortsCount ?? this.shortsCount,
      instagramSeconds: instagramSeconds ?? this.instagramSeconds,
      youtubeSeconds: youtubeSeconds ?? this.youtubeSeconds,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, uid, dateKey];
}
