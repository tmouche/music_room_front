import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/core/utils/busy_notifier.dart';
import 'package:music_room/features/auth/provider.dart';

final loginBusyProvider = NotifierProvider.autoDispose<BusyNotifier, bool>(BusyNotifier.new);

class LogInView {
  const LogInView({required this._isLogged});
  
  final bool _isLogged;

  bool get isLogged => _isLogged;
}

final logInViewProvider = Provider.autoDispose<LogInView>((ref) => LogInView(
  isLogged: ref.watch(authProvider.select((s) => s.isAuthenticated),
)));
