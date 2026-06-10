
enum Env { dev, staging, prod }

class AppConfig {
  final Env env;
  final String apiBaseUrl;
  final bool useMocks;
  final bool bypassAuth;

  const AppConfig({
    required this.env,
    required this.apiBaseUrl,
    this.useMocks = false,
    this.bypassAuth = false,
  });

  bool get isDev => env == Env.dev;
}