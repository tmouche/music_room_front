import 'package:music_room/core/network/api_client.dart';
import 'package:music_room/core/utils/constant.dart' as constant;
import 'package:music_room/core/utils/exception.dart';
import 'package:music_room/core/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  AuthRepository();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final data = await ApiClient.post(
        constant.AUTH_LOGIN_ROUTE,
        body: {'email': email, 'password': password},
      );
      if (!data) {
        logger.error('Authentication response is missing.');
        throw ApiException('No response data');
      }
      return data as Map<String, dynamic>;
    } catch (e) {
      logger.error('Login failed', error: e);
      throw ApiException('Authentification Operation failed');
    }
  }

  Future<Map<String, dynamic>>  fetchUser() async {
    try {
      final data = await ApiClient.get(constant.USER_ME);
      if (!data) {
        logger.error('User response is missing.');
        throw ApiException('No response data');
      }
      return data as Map<String, dynamic>;
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        logger.warning('User UnAuthorized, forcing logout');
        await logout(''); // ATTENTION ICI ON PREFERE UN REFRESH
      } else if (e.statusCode == 404) {
        logger.warning('User no longer exist, forcing logout');
        await logout(''); // '' EST TEMPORAIRE
      }
      logger.error('Failed to fetch user info', error: e);
      throw ApiException('Fetch User Operation failed');
    } catch (e) {
      logger.error('Failed to fetch user info', error: e);
      throw ApiException('Fetch User Operation failed');
    }
  }

  Future<Map<String, dynamic>> loginGoogle() async {
    if (kIsWeb) {
      logger.warning('Google Authentification is not available on Web');
      throw ApiException('Google Authentification not available.');
    }
    
    try {
      final GoogleSignInAccount account = await GoogleSignIn.instance
        .authenticate(scopeHint: ['email', 'profile']);

      final GoogleSignInAuthentication auth = account.authentication;
      final String? idToken = auth.idToken;

      if (idToken == null) {
        logger.error('Google token is missing.');
        throw ApiException('No Auth Token');
      }

      final data = await ApiClient.post(
        constant.AUTH_GOOGLE_LOGIN_ROUTE,
        body: {'id_token': idToken},
      );
      if (!data) {
        logger.error('Authentication response is missing.');
        throw ApiException('No response data');
      }
      return data;
    } catch (e) {
      logger.error('Google Login failed', error: e);
      throw ApiException('Google Authentification Operation failed');
    }
  }
  
  Future<void> logout(String refreshToken) async {
    try {
      await ApiClient.post(
        constant.AUTH_LOGOUT_ROUTE,
        body: {'refresh_token': refreshToken},
      );
    } catch (e) {
      logger.error('Server logout failed');
      throw ApiException('Logout Operation Failed');
    }
  }

  Future<Map<String, dynamic>> signin(String username, String email, String password) async {
    try {
      final data = await ApiClient.post(
        constant.AUTH_REGISTER,
        body: {'username': username, 'email': email, 'password': password},
      );
      if (!data) {
        logger.error('Register response is missing');
        throw ApiException('No response data');
      }
      return data as Map<String, dynamic>;
    } catch (e) {
      // ATTENTION AUX COLLISIONS
      logger.error('Registration failed', error: e);
      throw ApiException('Registration Operation failed');
    }
  }

  Future<void> updateUsername(String newUsername) async {
    try {
      await ApiClient.patch(
        constant.USER_UPDATE_USERNAME,
        body: {'username': newUsername}
      );
    } catch (e) {
      // ICI il pourrait avoir un pb de collision il faut donc voir si le back
      // retourne une erreur differente et lancer des Exceptions en concéquence
      logger.error('Failed to update user Username', error: e);
      throw ApiException('Update Username Operation failed');
    }
  }

  Future<void> updateEmail(String newEmail) async {
    try {
      await ApiClient.patch(
        constant.USER_UPDATE_EMAIL,
        body: {'new_email': newEmail}
      );
    } catch (e) {
      // ICI il pourrait avoir un pb de collision il faut donc voir si le back
      // retourne une erreur differente et lancer des Exceptions en concéquence
      logger.error('Failed to update user Email', error: e);
      throw ApiException('Update Email Operation failed');
    }
  }

  Future<void> updatePassword(String currentPassword, String newPassword) async {
    try {
      await ApiClient.patch(
        constant.USER_UPDATE_PASSWORD,
        body: {'current_password': currentPassword, 'new_password': newPassword},
      );
    } catch (e) {
      logger.error('Failed to update user Password', error: e);
      throw ApiException('Update Password Operation failed');
    }
  }

  Future<void> updateFavoriteGenres(List<String>? favoriteGenres) async {
    try {
      await ApiClient.patch(
        constant.USER_UPDATE_FAVORITE_GENRES,
        body: {'favorite_genres': favoriteGenres}
      );
    } catch (e) {
      logger.error('Failed to update user Favorite Genres', error: e);
      throw ApiException('Update Favorite Genres Operation failed');
    }
  }

  Future<void> updatePrivacyLevel(String privacyLevel) async {
    try {
      await ApiClient.patch(
        constant.USER_UPDATE_PRIVACY,
        body: {'privacy_level': privacyLevel}
      );
    } catch (e) {
      logger.error('Failed to update user Privacy Level', error: e);
      throw ApiException('Update Privacy Level Operation failed');
    }
  }

  Future<void>  confirmEmail() async {
    try {
      await ApiClient.post(constant.USER_CONFIRM_EMAIL);
    } catch (e) {
      logger.error('Failed to confirm user email', error: e);
      throw ApiException('Confirm Email Operation failed');
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await ApiClient.post(constant.AUTH_FORGOT_PASSWORD_ROUTE, body: {'email': email});
    } catch (e) {
      logger.error('Failed to start reseting password');
      throw ApiException('Forgot Password Operation failed');
    }
  }
}
