import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/friends_provider.dart';
import '../../widgets/common/glass_card.dart';

class SearchUsersScreen extends ConsumerStatefulWidget {
  const SearchUsersScreen({super.key});

  @override
  ConsumerState<SearchUsersScreen> createState() => _SearchUsersScreenState();
}

class _SearchUsersScreenState extends ConsumerState<SearchUsersScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(userSearchProvider(_query));
    final currentUid = ref.watch(authStateProvider).value?.uid ?? '';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Find Friends'),
        backgroundColor: AppTheme.surface,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
          ),

          // Results
          Expanded(
            child: _query.isEmpty
                ? Center(
                    child: Text(
                      'Type a name to search',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : results.when(
                    data: (users) {
                      final filtered =
                          users.where((u) => u.uid != currentUid).toList();
                      if (filtered.isEmpty) {
                        return Center(
                          child: Text(
                            'No users found',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, i) =>
                            _UserSearchTile(
                              user: filtered[i],
                              currentUid: currentUid,
                            ),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  ),
          ),
        ],
      ),
    );
  }
}

class _UserSearchTile extends ConsumerStatefulWidget {
  final UserModel user;
  final String currentUid;

  const _UserSearchTile({required this.user, required this.currentUid});

  @override
  ConsumerState<_UserSearchTile> createState() => _UserSearchTileState();
}

class _UserSearchTileState extends ConsumerState<_UserSearchTile> {
  bool _sent = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: widget.user.photoUrl.isNotEmpty
                ? NetworkImage(widget.user.photoUrl)
                : null,
            backgroundColor: AppTheme.surfaceVariant,
            child: widget.user.photoUrl.isEmpty
                ? Text(widget.user.name[0].toUpperCase())
                : null,
          ),
          title: Text(widget.user.name),
          subtitle: widget.user.instagramUsername != null
              ? Text('@${widget.user.instagramUsername}')
              : null,
          trailing: _sent
              ? const Icon(Icons.check_circle_rounded,
                  color: AppTheme.neonGreen)
              : _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : ElevatedButton(
                      onPressed: _sendRequest,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Add'),
                    ),
        ),
      ),
    );
  }

  Future<void> _sendRequest() async {
    setState(() => _loading = true);
    try {
      await ref
          .read(friendsRepositoryProvider)
          .sendRequest(widget.currentUid, widget.user.uid);
      setState(() => _sent = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
