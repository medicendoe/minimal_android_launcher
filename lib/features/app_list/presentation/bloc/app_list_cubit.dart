import 'dart:async';
import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_list_state.dart';

/// Fetches, caches, and periodically refreshes the list of installed apps.
///
/// A static in-memory cache is shared across all [AppListCubit] instances.
/// On creation the cached list (if available) is emitted immediately so the
/// UI is populated without delay. A background refresh is then triggered if
/// the cache is older than [_cacheValidDuration]. Subsequent background
/// refreshes replace the list silently, without any loading indicator.
///
/// Additionally, the app list is persisted to disk via [SharedPreferences] so
/// that it survives process restarts (e.g. Android low-memory eviction).
/// The loading spinner is therefore shown only on the absolute first launch.
class AppListCubit extends Cubit<AppListState> {
  Timer? _timer;

  // Static cache shared across instances so the list survives cubit recreation.
  static List<AppInfo>? _cachedApps;
  static DateTime? _lastUpdate;
  static const Duration _cacheValidDuration = Duration(minutes: 30);
  static const String _prefKey = 'app_list_cache_v1';

  bool _isCurrentlyUpdating = false;

  AppListCubit() : super(AppListState.initial()) {
    _initializeAndLoadApps();
    _startPeriodicUpdate();
  }

  Future<void> _initializeAndLoadApps() async {
    if (_cachedApps != null && _cachedApps!.isNotEmpty) {
      // Serve the in-memory cache immediately.
      emit(state.copyWith(
        installedApps: _cachedApps!,
        isInitialLoad: false,
        isUpdating: false,
      ));
      // Refresh in the background if the cache has expired.
      if (!_isCacheValid()) {
        await _updateAppListInBackground();
      }
    } else {
      // Try the disk cache to avoid showing the loading spinner after a
      // process restart (e.g. Android low-memory eviction).
      final diskApps = await _loadFromDisk();
      if (diskApps.isNotEmpty) {
        _cachedApps = diskApps;
        emit(state.copyWith(
          installedApps: diskApps,
          isInitialLoad: false,
          isUpdating: false,
        ));
        // Always refresh from the system after a cold start.
        await _updateAppListInBackground();
      } else {
        // Genuine first-ever launch: show the loading indicator.
        emit(state.copyWith(isUpdating: true, isInitialLoad: true));
        await _updateAppListInBackground();
      }
    }
  }

  bool _isCacheValid() {
    if (_lastUpdate == null) return false;
    return DateTime.now().difference(_lastUpdate!) < _cacheValidDuration;
  }

  Future<void> _updateAppListInBackground() async {
    if (_isCurrentlyUpdating) return;

    _isCurrentlyUpdating = true;
    try {
      final apps = await InstalledApps.getInstalledApps(false, true);
      _cachedApps = apps;
      _lastUpdate = DateTime.now();
      emit(state.copyWith(
        installedApps: apps,
        isUpdating: false,
        isInitialLoad: false,
      ));
      _saveToDisk(apps);
    } catch (_) {
      // On error, keep the existing list and clear the loading flag.
      emit(state.copyWith(isUpdating: false, isInitialLoad: false));
    } finally {
      _isCurrentlyUpdating = false;
    }
  }

  /// Loads the persisted app list from [SharedPreferences].
  ///
  /// Returns an empty list if no data is found or deserialisation fails.
  /// Only [AppInfo.name] and [AppInfo.packageName] are persisted; all other
  /// fields are set to harmless defaults since the UI does not use them.
  Future<List<AppInfo>> _loadFromDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map((e) => AppInfo(
                name: e['name'] as String,
                packageName: e['packageName'] as String,
                icon: null,
                versionName: '1.0.0',
                versionCode: 1,
                builtWith: BuiltWith.native_or_others,
                installedTimestamp: 0,
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Persists [apps] to [SharedPreferences] (fire-and-forget).
  ///
  /// Only [AppInfo.name] and [AppInfo.packageName] are stored.
  void _saveToDisk(List<AppInfo> apps) {
    SharedPreferences.getInstance().then((prefs) {
      final data = apps
          .map((a) => {'name': a.name, 'packageName': a.packageName})
          .toList();
      prefs.setString(_prefKey, jsonEncode(data));
    });
  }

  /// Triggers an immediate background refresh of the app list.
  Future<void> refreshAppList() async {
    await _updateAppListInBackground();
  }

  void _startPeriodicUpdate() {
    _timer = Timer.periodic(
      const Duration(minutes: 30),
      (_) => _updateAppListInBackground(),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
