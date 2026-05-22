import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/friends_repository.dart';
import '../models/friend_model.dart';
import '../models/user_model.dart';
import 'auth_provider.dart';

final friendsRepositoryProvider = Provider<FriendsRepository>((ref) {
  return FriendsRepository();
});

/// Stream of friend UIDs
final friendUidsProvider = StreamProvider<List<String>>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return const Stream.empty();
      return ref.read(friendsRepositoryProvider).watchFriendUids(user.uid);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

/// Stream of incoming friend requests
final incomingRequestsProvider =
    StreamProvider<List<FriendRequestModel>>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return const Stream.empty();
      return ref
          .read(friendsRepositoryProvider)
          .watchIncomingRequests(user.uid);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

/// User search results
final userSearchProvider =
    FutureProvider.family<List<UserModel>, String>((ref, query) async {
  return ref.read(friendsRepositoryProvider).searchUsers(query);
});
