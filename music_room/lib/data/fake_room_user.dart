
import 'package:music_room/core/model/room_user.dart';
import 'package:music_room/data/fake_db.dart';

/// Room listeners are real [FakeDb] accounts, so opening a listener's profile
/// from a room lands on a user whose friend status is coherent (friend,
/// invitation received, request sent, or stranger).
RoomUser _listener(String userId) {
  final user = FakeDb.instance.userById(userId);
  return RoomUser(id: user.id, username: user.username);
}

final fakeUser1 = _listener('2'); // Alice   - friend
final fakeUser2 = _listener('3'); // Bob     - friend, profile visible to friends only
final fakeUser3 = _listener('4'); // Chloe   - invitation received
final fakeUser4 = _listener('5'); // David   - invitation received
final fakeUser5 = _listener('6'); // Emma    - request sent, still pending
final fakeUser6 = _listener('7'); // Farid   - stranger, public profile
final fakeUser7 = _listener('8'); // Gwen    - stranger, friends-only profile
