
import 'package:hive/hive.dart';

class LocalStorage {


  static final _prefs = Hive.box("app_storage");


  static Future<void> setInt(String key, int value) async {
    await _prefs.put(key, value);
  }

  static Future<void> setString(String key, String value) async {
    await _prefs.put(key, value);
  }

  static int? getInt(String key) {
    return _prefs.get(key);
  }
  static String? getString(String key) {
    return _prefs.get(key);
  }

  static Future<void> setDouble(String key, double value) async {
    await _prefs.put(key, value);
  }

  static double? getDouble(String key) {
    return _prefs.get(key);
  }
}