
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/core/utils/logger.dart';
import 'package:music_room/features/auth/provider.dart';
import 'package:music_room/features/auth/state.dart';
import 'package:music_room/features/friend/impl_repository.dart';
import 'package:music_room/features/friend/provider.dart';
import 'package:music_room/features/friend/state.dart';

class FriendController extends Notifier<FriendState> {
  
  @override
  FriendState build() {
    final userId = ref.watch(authProvider.select((s) => s.user?.id));
    if (userId != null) _refreshFriendsInBackground();
    return FriendState();
  }

  AuthState get         _auth => ref.read(authProvider);
  FriendRepository get  _repo => ref.read(friendRepositoryProvider);

  Future<void>  refreshFriends() async {
    final friends = await _repo.getFriends(_auth.user!.id);
    state = state.copyWith(friends: friends);
  }

  void  _refreshFriendsInBackground() {
    unawaited(refreshFriends().catchError((Object e) {
      logger.debug('Fail to fetch Friends: $e');
    }));
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
    await _repo.rejectFriendInvite(userId);
    await refreshFriends();
  }
}
