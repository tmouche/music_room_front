import 'package:flutter/material.dart';
import 'package:music_room/app/theme/coloring.dart';
import 'package:music_room/data/fake_db.dart';
import 'package:music_room/features/cover_palette/impl_repository.dart';

class MockCoverPaletteRepository extends CoverPaletteRepository {
  MockCoverPaletteRepository() : super();

  @override
  Future<List<Color>>  extractColors(String imageUrl) async {
    await Future.delayed(FakeDb.latency);
    return Coloring.roomCard;
  }
}
