import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:window_manager/window_manager.dart';

/// Smallest window the layout is designed for. Below this, the OS refuses
/// to shrink the window instead of the UI trying to cope.
const Size kMinWindowSize = Size(400, 640);

/// Applies desktop window constraints. No-op on web and mobile.
///
/// Call it before [runApp].
Future<void> configureDesktopWindow() async {
  if (kIsWeb) return;
  if (!(Platform.isLinux || Platform.isMacOS || Platform.isWindows)) return;

  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await windowManager.setMinimumSize(kMinWindowSize);
}
