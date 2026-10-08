import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/core/notification/controller.dart';
import 'package:music_room/core/notification/notification.dart';

final notificationProvider =
    NotifierProvider<NotificationController, AppNotification?>(
  NotificationController.new,
);
