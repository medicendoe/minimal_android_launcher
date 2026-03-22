import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../config/domain/models/app_config.dart';
import '../../../config/domain/models/window_config.dart';
import '../../../config/domain/models/shortcut_config.dart';
import '../../data/config_repository.dart';

part 'config_state.dart';

/// Manages the app-wide [AppConfig] and its persistence lifecycle.
///
/// On construction the saved config is loaded automatically. Callers update
/// individual parts of the config via the provided mutation methods and
/// explicitly call [saveConfig] to persist changes.
class ConfigCubit extends Cubit<ConfigState> {
  final ConfigRepository _repository;

  ConfigCubit(this._repository) : super(ConfigState.initial()) {
    loadConfig();
  }

  /// Loads the persisted [AppConfig] from storage and emits the result.
  ///
  /// After loading, ensures all [WindowType] values have a corresponding
  /// [WindowConfig] entry, adding empty ones for any that are missing.
  Future<void> loadConfig() async {
    emit(state.copyWith(isLoading: true));
    try {
      var config = await _repository.loadConfig();
      final existingTypes = config.windowConfigs.map((w) => w.type).toSet();
      final missingTypes =
          WindowType.values.where((t) => !existingTypes.contains(t)).toList();
      if (missingTypes.isNotEmpty) {
        config = config.copyWith(
          windowConfigs: [
            ...config.windowConfigs,
            ...missingTypes.map((t) =>
                WindowConfig(type: t, appPackageNames: [], shortcuts: [])),
          ],
        );
      }
      emit(state.copyWith(config: config, isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load configuration: $e',
      ));
    }
  }

  /// Persists the current [AppConfig] to storage.
  Future<void> saveConfig() async {
    emit(state.copyWith(isSaving: true));
    try {
      await _repository.saveConfig(state.config);
      emit(state.copyWith(isSaving: false, successMessage: 'Configuration saved'));
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        error: 'Failed to save configuration: $e',
      ));
    }
  }

  /// Replaces the app list for [windowType] with [packageNames].
  void updateWindowApps(WindowType windowType, List<String> packageNames) {
    final updatedConfigs = state.config.windowConfigs.map((config) {
      if (config.type == windowType) {
        return config.copyWith(appPackageNames: packageNames);
      }
      return config;
    }).toList();
    emit(state.copyWith(
      config: state.config.copyWith(windowConfigs: updatedConfigs),
    ));
  }

  /// Adds or updates the shortcut for [direction] inside [windowType].
  void updateWindowShortcut(
      WindowType windowType, SwipeDirection direction, String packageName) {
    final updatedConfigs = state.config.windowConfigs.map((config) {
      if (config.type == windowType) {
        final updatedShortcuts = config.shortcuts.map((s) {
          return s.direction == direction ? s.copyWith(packageName: packageName) : s;
        }).toList();

        // Add the shortcut if this direction does not exist yet.
        if (!updatedShortcuts.any((s) => s.direction == direction)) {
          updatedShortcuts
              .add(ShortcutConfig(direction: direction, packageName: packageName));
        }
        return config.copyWith(shortcuts: updatedShortcuts);
      }
      return config;
    }).toList();
    emit(state.copyWith(
      config: state.config.copyWith(windowConfigs: updatedConfigs),
    ));
  }

  /// Removes the shortcut for [direction] from [windowType].
  void removeWindowShortcut(WindowType windowType, SwipeDirection direction) {
    final updatedConfigs = state.config.windowConfigs.map((config) {
      if (config.type == windowType) {
        return config.copyWith(
          shortcuts:
              config.shortcuts.where((s) => s.direction != direction).toList(),
        );
      }
      return config;
    }).toList();
    emit(state.copyWith(
      config: state.config.copyWith(windowConfigs: updatedConfigs),
    ));
  }

  /// Sets the app launched when the clock is tapped.
  /// Pass `null` to clear the action.
  void updateClockTap(String? packageName) {
    emit(state.copyWith(
      config: state.config.copyWith(clockTapPackageName: packageName),
    ));
  }

  /// Sets the app launched when the clock is long-pressed.
  /// Pass `null` to clear the action.
  void updateClockHold(String? packageName) {
    emit(state.copyWith(
      config: state.config.copyWith(clockHoldPackageName: packageName),
    ));
  }

  /// Clears any pending error or success message from the state.
  void clearMessages() {
    emit(state.copyWith(error: null, successMessage: null));
  }
}
