import 'package:equatable/equatable.dart';
import 'shortcut_config.dart';

/// Identifies the thematic window a [WindowConfig] belongs to,
/// named after the swipe direction used to reach it from the home screen.
enum WindowType {
  /// Apps reached by swiping up from the home screen.
  /// Reserved back gesture: swipe down to return home.
  up,

  /// Apps reached by swiping down from the home screen.
  down,

  /// Apps reached by swiping right from the home screen.
  right,

  /// Apps reached by swiping left from the home screen.
  left,
}

/// Configuration for a single thematic window.
///
/// Holds the ordered list of app package names to display and the swipe
/// shortcuts available inside the window.
class WindowConfig extends Equatable {
  /// The window this config belongs to.
  final WindowType type;

  /// Ordered list of Android package names shown in this window.
  final List<String> appPackageNames;

  /// Swipe-direction shortcuts available inside this window.
  final List<ShortcutConfig> shortcuts;

  const WindowConfig({
    required this.type,
    required this.appPackageNames,
    required this.shortcuts,
  });

  /// Deserialises a [WindowConfig] from a JSON map.
  /// Defaults to [WindowType.chat] when the stored type string is unrecognised.
  factory WindowConfig.fromJson(Map<String, dynamic> json) {
    return WindowConfig(
      type: WindowType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => WindowType.down,
      ),
      appPackageNames: List<String>.from(json['appPackageNames'] ?? []),
      shortcuts: (json['shortcuts'] as List<dynamic>?)
              ?.map((e) => ShortcutConfig.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Serialises this config to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'appPackageNames': appPackageNames,
      'shortcuts': shortcuts.map((e) => e.toJson()).toList(),
    };
  }

  /// Returns a copy of this config with the specified fields replaced.
  WindowConfig copyWith({
    WindowType? type,
    List<String>? appPackageNames,
    List<ShortcutConfig>? shortcuts,
  }) {
    return WindowConfig(
      type: type ?? this.type,
      appPackageNames: appPackageNames ?? this.appPackageNames,
      shortcuts: shortcuts ?? this.shortcuts,
    );
  }

  @override
  List<Object> get props => [type, appPackageNames, shortcuts];
}
