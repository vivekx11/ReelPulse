import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/friend_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/friends_provider.dart';
import '../../widgets/common/glass_card.dart';

class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomingRequests = ref.watch(incomingRequestsProvider).value ?? [];
    final friendUids = ref.watch(friendUidsProvider).value ?? [];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Text(
                        'Friends',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => context.push('/search-users'),
                        icon: const Icon(Icons.person_add_rounded),
                        color: AppTheme.neonPurple,
                        style: IconButton.styleFrom(
                          backgroundColor:
                              AppTheme.neonPurple.withOpacity(0.15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Incoming requests
              if (incomingRequests.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Text(
                      'Friend Requests (${incomingRequests.length})',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.neonPink,
                          ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: _RequestTile(request: incomingRequests[i])
                          .animate(delay: Duration(milliseconds: i * 80))
                          .fadeIn(duration: 300.ms)
                          .slideX(begin: 0.1, end: 0),
                    ),
                    childCount: incomingRequests.length,
                  ),
                ),
              ],

              // Friends list
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Text(
                    'My Friends (${friendUids.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),

              if (friendUids.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        const Text('🤝',
                            style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text(
                          'No friends yet',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Search for users and send friend requests',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => context.push('/search-users'),
                          icon: const Icon(Icons.search_rounded),
                          label: const Text('Find Friends'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: _FriendTile(friendUid: friendUids[i])
                          .animate(delay: Duration(milliseconds: i * 60))
                          .fadeIn(duration: 300.ms),
                    ),
                    childCount: friendUids.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestTile extends ConsumerWidget {
  final FriendRequestModel request;
  const _RequestTile({required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.neonPink.withOpacity(0.2),
          child: const Icon(Icons.person_rounded, color: AppTheme.neonPink),
        ),
        title: Text(
          request.fromUid,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: const Text('Wants to be your friend'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () async {
                await ref
                    .read(friendsRepositoryProvider)
                    .acceptRequest(
                      request.id,
                      request.fromUid,
                      request.toUid,
                    );
              },
              icon: const Icon(Icons.check_circle_rounded),
              color: AppTheme.neonGreen,
            ),
            IconButton(
              onPressed: () async {
                await ref
                    .read(friendsRepositoryProvider)
                    .rejectRequest(request.id);
              },
              icon: const Icon(Icons.cancel_rounded),
              color: AppTheme.neonRed,
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendTile extends ConsumerWidget {
  final String friendUid;
  const _FriendTile({required this.friendUid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUid = ref.watch(authStateProvider).value?.uid ?? '';

    return GlassCard(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.neonPurple.withOpacity(0.2),
          child: const Icon(Icons.person_rounded, color: AppTheme.neonPurple),
        ),
        title: Text(
          friendUid,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        trailing: IconButton(
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: AppTheme.surface,
                title: const Text('Remove Friend?'),
                content: const Text(
                    'Are you sure you want to remove this friend?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text('Remove',
                        style: TextStyle(color: AppTheme.neonRed)),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              await ref
                  .read(friendsRepositoryProvider)
                  .removeFriend(currentUid, friendUid);
            }
          },
          icon: const Icon(Icons.person_remove_rounded),
          color: AppTheme.textMuted,
        ),
      ),
    );
  }
}
