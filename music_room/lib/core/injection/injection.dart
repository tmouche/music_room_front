
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:music_room/core/config/app_config.dart';
import 'injection.config.dart'; 

final GetIt getIt = GetIt.instance;

@injectableInit
void configureDependencies(AppConfig config) => getIt.init(environment: config.env.name);
