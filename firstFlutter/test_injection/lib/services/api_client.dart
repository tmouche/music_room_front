import 'package:injectable/injectable.dart';

abstract class ApiClient {
  void fetchData();
}


@Injectable(as: ApiClient, env: ['dev'])
class DevClient implements ApiClient {
  void fetchData() {
    print("Im the dev client...");
  }
}

@Injectable(as: ApiClient, env: ['staging', 'prod'])
class RealClient implements ApiClient {
  void fetchData() {
    print("Im the realClient...");
  }
}

