import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_room/data/fake_room.dart';
import 'package:music_room/screens/room/room.dart';

void main() {
  testWidgets('ouvrir puis fermer la modale ne provoque pas d\'overflow',
      (tester) async {
    await tester.pumpWidget(MaterialApp(home: RoomPage(room: fakeRoom1)));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.list).first);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.list).first);
    await tester.pumpAndSettle();
  });
}
