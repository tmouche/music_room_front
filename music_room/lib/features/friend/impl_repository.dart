
import 'package:music_room/core/model/friend.dart';
import 'package:music_room/core/network/api_client.dart';
import 'package:music_room/core/network/api_path.dart';
import 'package:music_room/core/utils/logger.dart';

class FriendRepository {
  FriendRepository();

  Future<List<Friend>>  getFriends(String myId) async {
    final               response = await ApiClient.get(ApiPath.friends);
    final List<dynamic> rawList = List<dynamic>.from(response);
    final List<Friend>  fetchedFriends = [];
    for (final item in rawList) {
      final friend = Friend.fromJson(item, myId);
      try {
        final userRes = await ApiClient.get(ApiPath.usersGet(friend.friendId));
        friend.username = userRes['username'];
      } catch (e) {
        logger.debug('Fail to fetch user: $e');
      }
      fetchedFriends.add(friend);
    }
    return fetchedFriends;
  }

  Future<void>  addFriend(String username) async {
    await ApiClient.post(ApiPath.friends, body: {'username': username});
  }

  Future<void>  deleteFriend(String userId) async {
    await ApiClient.delete(ApiPath.friendsDelete(userId));
  }

  Future<void>  inviteToRoom(String roomId, String inviteeId) async {
    await ApiClient.post(ApiPath.roomsInvite(roomId, inviteeId));
  }

  Future<void>  acceptFriendInvite(String userId) async {
    await ApiClient.post(ApiPath.friendsInviteAccept(userId));
  }

  Future<void>  rejectFriendInvite(String userId) async {
    await ApiClient.delete(ApiPath.friendsInviteReject(userId));
  }

}