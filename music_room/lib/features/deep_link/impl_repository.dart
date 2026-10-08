import 'package:app_links/app_links.dart';

class DeepLinkRepository {
  DeepLinkRepository();

  Stream<Uri> get links => AppLinks().uriLinkStream;
}
