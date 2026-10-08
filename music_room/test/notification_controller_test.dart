import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_room/core/notification/controller.dart';
import 'package:music_room/core/notification/notification.dart';
import 'package:music_room/core/notification/provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  NotificationController notifier() =>
      container.read(notificationProvider.notifier);

  test('starts empty', () {
    expect(container.read(notificationProvider), isNull);
  });

  test('error/hint/success set the kind and title', () {
    notifier().error('Boom', description: 'details');
    var n = container.read(notificationProvider)!;
    expect(n.kind, NotificationKind.error);
    expect(n.title, 'Boom');
    expect(n.description, 'details');
    expect(n.hasDescription, isTrue);

    notifier().hint('Tip');
    n = container.read(notificationProvider)!;
    expect(n.kind, NotificationKind.hint);
    expect(n.hasDescription, isFalse);

    notifier().success('Done');
    expect(container.read(notificationProvider)!.kind, NotificationKind.success);
  });

  test('each show gets a new id', () {
    notifier().hint('a');
    final first = container.read(notificationProvider)!.id;
    notifier().hint('b');
    expect(container.read(notificationProvider)!.id, isNot(first));
  });

  test('dismiss only clears the matching id', () {
    notifier().hint('old');
    final oldId = container.read(notificationProvider)!.id;
    notifier().hint('new');

    notifier().dismiss(oldId);
    expect(container.read(notificationProvider)?.title, 'new');

    notifier().dismiss(container.read(notificationProvider)!.id);
    expect(container.read(notificationProvider), isNull);
  });

  test('clear removes whatever is shown', () {
    notifier().error('x');
    notifier().clear();
    expect(container.read(notificationProvider), isNull);
  });
}
