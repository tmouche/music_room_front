import 'package:music_room/core/model/user.dart';
import 'package:music_room/core/storage/session_storage.dart';
import 'package:music_room/features/auth/impl_repository.dart';

class MockAuthController extends AuthController {
  MockAuthController()
  : super();

  @override
  Future<void> login(String email, String password) async {
    await _createFakeAuthenticatedUser();
  }

  @override
  Future<void> loginGoogle() async {
    await _createFakeAuthenticatedUser();
  }

  Future<void> _createFakeAuthenticatedUser() async {
    final String accessToken = 'DevMockAccessToken';

    User user = User(
      id: '1',
      username: 'mockUsername',
      email: 'mockEmail@mocker.com',
      emailConfirmed: false,
      googleId: '1',
      favoriteGenres: ['mockGenre1', 'mockGenre2'],
      privacyLevel: 'Friends',
    );

    state = state.copyWith(
      token: accessToken,
      user: user,
    );

    await SessionStorage.saveSession(
      accessToken: accessToken,
      refreshToken: 'DevMockRefreshToken',
    );
  }

  @override
  Future<void> logout() async {
    state = state.copyWith(
      token: null,
      user: null
    );

    await SessionStorage.clear();
  }

  @override
  Future<void> signin(String username, String email, String password) async {
    await _createFakeAuthenticatedUser();
  }

  @override
  Future<void> updateUsername(String newUsername) async {
    User? user = state.user?.copyWith(username: newUsername);
    state = state.copyWith(user: user);
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> updateEmail(String newEmail) async {
    User? user = state.user?.copyWith(email: newEmail, emailConfirmed: false);
    state = state.copyWith(user: user);
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> updateFavoriteGenres(List<String>? favoriteGenres) async {
    User? user = state.user?.copyWith(favoriteGenres: favoriteGenres);
    state = state.copyWith(user: user);
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> updatePrivacyLevel(String privacyLevel) async {
    User? user = state.user?.copyWith(privacyLevel: privacyLevel);
    state = state.copyWith(user: user);
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void>  confirmEmail() async {
    User? user = state.user?.copyWith(emailConfirmed: true);
    state = state.copyWith(user: user);
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> forgotPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));
  }
}