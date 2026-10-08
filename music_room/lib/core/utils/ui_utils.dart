import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/core/notification/controller.dart';
import 'package:music_room/core/notification/provider.dart';

class UiUtils {
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    if (!context.mounted) return;
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: isError
                ? colorScheme.onErrorContainer
                : colorScheme.onSecondaryContainer,
          ),
        ),
        backgroundColor: isError
            ? colorScheme.errorContainer
            : colorScheme.secondaryContainer,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    showSnackBar(context, message, isError: true);
  }

  static void showSuccess(BuildContext context, String message) {
    showSnackBar(context, message, isError: false);
  }



  /// Facades over [notificationProvider]. The [context] is only used to
  /// reach the provider container; call sites that already hold a `ref`
  /// should use `ref.read(notificationProvider.notifier)` directly.
  static NotificationController _notifier(BuildContext context) =>
      ProviderScope.containerOf(context, listen: false)
          .read(notificationProvider.notifier);

  static void showErrorBanner(
    BuildContext context,
    String title,
    {String? description,}
  )  {
    _notifier(context).error(title, description: description);
  }

  static void showHintBanner(
    BuildContext context,
    String title,
    {String? description,}
  )  {
    _notifier(context).hint(title, description: description);
  }

  static void showSuccessBanner(
    BuildContext context,
    String title,
    {String? description,}
  )  {
    _notifier(context).success(title, description: description);
  }
}
