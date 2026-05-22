import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/friend_model.dart';
import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';

class FriendsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _friends =>
      _firestore.collection(AppConstants.friendsCollection);
  CollectionReference get _requests =>
      _firestore.collection(AppConstants.requestsCollection);
  CollectionReference get _users =>
      _firestore.collection(AppConstants.usersCollection);

  /// Send a friend request
  Future<void> sendRequest(String fromUid, String toUid) async {
    final id = '${fromUid}_$toUid';
    await _requests.doc(id).set(FriendRequestModel(
          id: id,
          fromUid: fromUid,
          toUid: toUid,
          status: FriendRequestStatus.pending,
          createdAt: DateTime.now(),
        ).toFirestore());
  }

  /// Accept a friend request
  Future<void> acceptRequest(String requestId, String fromUid, String toUid) async {
    final batch = _firestore.batch();

    // Update request status
    batch.update(_requests.doc(requestId), {'status': 'accepted'});

    // Create bidirectional friend docs
    batch.set(
      _friends.doc('${fromUid}_$toUid'),
      FriendModel(uid: fromUid, friendUid: toUid, since: DateTime.now())
          .toFirestore(),
    );
    batch.set(
      _friends.doc('${toUid}_$fromUid'),
      FriendModel(uid: toUid, friendUid: fromUid, since: DateTime.now())
          .toFirestore(),
    );

    await batch.commit();
  }

  /// Reject a friend request
  Future<void> rejectRequest(String requestId) async {
    await _requests.doc(requestId).update({'status': 'rejected'});
  }

  /// Remove a friend
  Future<void> removeFriend(String uid, String friendUid) async {
    final batch = _firestore.batch();
    batch.delete(_friends.doc('${uid}_$friendUid'));
    batch.delete(_friends.doc('${friendUid}_$uid'));
    await batch.commit();
  }

  /// Stream of friend UIDs for a user
  Stream<List<String>> watchFriendUids(String uid) {
    return _friends
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => FriendModel.fromFirestore(d).friendUid)
            .toList());
  }

  /// Stream of incoming pending requests
  Stream<List<FriendRequestModel>> watchIncomingRequests(String uid) {
    return _requests
        .where('toUid', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => FriendRequestModel.fromFirestore(d)).toList());
  }

  /// Search users by name (simple prefix search)
  Future<List<UserModel>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];
    final snap = await _users
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: '${query}z')
        .limit(20)
        .get();
    return snap.docs.map((d) => UserModel.fromFirestore(d)).toList();
  }

  /// Check if two users are already friends
  Future<bool> areFriends(String uid, String otherUid) async {
    final doc = await _friends.doc('${uid}_$otherUid').get();
    return doc.exists;
  }

  /// Check if a pending request exists
  Future<bool> hasPendingRequest(String fromUid, String toUid) async {
    final doc = await _requests.doc('${fromUid}_$toUid').get();
    return doc.exists &&
        (doc.data() as Map)['status'] == 'pending';
  }
}
