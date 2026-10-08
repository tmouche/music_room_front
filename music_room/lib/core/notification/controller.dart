import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/core/notification/notification.dart';

/// Holds the notification currently on screen, if any.
///
/// Showing a new one replaces the current one. Widgets call [error], [hint]
/// or [success]; the shell's NotificationHost watches the state and renders
/// it, then calls [dismiss] when the banner has gone away.
class NotificationController extends Notifier<AppNotification?> {
  int _nextId = 0;

  @override
  AppNotification? build() => null;

  void show(
    NotificationKind kind,
    String title, {
    String? description,
    Duration duration = const Duration(seconds: 5),
  }) {
    state = AppNotification(
      id: _nextId++,
      kind: kind,
      title: title,
      description: description,
      duration: duration,
    );
  }

  void error(String title, {String? description}) =>
      show(NotificationKind.error, title, description: description);

  void hint(String title, {String? description}) =>
      show(NotificationKind.hint, title, description: description);

  void success(String title, {String? description}) =>
      show(NotificationKind.success, title, description: description);

  /// Clears the notification with [id]. A no-op if a newer one has already
  /// replaced it.
  void dismiss(int id) {
    if (state?.id == id) state = null;
  }

  /// Clears whatever is currently shown.
  void clear() => state = null;
}
