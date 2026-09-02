
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/core/model/friend.dart';
import 'package:music_room/core/utils/logger.dart';
import 'package:music_room/features/auth/provider.dart';
import 'package:music_room/features/auth/state.dart';
import 'package:music_room/features/friend/impl_repository.dart';
import 'package:music_room/features/friend/provider.dart';
import 'package:music_room/features/friend/state.dart';

class FriendController extends Notifier<FriendState> {
  
  @override
  FriendState build() {
    _auth = ref.read(authProvider);
    _repo = ref.read(friendRepositoryProvider);
    final friendState = FriendState();
    refreshFriends();
    return friendState;
  }

  late final AuthState        _auth;
  late final FriendRepository _repo;

  Future<List<Friend>>  getFriends() async {
    await refreshFriends();
    return state.friends;
  }

  Future<void>  refreshFriends() async {
    List<Friend>  friends = [];
    try {
      final userId = _auth.user!.id;
      friends = await _repo.getFriends(userId);
    } catch (e) {
      logger.debug("Fail to fetch Friends");
      rethrow ;
    } finally {
      state = state.copyWith(friends: friends);
    }
  }

  Future<void>  addFriend(String username) async {
    await _repo.addFriend(username);
    await refreshFriends();
  }

  Future<void>  deleteFriend(String userId) async {
    await _repo.deleteFriend(userId);
    await refreshFriends();
  }

  Future<void>  inviteToRoom(String roomId, String inviteeId) async {
    await _repo.inviteToRoom(roomId, inviteeId);
  }

  Future<void>  acceptFriendInvite(String userId) async {
    await _repo.acceptFriendInvite(userId);
    await refreshFriends();
  }

  Future<void>  rejectFriendInvite(String userId) async {
    return await _repo.rejectFriendInvite(userId);
  }
}
