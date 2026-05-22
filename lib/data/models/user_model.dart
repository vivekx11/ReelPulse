import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;
  final String? instagramUsername;
  final DateTime createdAt;
  final bool isPublic;
  final int totalReels;
  final int totalShorts;
  final int streakDays;
  final List<String> badges;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.photoUrl,
    this.instagramUsername,
    required this.createdAt,
    this.isPublic = true,
    this.totalReels = 0,
    this.totalShorts = 0,
    this.streakDays = 0,
    this.badges = const [],
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      instagramUsername: data['instagramUsername'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPublic: data['isPublic'] ?? true,
      totalReels: data['totalReels'] ?? 0,
      totalShorts: data['totalShorts'] ?? 0,
      streakDays: data['streakDays'] ?? 0,
      badges: List<String>.from(data['badges'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'instagramUsername': instagramUsername,
        'createdAt': Timestamp.fromDate(createdAt),
        'isPublic': isPublic,
        'totalReels': totalReels,
        'totalShorts': totalShorts,
        'streakDays': streakDays,
        'badges': badges,
      };

  UserModel copyWith({
    String? name,
    String? photoUrl,
    String? instagramUsername,
    bool? isPublic,
    int? totalReels,
    int? totalShorts,
    int? streakDays,
    List<String>? badges,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      instagramUsername: instagramUsername ?? this.instagramUsername,
      createdAt: createdAt,
      isPublic: isPublic ?? this.isPublic,
      totalReels: totalReels ?? this.totalReels,
      totalShorts: totalShorts ?? this.totalShorts,
      streakDays: streakDays ?? this.streakDays,
      badges: badges ?? this.badges,
    );
  }

  @override
  List<Object?> get props => [uid, name, email, photoUrl, instagramUsername];
}
