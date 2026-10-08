enum NotificationKind { error, hint, success }

/// A transient message shown to the user by the app shell.
///
/// Pure data: how it looks (color, icon, animation) is decided by the
/// widget that renders it, not here.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    this.description,
    this.duration = const Duration(seconds: 5),
  });

  /// Monotonic identifier so a late dismiss cannot remove a newer message.
  final int id;
  final NotificationKind kind;
  final String title;
  final String? description;

  /// How long the message stays visible before dismissing itself.
  final Duration duration;

  bool get hasDescription => description != null && description!.isNotEmpty;
}
