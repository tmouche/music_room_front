import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_room/core/notification/notification.dart';
import 'package:music_room/core/notification/provider.dart';
import 'package:music_room/core/utils/busy_notifier.dart';
import 'package:music_room/core/utils/exception.dart';

final _busyProvider =
    NotifierProvider.autoDispose<BusyNotifier, bool>(BusyNotifier.new);

void main() {
  _disposedDuringRun();

  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  BusyNotifier busy() => container.read(_busyProvider.notifier);
  AppNotification? notification() => container.read(notificationProvider);

  test('is busy while the action runs and idle afterwards', () async {
    final sub = container.listen(_busyProvider, (_, _) {});
    final gate = Completer<void>();

    final result = busy().run(() => gate.future);
    expect(container.read(_busyProvider), isTrue);

    gate.complete();
    expect(await result, isTrue);
    expect(container.read(_busyProvider), isFalse);
    expect(notification(), isNull);
    sub.close();
  });

  test('rejects a second call while one is in flight', () async {
    final sub = container.listen(_busyProvider, (_, _) {});
    final gate = Completer<void>();
    var secondRan = false;

    final first = busy().run(() => gate.future);
    final second = await busy().run(() async => secondRan = true);

    expect(second, isFalse);
    expect(secondRan, isFalse);

    gate.complete();
    expect(await first, isTrue);
    sub.close();
  });

  test('ApiException becomes a notification with the server message', () async {
    final sub = container.listen(_busyProvider, (_, _) {});
    final ok = await busy().run(
      () async => throw ApiException('Wrong password'),
      apiErrorKind: NotificationKind.hint,
    );

    expect(ok, isFalse);
    expect(container.read(_busyProvider), isFalse);
    expect(notification()?.kind, NotificationKind.hint);
    expect(notification()?.title, 'Wrong password');
    sub.close();
  });

  test('ServerException and unknown errors become an error notification', () async {
    final sub = container.listen(_busyProvider, (_, _) {});

    expect(await busy().run(() async => throw ServerException(), label: 'Log in'), isFalse);
    expect(notification()?.kind, NotificationKind.error);
    expect(notification()?.description, contains('Log in'));

    expect(await busy().run(() async => throw StateError('boom')), isFalse);
    expect(notification()?.kind, NotificationKind.error);
    expect(container.read(_busyProvider), isFalse);
    sub.close();
  });
}

void _disposedDuringRun() {
  test('survives the provider being disposed while the action runs', () async {
    final container = ProviderContainer();
    final sub = container.listen(_busyProvider, (_, _) {});
    final gate = Completer<void>();

    final result = container.read(_busyProvider.notifier).run(() => gate.future);

    // Last listener leaves: autoDispose tears the notifier down.
    sub.close();
    await Future<void>.delayed(Duration.zero);

    gate.complete();
    await expectLater(result, completion(isTrue));
    container.dispose();
  });
}
