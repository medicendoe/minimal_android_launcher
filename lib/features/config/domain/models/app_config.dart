import 'package:equatable/equatable.dart';
import 'window_config.dart';
import 'shortcut_config.dart';

// Sentinel used so that copyWith can distinguish "pass null explicitly" from
// "leave the current value unchanged" for nullable String fields.
const _sentinel = Object();

/// Root configuration model for the launcher.
///
/// Holds the per-window app lists and shortcuts, and the configurable
/// tap/hold actions for the home screen central widget.
/// All data is JSON-serialisable for persistence via [ConfigRepository].
class AppConfig extends Equatable {
  /// Per-window configurations (up, down, right, left).
  final List<WindowConfig> windowConfigs;

  /// Package name of the app launched when the home screen is tapped.
  /// `null` means no action is assigned.
  final String? clockTapPackageName;

  /// Package name of the app launched when the home screen is long-pressed.
  /// `null` means no action is assigned.
  final String? clockHoldPackageName;

  const AppConfig({
    required this.windowConfigs,
    this.clockTapPackageName,
    this.clockHoldPackageName,
  });

  /// Returns an empty configuration with no apps, shortcuts, or actions
  /// assigned. Used as the starting point for a first-run setup.
  factory AppConfig.initial() {
    return const AppConfig(
      windowConfigs: [
        WindowConfig(type: WindowType.up, appPackageNames: [], shortcuts: []),
        WindowConfig(type: WindowType.down, appPackageNames: [], shortcuts: []),
        WindowConfig(type: WindowType.right, appPackageNames: [], shortcuts: []),
        WindowConfig(type: WindowType.left, appPackageNames: [], shortcuts: []),
      ],
    );
  }

  /// Deserialises an [AppConfig] from a JSON map.
  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      windowConfigs: (json['windowConfigs'] as List<dynamic>?)
              ?.map((e) => WindowConfig.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      clockTapPackageName: json['clockTapPackageName'] as String?,
      clockHoldPackageName: json['clockHoldPackageName'] as String?,
    );
  }

  /// Serialises this config to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'windowConfigs': windowConfigs.map((e) => e.toJson()).toList(),
      'clockTapPackageName': clockTapPackageName,
      'clockHoldPackageName': clockHoldPackageName,
    };
  }

  /// Returns the [WindowConfig] for the given [type], or `null` if none has
  /// been configured yet.
  WindowConfig? getWindowConfig(WindowType type) {
    try {
      return windowConfigs.firstWhere((config) => config.type == type);
    } catch (_) {
      return null;
    }
  }

  /// Returns the [ShortcutConfig] for [direction] within [windowType]'s
  /// shortcuts. Returns `null` if no matching shortcut exists.
  ShortcutConfig? getShortcut(SwipeDirection direction, {required WindowType windowType}) {
    final shortcuts = getWindowConfig(windowType)?.shortcuts ?? [];
    try {
      return shortcuts.firstWhere((s) => s.direction == direction);
    } catch (_) {
      return null;
    }
  }

  /// Returns a copy of this config with the specified fields replaced.
  ///
  /// Nullable String fields ([clockTapPackageName], [clockHoldPackageName])
  /// support explicit `null` assignment via a sentinel default; omitting the
  /// argument preserves the current value.
  AppConfig copyWith({
    List<WindowConfig>? windowConfigs,
    Object? clockTapPackageName = _sentinel,
    Object? clockHoldPackageName = _sentinel,
  }) {
    return AppConfig(
      windowConfigs: windowConfigs ?? this.windowConfigs,
      clockTapPackageName: clockTapPackageName == _sentinel
          ? this.clockTapPackageName
          : clockTapPackageName as String?,
      clockHoldPackageName: clockHoldPackageName == _sentinel
          ? this.clockHoldPackageName
          : clockHoldPackageName as String?,
    );
  }

  @override
  List<Object?> get props => [
        windowConfigs,
        clockTapPackageName,
        clockHoldPackageName,
      ];
}
