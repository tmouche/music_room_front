
import 'package:music_room/core/model/friend.dart';
import 'package:music_room/data/fake_db.dart';
import 'package:music_room/features/friend/impl_repository.dart';

/// Friend repository backed by [FakeDb]: every mutation is persisted for the
/// run, so the friends / invitations lists really change after an accept, a
/// reject or a removal.
class MockFriendRepository extends FriendRepository {
  MockFriendRepository() : super();

  final FakeDb  _db = FakeDb.instance;

  @override
  Future<List<Friend>>  getFriends(String myId) async {
    await Future.delayed(FakeDb.latency);
    return _db.friendshipsOf(myId).map((friendship) {
      final friend = Friend.fromJson(friendship.toJson(), myId);
      // Mirrors the impl repository, which resolves the username with a
      // second call on /users/:id.
      friend.username = _db.userById(friend.friendId).username;
      return friend;
    }).toList();
  }

  @override
  Future<void>  addFriend(String username) async {
    await Future.delayed(FakeDb.latency);
    _db.sendFriendRequest(FakeDb.currentUserId, username);
  }

  @override
  Future<void>  deleteFriend(String userId) async {
    await Future.delayed(FakeDb.latency);
    _db.removeFriendship(FakeDb.currentUserId, userId);
  }

  @override
  Future<void>  inviteToRoom(String roomId, String inviteeId) async {
    await Future.delayed(FakeDb.latency);
  }

  @override
  Future<void>  acceptFriendInvite(String userId) async {
    await Future.delayed(FakeDb.latency);
    _db.acceptFriendRequest(FakeDb.currentUserId, userId);
  }

  @override
  Future<void>  rejectFriendInvite(String userId) async {
    await Future.delayed(FakeDb.latency);
    _db.removeFriendship(FakeDb.currentUserId, userId);
  }
}
