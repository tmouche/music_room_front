
import 'package:music_room/core/model/friend.dart';

class FriendState {
  const FriendState({
    this._friends = const [],
  });

  final List<Friend> _friends;

  List<Friend> get friends => _friends;
  List<Friend> get pendingRequests => _friends.where((f) => f.isPending && !f.isSender).toList();
  List<Friend> get acceptedFriends => _friends.where((f) => !f.isPending).toList();

  FriendState copyWith({
    List<Friend>? friends
  }) {
    return FriendState(
      friends: friends ?? _friends,
    );
  }
}
