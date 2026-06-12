import 'package:music_room/core/model/user.dart';

class AuthState {
  const AuthState({
    this._token,
    this._user,
    this._isLoading = false,
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