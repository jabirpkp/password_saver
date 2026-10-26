import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static SharedPreferences? _prefs;

  static Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get _storage {
    final storage = _prefs;
    if (storage == null) {
      throw StateError('LocalStorage.initialize() must be called first.');
    }
    return storage;
  }

  static Future<bool> setInt(String key, int value) =>
      _storage.setInt(key, value);

  static Future<bool> setString(String key, String value) =>
      _storage.setString(key, value);

  static int? getInt(String key) {
    return _storage.getInt(key);
  }

  static String? getString(String key) {
    return _storage.getString(key);
  }

  static Future<bool> setDouble(String key, double value) =>
      _storage.setDouble(key, value);

  static double? getDouble(String key) {
    return _storage.getDouble(key);
  }
}
