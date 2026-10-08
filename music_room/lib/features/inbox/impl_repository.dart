import 'package:music_room/core/model/invitation.dart';
import 'package:music_room/core/network/api_client.dart';
import 'package:music_room/core/network/api_path.dart';
import 'package:music_room/core/utils/logger.dart';

class InboxRepository {
  InboxRepository();

  Future<List<Invitation>>  getInvitations() async {
    final response = await ApiClient.get(ApiPath.invitations);
    final invitations = List<dynamic>.from(response)
      .map((json) => Invitation.fromJson(json));
    return Future.wait(invitations.map(_withInviterUsername));
  }

  Future<Invitation>  _withInviterUsername(Invitation invitation) async {
    try {
      final response = await ApiClient.get(ApiPath.usersGet(invitation.inviterId));
      return invitation.copyWith(inviterUsername: response['username']);
    } catch (e) {
      logger.debug('Fail to fetch user: $e');
      return invitation;
    }
  }

  Future<void>  acceptInvitation(String invitationId) async {
    await ApiClient.post(ApiPath.invitationsAccept(invitationId));
  }

  Future<void>  rejectInvitation(String invitationId) async {
    await ApiClient.post(ApiPath.invitationsReject(invitationId));
  }
}
