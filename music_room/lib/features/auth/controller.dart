import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/core/model/user.dart';
import 'package:music_room/core/network/api_client.dart';
import 'package:music_room/core/storage/session_storage.dart';
import 'package:music_room/core/utils/exception.dart';
import 'package:music_room/core/utils/logger.dart';
import 'package:music_room/features/auth/impl_repository.dart';
import 'package:music_room/features/auth/provider.dart';
import 'package:music_room/features/auth/state.dart';

class AuthController extends Notifier<AuthState> {

  late final AuthRepository _repo;

  @override
  AuthState build() {
    _repo = ref.read(authRepositoryProvider);
    ApiClient.onUnauthorized = _handleUnauthorized;
    return const AuthState();
  }

  /// Must stay synchronous: the auth interceptor fires it on an
  /// unrecoverable 401 and does not await it.
  void _handleUnauthorized() {
    logger.warning('Session invalid, clearing local session');
    state = const AuthState();
    unawaited(SessionStorage.clear());
  }

  Future<void>  login(String email, String password) async {
    final Map<String, dynamic> data = await _repo.login(email, password);
    await _storeAuthenticatedSession(data);
  }

  Future<void>  loginGoogle() async {
    final Map<String, dynamic> data = await _repo.loginGoogle();
    await _storeAuthenticatedSession(data);
  }

  Future<void> _storeAuthenticatedSession(Map<String, dynamic> data) async {
    final accessToken = data['access_token']?.toString();
    final refreshToken = data['refresh_token']?.toString();
    if (
      (accessToken == null || accessToken.isEmpty)
      || (refreshToken == null || refreshToken.isEmpty)
    ) {
      throw ApiException('Authentication response is missing an access token.');
    }

    state = state.copyWith(token: accessToken);

    await SessionStorage.saveSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    await loadUser();
  }

  Future<void>  loadUser() async {
    if (state.token == null) {
      logger.error('No token found, Operation impossible');
      throw ApiException('No token');
    }
    state = state.copyWith(isLoading: true);

    final Map<String, dynamic> data = await _repo.fetchUser();
    final User user = _buildUser(Map<String, dynamic>.from(data as Map));

    state = state.copyWith(user: user, isLoading: false);
  }

  Future<User>  getUser(String userId) async {
    final response = await _repo.getUser(userId);
    return _buildUser(response);
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
      premiumUser: data['is_subscribed'] ?? false,
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

  Future<void> logout() async {
    final refreshToken = await SessionStorage.getRefreshToken();
    final wasAuthenticated = state.isAuthenticated;
    state = const AuthState();
    if (wasAuthenticated && refreshToken != null) {
      await _repo.logout(refreshToken);
      await SessionStorage.clear();
    }
  }

  Future<void>  signin(String username, String email, String password) async {
    final Map<String, dynamic> data = await _repo.signin(username, email, password);
    await _storeAuthenticatedSession(Map<String, dynamic>.from(data as Map));
  }

  Future<void>  updateUsername(String newUsername) async {
    await _repo.updateUsername(newUsername);

    User  user = state.user!.copyWith(username: newUsername);
    state = state.copyWith(user: user);
  }

  Future<void>  updateEmail(String newEmail) async {
    await _repo.updateEmail(newEmail);

    User  user = state.user!.copyWith(email: newEmail, emailConfirmed: false);
    state = state.copyWith(user: user);
  }

  Future<void>  updatePassword(String currentPassword, String newPassword) async {
    await _repo.updatePassword(currentPassword, newPassword);
  }

  Future<void>  updateFavoriteGenres(List<String>? favoriteGenres) async {
    await _repo.updateFavoriteGenres(favoriteGenres);

    User  user = state.user!.copyWith(favoriteGenres: favoriteGenres);
    state = state.copyWith(user: user);
  }

  Future<void>  updatePrivacyLevel(String privacyLevel) async {
    await _repo.updatePrivacyLevel(privacyLevel);

    User user = state.user!.copyWith(privacyLevel: privacyLevel);
    state = state.copyWith(user: user);
  }

  Future<void>  sendConfirmationEmail() async {
    await _repo.sendConfirmationEmail();
    state = state.copyWith(isConfirmationEmailSent: true);
  }

  Future<void>  confirmEmail(String token) async {
    await _repo.confirmEmail(token);
    await loadUser();
  }

  Future<void>  subscribe() async {
    final Map<String, dynamic> data = await _repo.enableSubscription();
    state = state.copyWith(user: _buildUser(data));
  }

  Future<void>  forgotPassword(String email) async {
    await _repo.forgotPassword(email);
  }
}
