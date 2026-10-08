class Invitation {
  final String _id;
  final String _roomId;
  final String _inviterId;
  final String? _inviterUsername;

  Invitation({
    required this._id,
    required this._roomId,
    required this._inviterId,
    this._inviterUsername,
  });

  String get id => _id;
  String get roomId => _roomId;
  String get inviterId => _inviterId;
  String? get inviterUsername => _inviterUsername;

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id'],
      roomId: json['room_id'],
      inviterId: json['inviter_id'],
    );
  }

  Invitation copyWith({String? inviterUsername}) {
    return Invitation(
      id: _id,
      roomId: _roomId,
      inviterId: _inviterId,
      inviterUsername: inviterUsername ?? _inviterUsername,
    );
  }
}
