import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/core/model/user.dart';
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
    return AuthState();
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

    await loadUser();

    await SessionStorage.saveSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
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

  Future<void> logout() async {
    final refreshToken = await SessionStorage.getRefreshToken();
    final wasAuthenticated = state.isAuthenticated;

    state = state.copyWith(user: null, token: null);
    if (wasAuthenticated && refreshToken != null) {
      _repo.logout(refreshToken);
      await SessionStorage.clear();
    }
  }

  Future<void>  signin(String username, String email, String password) async {
    final Map<String, dynamic> data = await _repo.signin(username, email, password);
    await _storeAuthenticatedSession(Map<String, dynamic>.from(data as Map));
  }

  void  updateUsername(String newUsername) {
    unawaited(_repo.updateUsername(newUsername));

    User  user = state.user!.copyWith(username: newUsername);
    state = state.copyWith(user: user);
  }

  void  updateEmail(String newEmail) {
    unawaited(_repo.updateEmail(newEmail));

    User  user = state.user!.copyWith(email: newEmail, emailConfirmed: false);
    state = state.copyWith(user: user);
  }

  void  updatePassword(String currentPassword, String newPassword) {
    unawaited(_repo.updatePassword(currentPassword, newPassword));
  }

  void  updateFavoriteGenres(List<String>? favoriteGenres) {
    unawaited(_repo.updateFavoriteGenres(favoriteGenres));

    User  user = state.user!.copyWith(favoriteGenres: favoriteGenres);
    state = state.copyWith(user: user);
  }

  void  updatePrivacyLevel(String privacyLevel) {
    unawaited(_repo.updatePrivacyLevel(privacyLevel));

    User user = state.user!.copyWith(privacyLevel: privacyLevel);
    state = state.copyWith(user: user);
  }

  void  confirmEmail() async {
    unawaited(_repo.confirmEmail());
  }

  void  forgotPassword() async {
    unawaited(_repo.forgotPassword(state.user!.email!));
  }
}
