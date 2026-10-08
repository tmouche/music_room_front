import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/core/notification/notification.dart';
import 'package:music_room/core/notification/provider.dart';
import 'package:music_room/core/utils/exception.dart';
import 'package:music_room/core/utils/logger.dart';

class BusyNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  Future<bool> run(
    Future<void> Function() action, {
    String? label,
    NotificationKind apiErrorKind = NotificationKind.error,
  }) async {
    final (ok, _) = await _guard(action, label: label, apiErrorKind: apiErrorKind);
    return ok;
  }

  Future<T?> fetch<T>(
    Future<T> Function() action, {
    String? label,
    NotificationKind apiErrorKind = NotificationKind.error,
  }) async {
    final (ok, value) = await _guard(action, label: label, apiErrorKind: apiErrorKind);
    return ok ? value : null;
  }

  Future<(bool, T?)> _guard<T>(
    Future<T> Function() action, {
    String? label,
    required NotificationKind apiErrorKind,
  }) async {
    if (state) return (false, null);
    state = true;

    final notifier = ref.read(notificationProvider.notifier);
    final what = label ?? 'Request';

    try {
      final value = await action();
      return (true, value);
    } on ApiException catch (e) {
      logger.debug('$what failed: ${e.message}');
      notifier.show(apiErrorKind, label ?? "Something went wrong", description: e.message);
      return (false, null);
    } on ServerException {
      logger.error('$what failed: ${ServerException.message}');
      notifier.error('Internal Server Error.', description: '$what failed, please try again.');
      return (false, null);
    } catch (e, st) {
      logger.error('$what failed', error: e, stackTrace: st);
      notifier.error('Internal Server Error.', description: '$what failed, please try again.');
      return (false, null);
    } finally {
      if (ref.mounted) state = false;
    }
  }
}
