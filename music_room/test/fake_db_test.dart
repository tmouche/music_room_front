import 'package:flutter_test/flutter_test.dart';
import 'package:music_room/core/utils/exception.dart';
import 'package:music_room/data/fake_db.dart';
import 'package:music_room/features/friend/mock_repository.dart';

void main() {
  final db = FakeDb.instance;
  final repo = MockFriendRepository();

  setUp(db.seed);

  group('FakeDb seed', () {
    test('splits friends between accepted and pending', () async {
      final friends = await repo.getFriends(FakeDb.currentUserId);

      final accepted = friends.where((f) => !f.isPending).map((f) => f.username);
      final received = friends.where((f) => f.isPending && !f.isSender).map((f) => f.username);
      final sent = friends.where((f) => f.isPending && f.isSender).map((f) => f.username);

      expect(accepted, containsAll(['Alice', 'Bob']));
      expect(received, containsAll(['Chloe', 'David']));
      expect(sent, ['Emma']);
    });
  });

  group('friend requests', () {
    test('accepting a request moves the user to the friends', () async {
      await repo.acceptFriendInvite('4');

      final friends = await repo.getFriends(FakeDb.currentUserId);
      final chloe = friends.firstWhere((f) => f.friendId == '4');
      expect(chloe.isPending, isFalse);
    });

    test('rejecting a request drops it', () async {
      await repo.rejectFriendInvite('4');

      final friends = await repo.getFriends(FakeDb.currentUserId);
      expect(friends.any((f) => f.friendId == '4'), isFalse);
    });

    test('removing a friend drops the friendship', () async {
      await repo.deleteFriend('2');

      final friends = await repo.getFriends(FakeDb.currentUserId);
      expect(friends.any((f) => f.friendId == '2'), isFalse);
    });

    test('adding a stranger creates a request I sent', () async {
      await repo.addFriend('Farid');

      final friends = await repo.getFriends(FakeDb.currentUserId);
      final farid = friends.firstWhere((f) => f.friendId == '7');
      expect(farid.isPending, isTrue);
      expect(farid.isSender, isTrue);
    });

    test('adding an unknown username fails', () {
      expect(() => repo.addFriend('Nobody'), throwsA(isA<ApiException>()));
    });

    test('adding an existing friend fails', () {
      expect(() => repo.addFriend('Alice'), throwsA(isA<ApiException>()));
    });

    test('an incoming request shows up as a received invitation', () async {
      db.simulateIncomingRequest('7');

      final friends = await repo.getFriends(FakeDb.currentUserId);
      final farid = friends.firstWhere((f) => f.friendId == '7');
      expect(farid.isPending, isTrue);
      expect(farid.isSender, isFalse);
    });
  });
}
