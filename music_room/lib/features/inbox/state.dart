import 'package:music_room/core/model/invitation.dart';

class InboxState {
  const InboxState({
    this._invitations = const [],
  });

  final List<Invitation> _invitations;

  List<Invitation> get invitations => _invitations;

  InboxState copyWith({
    List<Invitation>? invitations,
  }) {
    return InboxState(
      invitations: invitations ?? _invitations,
    );
  }
}
