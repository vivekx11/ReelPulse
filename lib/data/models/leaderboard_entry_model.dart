import 'package:equatable/equatable.dart';

class LeaderboardEntry extends Equatable {
  final String uid;
  final String name;
  final String photoUrl;
  final String? instagramUsername;
  final int totalScrolls;
  final int reels;
  final int shorts;
  final int totalSeconds;
  final double addictionScore;
  final int rank;

  const LeaderboardEntry({
    required this.uid,
    required this.name,
    required this.photoUrl,
    this.instagramUsername,
    required this.totalScrolls,
    required this.reels,
    required this.shorts,
    required this.totalSeconds,
    required this.addictionScore,
    required this.rank,
  });

  @override
  List<Object?> get props => [uid, rank];
}
