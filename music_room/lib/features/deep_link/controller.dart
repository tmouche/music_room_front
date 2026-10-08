import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/core/notification/controller.dart';
import 'package:music_room/core/notification/provider.dart';
import 'package:music_room/core/utils/logger.dart';
import 'package:music_room/features/auth/controller.dart';
import 'package:music_room/features/auth/provider.dart';
import 'package:music_room/features/deep_link/impl_repository.dart';
import 'package:music_room/features/deep_link/provider.dart';

class DeepLinkController extends Notifier<void> {
  static const String _confirmEmailHost = 'confirm-email';

  String? _pendingEmailToken;

  DeepLinkRepository get      _repo => ref.read(deepLinkRepositoryProvider);
  AuthController get          _auth => ref.read(authProvider.notifier);
  NotificationController get  _notification => ref.read(notificationProvider.notifier);

  @override
  void build() {
    final subscription = _repo.links.listen(_onLink);
    ref.onDispose(subscription.cancel);
    ref.listen(authProvider.select((s) => s.isAuthenticated), (_, isAuthenticated) {
      if (isAuthenticated) _confirmPendingEmail();
    });
  }

  void  _onLink(Uri uri) {
    if (uri.host != _confirmEmailHost) return;
    _pendingEmailToken = uri.queryParameters['token'];
    if (ref.read(authProvider).isAuthenticated) _confirmPendingEmail();
  }

  void  _confirmPendingEmail() {
    final token = _pendingEmailToken;
    if (token == null) return;
    _pendingEmailToken = null;
    unawaited(_confirmEmail(token));
  }

  Future<void>  _confirmEmail(String token) async {
    try {
      await _auth.confirmEmail(token);
      _notification.success('Email confirmed');
    } catch (e) {
      logger.debug('Fail to confirm email: $e');
      _notification.error(
        'Email confirmation failed',
        description: 'The link may have expired, send a new one from your profile.',
      );
    }
  }
}
