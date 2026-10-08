import 'package:music_room/core/model/invitation.dart';
import 'package:music_room/data/fake_db.dart';
import 'package:music_room/features/inbox/impl_repository.dart';

class MockInboxRepository extends InboxRepository {
  MockInboxRepository() : super();

  final FakeDb  _db = FakeDb.instance;

  @override
  Future<List<Invitation>>  getInvitations() async {
    await Future.delayed(FakeDb.latency);
    return _db.invitationsOf(FakeDb.currentUserId).map((fakeInvitation) {
      final invitation = Invitation.fromJson(fakeInvitation.toJson());
      return invitation.copyWith(
        inviterUsername: _db.userById(invitation.inviterId).username,
      );
    }).toList();
  }

  @override
  Future<void>  acceptInvitation(String invitationId) async {
    await Future.delayed(FakeDb.latency);
    _db.removeInvitation(invitationId);
  }

  @override
  Future<void>  rejectInvitation(String invitationId) async {
    await Future.delayed(FakeDb.latency);
    _db.removeInvitation(invitationId);
  }
}
