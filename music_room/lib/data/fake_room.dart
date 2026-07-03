import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/core/model/queue_item.dart';
import 'package:music_room/core/model/room.dart';
import 'package:music_room/data/fake_room_user.dart';
import 'package:music_room/data/fake_track.dart';

int nextId = 3;

QueueItem queueItem1 = QueueItem(id: '1', roomId: '1', trackId: '2', position: 1, track: fakeTrack2);
QueueItem queueItem2 = QueueItem(id: '2', roomId: '1', trackId: '3', position: 2, track: fakeTrack3);
QueueItem queueItem3 = QueueItem(id: '3', roomId: '1', trackId: '4', position: 3, track: fakeTrack4);

final fakeRoom1 = Room(
  id: '1',
  name: 'Fake Vibes 1',
  owner: fakeUser1.username,
  listeners: [
    fakeUser1,
    fakeUser2,
    fakeUser3,
    fakeUser4,
    fakeUser5,
  ],
  queue: [
    queueItem1,
    queueItem2,
    queueItem3,
  ],
  currentTrack: fakeTrack5,
  gradientColor: Coloring.cardColors[1],
);

final fakeRoom2 = Room(
  id: '2',
  name: 'Fake Vibes 2',
  owner: fakeUser2.username,
  listeners: [
    fakeUser2,
  ],
  currentTrack: fakeTrack5,
  gradientColor: Coloring.cardColors[2],
);

final fakeRoom3 = Room(
  id: '3',
  name: 'Fake Vibes 3',
  owner: fakeUser2.username,
  listeners: [
    fakeUser2,
  ],
  currentTrack: fakeTrack5,
  gradientColor: Coloring.cardColors[3],
);

final fakeRoom4 = Room(
  id: '4',
  name: 'Fake Vibes 4',
  owner: fakeUser2.username,
  listeners: [
    fakeUser2,
  ],
  currentTrack: fakeTrack5,
  gradientColor: Coloring.cardColors[4],
);

final fakeRoom5 = Room(
  id: '5',
  name: 'Fake Vibes 5',
  owner: fakeUser2.username,
  listeners: [
    fakeUser2,
  ],
  currentTrack: fakeTrack5,
  gradientColor: Coloring.cardColors[5],
);

final fakeRoom6 = Room(
  id: '6',
  name: 'Fake Vibes 6',
  owner: fakeUser2.username,
  listeners: [
    fakeUser2,
  ],
  currentTrack: fakeTrack5,
  gradientColor: Coloring.cardColors[6],
);

final fakeRoom7 = Room(
  id: '7',
  name: 'Fake Vibes 7',
  owner: fakeUser2.username,
  listeners: [
    fakeUser2,
  ],
  currentTrack: fakeTrack5,
  gradientColor: Coloring.cardColors[6],
);