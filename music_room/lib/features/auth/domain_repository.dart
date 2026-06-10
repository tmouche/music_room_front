import 'package:flutter_riverpod/legacy.dart';

abstract class AuthControllerOLD{

  bool getIsAuthenticated();

  Future<void> login(String email, String password);
  Future<void> loginGoogle();
  Future<void> logout();
  Future<void> signin(String username, String email, String password);

  Future<void> updateUsername(String newUsername);
  Future<void> updateEmail(String newEmail);
  Future<void> updatePassword(String currentPassword, String newPassword);
  Future<void> updateFavoriteGenres(List<String>? favoritesGenres);
  Future<void> updatePrivacyLevel(String privacyLevel);
  Future<void> confirmEmail();
  Future<void> forgotPassword(String email);
}

