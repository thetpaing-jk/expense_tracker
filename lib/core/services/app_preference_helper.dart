import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesUtils{
  static SharedPreferences? _pref;
  static Future<void> intiSharePreference() async{
    _pref = await SharedPreferences.getInstance();
  }
  
  static String? getString(String key, [String? defValue]) {
    return _pref?.getString(key) ?? defValue;
  }

  static Future<void> setString(String key, String value) async {
    await _pref?.setString(key, value);
  }

  static Future<void> setBool(String key, bool value) async =>
    await _pref?.setBool(key, value);

  static bool getBool(String key, [bool defValue = false]) =>
      _pref?.getBool(key) ?? defValue;

  static int? getInt(String key, [int? defValue]) {
    return _pref?.getInt(key) ?? defValue;
  }
  static Future<void> setInt(String key, int value) async {
    await _pref?.setInt(key, value);
  }

  static Future<void> remove(String key) async{
    await _pref?.remove(key);
  }

  static Future<void> clear() async{
    await _pref?.clear();
  }
}