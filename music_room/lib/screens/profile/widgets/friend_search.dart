
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/spacing.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/core/model/friend.dart';
import 'package:music_room/features/friend/provider.dart';
import 'package:music_room/widgets/separator.dart';


class FriendSearch extends ConsumerStatefulWidget {
  const FriendSearch({
    super.key,
    required this.query
  });

  final String query;

  @override
  ConsumerState<FriendSearch>  createState() => _FriendSearchState();
} 


class _FriendSearchState extends ConsumerState<FriendSearch> {
  List<Friend>  _friends = [];
  List<Friend>  _pendingFriends = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void didUpdateWidget(covariant FriendSearch old) {
    super.didUpdateWidget(old);
    if (old.query != widget.query) _fetch();
  }

  Future<void>  _fetch() async {
    await ref.read(friendProvider.notifier).refreshFriends();
    final friends = ref.read(friendProvider);
    if (widget.query.isEmpty) {
      setState(() => _friends = friends.acceptedFriends);
      setState(() => _pendingFriends = friends.pendingRequests);
      return ;
    }

    setState(() => _friends = friends.acceptedFriends.where(
      (f) => f.username != null ? f.username!.contains(widget.query) : false).toList()
    );
    setState(() => _friends = friends.pendingRequests.where(
      (f) => f.username != null ? f.username!.contains(widget.query) : false).toList()
    );
  }

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: Text('YOUR INVITATION', style: Texting.bodyMedium,),
          ),
          separator(),
          Column(
            spacing: Spacing.sm,
            children: _friends.map(
              (toElement) => FriendSearchCard(friend: toElement)
            ).toList(),
          ),
        ],
      )
    );
  }
}

class FriendSearchCard extends ConsumerStatefulWidget {
  const FriendSearchCard({
    super.key,
    required this._friend,
  });

  final Friend _friend;

  @override
  ConsumerState<FriendSearchCard> createState() => _FriendSearchCardState();
}

class _FriendSearchCardState extends ConsumerState<FriendSearchCard> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Hello'),
        Text('Hi')
      ],
    );
  }
}