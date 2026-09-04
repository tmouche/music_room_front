
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BusyNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  Future<bool>  run(Future<void> Function() action) async {
    if (state) return false;
    state = true;
    try {
      await action();
      return true;
    } finally {
      state = false;
    }
  }
}
