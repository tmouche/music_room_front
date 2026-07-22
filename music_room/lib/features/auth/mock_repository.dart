import 'package:music_room/features/auth/impl_repository.dart';

class MockAuthRepository extends AuthRepository {
  MockAuthRepository()
  : super();

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    return _createFakeAuthenticatedUser();
  }

  @override
  Future<Map<String, dynamic>> loginGoogle() async {
    return _createFakeAuthenticatedUser();
  }

  Map<String, dynamic> _createFakeAuthenticatedUser() {
    final String accessToken = 'DevMockAccessToken';
    final String refreshToken = 'DevMockRefreshToken';

    return {
      'id': '1',
      'username': 'mockUsername',
      'email': 'mockEmail@mocker.com',
      'emailConfirmed': false,
      'googleId': '1',
      'favoriteGenres': ['mockGenre1', 'mockGenre2'],
      'privacyLevel': 'Friends',
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }

  @override
  Future<void> logout(String refreshToken) async {
    return ;
  }

  @override
  Future<Map<String, dynamic>>  fetchUser() async {
    return _createFakeAuthenticatedUser();
  }

  @override
  Future<Map<String, dynamic>> signin(String username, String email, String password) async {
    return _createFakeAuthenticatedUser();
  }

  @override
  Future<void> updateUsername(String newUsername) async {
    return ;
  }

  @override
  Future<void> updateEmail(String newEmail) async {
    return ;
  }

  @override
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    return ;
  }

  @override
  Future<void> updateFavoriteGenres(List<String>? favoriteGenres) async {
    return ;
  }

  @override
  Future<void> updatePrivacyLevel(String privacyLevel) async {
    return ;
  }

  @override
  Future<void>  confirmEmail() async {
    return ;
  }

  @override
  Future<void> forgotPassword(String email) async {
    return ;
  }
}