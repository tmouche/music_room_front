import 'package:music_room/core/utils/exception.dart';

/// In-memory "backend" shared by every Mock*Repository of the dev flavor.
///
/// The goal is to behave like a tiny server: the data lives in one place, the
/// mutations are persisted for the whole run, and every screen reading it sees
/// the same thing. Accepting a friend request really moves that user from the
/// invitations to the friends list, adding a friend really creates a pending
/// request, etc.
class FakeDb {
  FakeDb._() {
    seed();
  }

  static final FakeDb instance = FakeDb._();

  /// Account returned by [MockAuthRepository] once logged in.
  static const String currentUserId = '1';

  /// Fake network latency, so loading states are visible in dev.
  static const Duration latency = Duration(milliseconds: 350);

  final Map<String, FakeUser>  _users = {};
  final List<FakeFriendship>   _friendships = [];
  final List<FakeInvitation>   _invitations = [];

  // ---------------------------------------------------------------- seeding

  /// Restores the initial scenario. Called once at startup, and usable from a
  /// dev action or a test to start over.
  void  seed() {
    _users
      ..clear()
      ..addEntries(_seedUsers.map((user) => MapEntry(user.id, user.copy())));
    _friendships
      ..clear()
      ..addAll(_seedFriendships.map((friendship) => friendship.copy()));
    _invitations
      ..clear()
      ..addAll(_seedInvitations.map((invitation) => invitation.copy()));
  }

  // ---------------------------------------------------------------- users

  FakeUser get currentUser => userById(currentUserId);

  FakeUser  userById(String id) {
    final user = _users[id];
    if (user == null) throw ApiException('No user with id $id', 404);
    return user;
  }

  FakeUser? userByUsername(String username) {
    final lowered = username.trim().toLowerCase();
    for (final user in _users.values) {
      if (user.username.toLowerCase() == lowered) return user;
    }
    return null;
  }

  /// Everybody but me, matching [query] (empty query returns everybody).
  List<FakeUser>  searchUsers(String query) {
    final lowered = query.trim().toLowerCase();
    return _users.values
      .where((user) => user.id != currentUserId)
      .where((user) => lowered.isEmpty || user.username.toLowerCase().contains(lowered))
      .toList();
  }

  // ---------------------------------------------------------------- friends

  /// Every friendship [userId] takes part in, accepted or still pending.
  List<FakeFriendship>  friendshipsOf(String userId) {
    return _friendships
      .where((friendship) => friendship.involves(userId))
      .toList();
  }

  FakeFriendship? friendshipBetween(String userId, String otherId) {
    for (final friendship in _friendships) {
      if (friendship.involves(userId) && friendship.involves(otherId)) {
        return friendship;
      }
    }
    return null;
  }

  /// [fromId] sends a request to the account named [toUsername].
  void  sendFriendRequest(String fromId, String toUsername) {
    final target = userByUsername(toUsername);
    if (target == null) {
      throw ApiException('No user named $toUsername', 404);
    }
    if (target.id == fromId) {
      throw ApiException('You cannot add yourself', 400);
    }
    final existing = friendshipBetween(fromId, target.id);
    if (existing != null) {
      throw ApiException(
        existing.isPending ? 'A request is already pending' : 'Already friends',
        409,
      );
    }
    _friendships.add(FakeFriendship(
      userId1: fromId,
      userId2: target.id,
      senderId: fromId,
      isPending: true,
    ));
  }

  /// [myId] accepts the request [otherId] sent them.
  void  acceptFriendRequest(String myId, String otherId) {
    final friendship = friendshipBetween(myId, otherId);
    if (friendship == null || !friendship.isPending) {
      throw ApiException('No pending request from $otherId', 404);
    }
    if (friendship.senderId == myId) {
      throw ApiException('You cannot accept your own request', 400);
    }
    friendship.isPending = false;
  }

  /// Used both to reject a pending request and to remove an accepted friend.
  void  removeFriendship(String myId, String otherId) {
    final friendship = friendshipBetween(myId, otherId);
    if (friendship == null) {
      throw ApiException('No friendship with $otherId', 404);
    }
    _friendships.remove(friendship);
  }

  /// Someone out there adds me: handy to check that the invitations list and
  /// its notification refresh on their own.
  void  simulateIncomingRequest(String fromId) {
    sendFriendRequest(fromId, currentUser.username);
  }

  // ---------------------------------------------------------------- invitations

  List<FakeInvitation>  invitationsOf(String userId) {
    return _invitations
      .where((invitation) => invitation.inviteeId == userId)
      .toList();
  }

  void  removeInvitation(String invitationId) {
    _invitations.removeWhere((invitation) => invitation.id == invitationId);
  }

  // ---------------------------------------------------------------- seeds

