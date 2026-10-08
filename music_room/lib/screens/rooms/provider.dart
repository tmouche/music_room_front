
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_room/core/utils/busy_notifier.dart';

final roomsBusyProvider = NotifierProvider.autoDispose<BusyNotifier, bool>(BusyNotifier.new);
