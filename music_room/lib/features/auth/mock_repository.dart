import 'package:music_room/data/fake_db.dart';
import 'package:music_room/features/auth/impl_repository.dart';

/// Auth repository backed by [FakeDb]: profile edits are persisted, and
/// `getUser` returns the real row of the requested account instead of always
/// the same stub.
class MockAuthRepository extends AuthRepository {
  MockAuthRepository() : super();

  final FakeDb  _db = FakeDb.instance;

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    return _authenticatedSession();
  }

  @override
  Future<Map<String, dynamic>> loginGoogle() async {
    return _authenticatedSession();
  }

  @override
  Future<Map<String, dynamic>> signin(String username, String email, String password) async {
    return _authenticatedSession();
  }

  Map<String, dynamic> _authenticatedSession() {
    return {
      ..._db.currentUser.toJson(),
      'access_token': 'DevMockAccessToken',
      'refresh_token': 'DevMockRefreshToken',
    };
  }

  @override
  Future<Map<String, dynamic>>  getUser(String userId) async {
    await Future.delayed(FakeDb.latency);
    return _db.userById(userId).toJson();
  }

  @override
  Future<Map<String, dynamic>>  fetchUser() async {
    await Future.delayed(FakeDb.latency);
    return _db.currentUser.toJson();
  }

  @override
  Future<void> logout(String refreshToken) async {}

  @override
  Future<void> updateUsername(String newUsername) async {
    await Future.delayed(FakeDb.latency);
    _db.currentUser.username = newUsername;
  }

  @override
  Future<void> updateEmail(String newEmail) async {
    await Future.delayed(FakeDb.latency);
    _db.currentUser
      ..email = newEmail
      ..emailConfirmed = false;
  }

  @override
  Future<void> updatePassword(String currentPassword, String newPassword) async {}

  @override
  Future<void> updateFavoriteGenres(List<String>? favoriteGenres) async {
    await Future.delayed(FakeDb.latency);
    _db.currentUser.favoriteGenres = List<String>.from(favoriteGenres ?? []);
  }

  @override
  Future<void> updatePrivacyLevel(String privacyLevel) async {
    await Future.delayed(FakeDb.latency);
    _db.currentUser.privacyLevel = privacyLevel;
  }

  @override
  Future<void>  sendConfirmationEmail() async {
    await Future.delayed(FakeDb.latency);
  }

  @override
  Future<void>  confirmEmail(String token) async {
    await Future.delayed(FakeDb.latency);
    _db.currentUser.emailConfirmed = true;
  }

  @override
  Future<Map<String, dynamic>>  enableSubscription() async {
    await Future.delayed(FakeDb.latency);
    _db.currentUser.isSubscribed = true;
    return _db.currentUser.toJson();
  }

  @override
  Future<void> forgotPassword(String email) async {}
}