  /// Scenario: two settled friends, two invitations waiting for me, one
  /// request I sent, and three strangers with the three privacy levels.
  static final List<FakeUser> _seedUsers = [
    FakeUser(
      id: '1',
      username: 'mockUsername',
      email: 'mockEmail@mocker.com',
      emailConfirmed: false,
      googleId: '1',
      favoriteGenres: ['rock', 'jazz'],
      privacyLevel: 'Public',
    ),
    FakeUser(
      id: '2',
      username: 'Alice',
      email: 'alice@mocker.com',
      emailConfirmed: true,
      favoriteGenres: ['pop', 'electro'],
      privacyLevel: 'Public',
    ),
    FakeUser(
      id: '3',
      username: 'Bob',
      email: 'bob@mocker.com',
      emailConfirmed: true,
      favoriteGenres: ['rap'],
      privacyLevel: 'Friends',
    ),
    FakeUser(
      id: '4',
      username: 'Chloe',
      email: 'chloe@mocker.com',
      emailConfirmed: true,
      favoriteGenres: ['jazz', 'soul'],
      privacyLevel: 'Public',
    ),
    FakeUser(
      id: '5',
      username: 'David',
      email: 'david@mocker.com',
      emailConfirmed: false,
      favoriteGenres: ['metal'],
      privacyLevel: 'Public',
    ),
    FakeUser(
      id: '6',
      username: 'Emma',
      email: 'emma@mocker.com',
      emailConfirmed: true,
      favoriteGenres: ['classical'],
      privacyLevel: 'Public',
    ),
    FakeUser(
      id: '7',
      username: 'Farid',
      email: 'farid@mocker.com',
      emailConfirmed: true,
      favoriteGenres: ['techno', 'house'],
      privacyLevel: 'Public',
    ),
    FakeUser(
      id: '8',
      username: 'Gwen',
      email: 'gwen@mocker.com',
      emailConfirmed: true,
      favoriteGenres: ['indie'],
      privacyLevel: 'Friends',
    ),
    FakeUser(
      id: '9',
      username: 'Hugo',
      email: 'hugo@mocker.com',
      emailConfirmed: true,
      favoriteGenres: ['funk'],
      privacyLevel: 'Private',
    ),
  ];

  static final List<FakeFriendship> _seedFriendships = [
    // Accepted friends.
    FakeFriendship(userId1: '1', userId2: '2', senderId: '1', isPending: false),
    FakeFriendship(userId1: '3', userId2: '1', senderId: '3', isPending: false),
    // Invitations waiting for me (accept / reject).
    FakeFriendship(userId1: '4', userId2: '1', senderId: '4', isPending: true),
    FakeFriendship(userId1: '5', userId2: '1', senderId: '5', isPending: true),
    // Request I sent, still pending on their side.
    FakeFriendship(userId1: '1', userId2: '6', senderId: '1', isPending: true),
  ];

  static final List<FakeInvitation> _seedInvitations = [
    FakeInvitation(id: '1', roomId: '1', inviterId: '2', inviteeId: '1'),
  ];
}

/// A user row. [toJson] mirrors the payload shape of the real API so the mocks
/// exercise the same parsing as production.
class FakeUser {
  FakeUser({
    required this.id,
    required this.username,
    required this.email,
    this.emailConfirmed = false,
    this.googleId,
    List<String>? favoriteGenres,
    this.privacyLevel = 'Public',
    this.isSubscribed = false,
  }) : favoriteGenres = favoriteGenres ?? [];

  final String  id;
  String        username;
  String        email;
  bool          emailConfirmed;
  String?       googleId;
  List<String>  favoriteGenres;
  String        privacyLevel;
  bool          isSubscribed;

  FakeUser  copy() {
    return FakeUser(
      id: id,
      username: username,
      email: email,
      emailConfirmed: emailConfirmed,
      googleId: googleId,
      favoriteGenres: List<String>.from(favoriteGenres),
      privacyLevel: privacyLevel,
      isSubscribed: isSubscribed,
    );
  }

  Map<String, dynamic>  toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'email_confirmed': emailConfirmed,
      'google_id': googleId,
      'favorite_genres': List<String>.from(favoriteGenres),
      'privacy_level': privacyLevel,
      'is_subscribed': isSubscribed,
    };
  }
}

/// A friendship row, pending until the receiver accepts it.
class FakeFriendship {
  FakeFriendship({
    required this.userId1,
    required this.userId2,
    required this.senderId,
    required this.isPending,
  });

  final String  userId1;
  final String  userId2;
  final String  senderId;
  bool          isPending;

  bool  involves(String userId) => userId1 == userId || userId2 == userId;

  String  otherThan(String userId) => userId1 == userId ? userId2 : userId1;

  FakeFriendship  copy() {
    return FakeFriendship(
      userId1: userId1,
      userId2: userId2,
      senderId: senderId,
      isPending: isPending,
    );
  }

  Map<String, dynamic>  toJson() {
    return {
      'user_id_1': userId1,
      'user_id_2': userId2,
      'sender_id': senderId,
      'is_pending': isPending,
    };
  }
}

class FakeInvitation {
  FakeInvitation({
    required this.id,
    required this.roomId,
    required this.inviterId,
    required this.inviteeId,
  });

  final String  id;
  final String  roomId;
  final String  inviterId;
  final String  inviteeId;

  FakeInvitation  copy() {
    return FakeInvitation(
      id: id,
      roomId: roomId,
      inviterId: inviterId,
      inviteeId: inviteeId,
    );
  }

  Map<String, dynamic>  toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'inviter_id': inviterId,
      'invitee_id': inviteeId,
      'is_pending': true,
    };
  }
}
