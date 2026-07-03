
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/features/auth/controller.dart';
import 'package:music_room/features/auth/impl_repository.dart';
import 'package:music_room/features/auth/state.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authProvider = NotifierProvider<AuthController, AuthState>(
  () => AuthController(),
);
