
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
    String? query,
  }) : _query = query ?? "";

  final String _query;

  @override
  ConsumerState<FriendSearch>  createState() => _FriendSearchState();
} 

class _FriendSearchState extends ConsumerState<FriendSearch> {
  List<Friend>  _friends = [];
  List<Friend>  _pendingFriends = [];

  @override
  Widget build(BuildContext context) {
    final friends = ref.watch(friendProvider);
    if (widget._query.isEmpty) {
      _friends = friends.acceptedFriends;
      _pendingFriends = friends.pendingRequests;
    } else {
      _friends = friends.acceptedFriends.where(
        (f) => f.username != null && f.username!.contains(widget._query)).toList();
      _pendingFriends = friends.pendingRequests.where(
        (f) => f.username != null && f.username!.contains(widget._query)).toList();
    }
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
