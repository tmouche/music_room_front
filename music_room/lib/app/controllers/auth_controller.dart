import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../network/api_client.dart';
import '../storage/session_storage.dart';
import '../utils/exception.dart';
import '../utils/logger.dart';
import '../utils/constant.dart' as constant;
import '../../models/user.dart';

class AuthState {
  const AuthState({
    required this._token,
    required this._user,
    required this._isLoading,
  });

  final String? _token;
  final User? _user;
  final bool _isLoading;

  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  User? get user => _user;
  String? get token => _token;

  AuthState copyWith({
    String? token,
    User? user,
    bool? isLoading,
  }) {
    return AuthState(
      token: token ?? _token,
      user: user ?? _user,
      isLoading: isLoading ?? _isLoading,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController() 
    : super(const AuthState(
      token: null,
      user: null,
      isLoading: false,
  ));


  Future<void> login(String email, String password) async {
    try {
      final data = await ApiClient.post(
        constant.AUTH_LOGIN_ROUTE,
        body: {'email': email, 'password': password},
      );
      if (!data) {
        logger.error('Authentication response is missing.');
        throw ApiException('No response data');
      }
      await _storeAuthenticatedSession(Map<String, dynamic>.from(data as Map));
    } catch (e) {
      logger.error('Login failed', error: e);
      throw ApiException('Authentification Operation failed');
    }
  }

  Future<void> googleLogin() async {
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
      await _storeAuthenticatedSession(Map<String, dynamic>.from(data as Map));
    } catch (e) {
      logger.error('Google Login failed', error: e);
      throw ApiException('Google Authentification Operation failed');
    }
  }

  Future<void> logout() async {
    final refreshToken = await SessionStorage.getRefreshToken();
    final wasAuthenticated = state.isAuthenticated;

    state = state.copyWith(user: null, token: null);

    if (wasAuthenticated && refreshToken != null) {
      try {
        await ApiClient.post(
          constant.AUTH_LOGOUT_ROUTE,
          body: {'refresh_token': refreshToken},
        );
      } catch (e) {
        logger.error('Server logout failed');
        throw ApiException('Logout Operation Failed');
      }

      await SessionStorage.clear();
    }
  }

  Future<void>  register(String username, String email, String password) async {
    try {
      final data = await ApiClient.post(
        constant.AUTH_REGISTER,
        body: {'username': username, 'email': email, 'password': password},
      );
      if (!data) {
        logger.error('Register response is missing');
        throw ApiException('No response data');
      }
      await _storeAuthenticatedSession(Map<String, dynamic>.from(data as Map));
    } catch (e) {
      // ATTENTION AUX COLLISIONS
      logger.error('Registration failed', error: e);
      throw ApiException('Registration Operation failed');
    }
  }

  Future<void> _storeAuthenticatedSession(Map<String, dynamic> data) async {
    final accessToken = data['access_token']?.toString();
    if (accessToken == null || accessToken.isEmpty) {
      throw ApiException('Authentication response is missing an access token.');
    }

    state = state.copyWith(token: accessToken);

    await loadUser();

    await SessionStorage.saveSession(
      accessToken: accessToken,
      refreshToken: data['refresh_token']?.toString(),
    );
  }

  Future<void>  loadUser() async {
    if (state.token == null) {
      logger.error('No token found, Operation impossible');
      throw ApiException('No token');
    }
    state = state.copyWith(isLoading: true);

    User user = await fetchUser();

    state = state.copyWith(user: user, isLoading: false);
  }

  Future<User>  fetchUser() async {
    try {
      final data = await ApiClient.get(constant.USER_ME);
      if (!data) {
        logger.error('User response is missing.');
        throw ApiException('No response data');
      }
      User user = _buildUser(Map<String, dynamic>.from(data as Map));
      return user;
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        logger.warning('User UnAuthorized, forcing logout');
        await logout();
      } else if (e.statusCode == 404) {
        logger.warning('User no longer exist, forcing logout');
        await logout();
      }
      logger.error('Failed to fetch user info', error: e);
      throw ApiException('Fetch User Operation failed');
    } catch (e) {
      logger.error('Failed to fetch user info', error: e);
      throw ApiException('Fetch User Operation failed');
    }
  }
  
  User _buildUser(Map<String, dynamic> data) {
    return User(
      id: data['id'],
      username: data['username'],
      email: data['email'],
      emailConfirmed: data['email_confirmed'] ?? false,
      googleId: data['google_id'],
      favoriteGenres: __parseFavoriteGenres(data['favorite_genres']),
      privacyLevel: data['privacy_level']?.toString() ?? 'Friends',
    );
  }

  List<String>? __parseFavoriteGenres(dynamic rawFavoriteGenres) {
    if (rawFavoriteGenres is! List) {
      return null;
    }

    final favoriteGenres = rawFavoriteGenres
        .map((item) => item.toString())
        .where((item) => item.isNotEmpty)
        .toList();

    return favoriteGenres.isEmpty ? null : favoriteGenres;
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
    
    User? user = state.user?.copyWith(username: newUsername);
    state = state.copyWith(user: user);
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
    
    User? user = state.user?.copyWith(email: newEmail, emailConfirmed: false);
    state = state.copyWith(user: user);
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
    
    User? user = state.user?.copyWith(favoriteGenres: favoriteGenres);
    state = state.copyWith(user: user);
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
    
    User? user = state.user?.copyWith(privacyLevel: privacyLevel);
    state = state.copyWith(user: user);
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
      throw ApiException('Forgor Password Operation failed');
    }
  }
}

final authProvider = StateNotifierProvider<AuthController, AuthState>(((ref) {
  return AuthController();
}));
