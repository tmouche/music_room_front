
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/app/theme/texting.dart';
import 'package:music_room/core/model/friend.dart';
import 'package:music_room/features/friend/provider.dart';
import 'package:music_room/screens/profile/widgets/friend_search_card.dart';
import 'package:music_room/widgets/drop_down_list.dart';
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
      (f) => f.username != null && f.username!.contains(widget.query)).toList()
    );
    setState(() => _pendingFriends = friends.pendingRequests.where(
      (f) => f.username != null && f.username!.contains(widget.query)).toList()
    );
  }

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: Column(
        children: [
          DropDownList(
            title: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text('YOUR INVITATIONS', style: Texting.bodyMedium,),
                ),
                separator(),
              ],
            ),
            children: _pendingFriends.map((f) => FriendSearchCard(friend: f, isPending: true,)).toList()
          ),
          DropDownList(
            title: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text('YOUR FRIENDS', style: Texting.bodyMedium,),
                ),
                separator(),
              ],
            ),
            children: _friends.map((f) => FriendSearchCard(friend: f)).toList()
          ),
        ],
      ),
    );
  }
}
