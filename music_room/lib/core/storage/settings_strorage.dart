import 'package:shared_preferences/shared_preferences.dart';

class SettingsStrorage {
  static const volumeKey = 'volume';

  static Future<double?> getVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(volumeKey);
  }

  static Future<void> saveVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(volumeKey, volume);
  }
}