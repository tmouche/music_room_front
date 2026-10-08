import 'package:music_room/features/deep_link/impl_repository.dart';

class MockDeepLinkRepository extends DeepLinkRepository {
  MockDeepLinkRepository() : super();

  @override
  Stream<Uri> get links => const Stream.empty();
}
