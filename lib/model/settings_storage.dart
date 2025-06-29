import 'package:hive_ce/hive.dart';

class SettingsStorage {
  static late final Box box;

  static const String keyServerUrl = 'serverUrl';

  static Future<void> init() async {
    box = await Hive.openBox('settings');
  }

  static String? getServerUrl() {
    return box.get(keyServerUrl);
  }

  static Future<void> setServerUrl(String url) async {
    await box.put(keyServerUrl, url);
  }
}
