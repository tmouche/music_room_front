
import 'package:music_room/core/model/friend.dart';
import 'package:music_room/data/fake_friends.dart';
import 'package:music_room/features/friend/impl_repository.dart';

class MockFriendRepository extends FriendRepository {
  MockFriendRepository() : super();

  @override
  Future<List<Friend>>  getFriends(String myId) async {
    return [
      friend1,
      friend2,
      friend3,
      friend4,
    ];
  }

  @override
  Future<void>  addFriend(String username) async {}

  @override
  Future<void>  deleteFriend(String userId) async {}

  @override
  Future<void>  inviteToRoom(String roomId, String inviteeId) async {}

  @override
  Future<void>  acceptFriendInvite(String userId) async {}

  @override
  Future<void>  rejectFriendInvite(String userId) async {}
}