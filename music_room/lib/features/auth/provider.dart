
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/features/auth/impl_repository.dart';
import 'package:music_room/features/auth/state.dart';

final authProvider = NotifierProvider<AuthController, AuthState>(
  () => AuthController(),
);
