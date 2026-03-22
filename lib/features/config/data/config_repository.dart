import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/app_config.dart';

/// Persists and retrieves [AppConfig] using [SharedPreferences].
///
/// The config is stored as a JSON string under a single key. On load failures
/// or missing data an empty [AppConfig.initial] is returned so the app always
/// has a valid configuration to work with.
class ConfigRepository {
  static const String _configKey = 'app_config';

  /// Loads the saved [AppConfig] from storage.
  ///
  /// Returns [AppConfig.initial] when no config has been saved yet or if
  /// deserialisation fails.
  Future<AppConfig> loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString(_configKey);
      if (configJson != null) {
        final configMap = jsonDecode(configJson) as Map<String, dynamic>;
        return AppConfig.fromJson(configMap);
      }
    } catch (e) {
      debugPrint('ConfigRepository: failed to load config — $e');
    }
    return AppConfig.initial();
  }

  /// Persists [config] to storage.
  ///
  /// Returns `true` on success, `false` on failure.
  Future<bool> saveConfig(AppConfig config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_configKey, jsonEncode(config.toJson()));
    } catch (e) {
      debugPrint('ConfigRepository: failed to save config — $e');
      return false;
    }
  }

  /// Removes the saved config from storage.
  ///
  /// Returns `true` on success, `false` on failure.
  Future<bool> clearConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_configKey);
    } catch (e) {
      debugPrint('ConfigRepository: failed to clear config — $e');
      return false;
    }
  }
}
