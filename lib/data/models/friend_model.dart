import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum FriendRequestStatus { pending, accepted, rejected }

class FriendRequestModel extends Equatable {
  final String id;
  final String fromUid;
  final String toUid;
  final FriendRequestStatus status;
  final DateTime createdAt;

  const FriendRequestModel({
    required this.id,
    required this.fromUid,
    required this.toUid,
    required this.status,
    required this.createdAt,
  });

  factory FriendRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FriendRequestModel(
      id: doc.id,
      fromUid: data['fromUid'] ?? '',
      toUid: data['toUid'] ?? '',
      status: FriendRequestStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'pending'),
        orElse: () => FriendRequestStatus.pending,
      ),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'fromUid': fromUid,
        'toUid': toUid,
        'status': status.name,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  @override
  List<Object?> get props => [id, fromUid, toUid, status];
}

class FriendModel extends Equatable {
  final String uid;
  final String friendUid;
  final DateTime since;

  const FriendModel({
    required this.uid,
    required this.friendUid,
    required this.since,
  });

  factory FriendModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FriendModel(
      uid: data['uid'] ?? '',
      friendUid: data['friendUid'] ?? '',
      since: (data['since'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'uid': uid,
        'friendUid': friendUid,
        'since': Timestamp.fromDate(since),
      };

  @override
  List<Object?> get props => [uid, friendUid];
}
