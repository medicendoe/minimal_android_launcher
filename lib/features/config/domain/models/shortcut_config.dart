import 'package:equatable/equatable.dart';

/// The four swipe directions used for gesture shortcuts.
enum SwipeDirection {
  up,
  down,
  left,
  right,
}

/// Maps a [SwipeDirection] to an Android package name that will be launched
/// when that gesture is performed.
class ShortcutConfig extends Equatable {
  /// The swipe direction that triggers this shortcut.
  final SwipeDirection direction;

  /// The Android package name of the app to launch.
  final String packageName;

  const ShortcutConfig({
    required this.direction,
    required this.packageName,
  });

  /// Deserialises a [ShortcutConfig] from a JSON map.
  /// Defaults to [SwipeDirection.up] when the stored direction is unrecognised.
  factory ShortcutConfig.fromJson(Map<String, dynamic> json) {
    return ShortcutConfig(
      direction: SwipeDirection.values.firstWhere(
        (e) => e.name == json['direction'],
        orElse: () => SwipeDirection.up,
      ),
      packageName: json['packageName'] as String? ?? '',
    );
  }

  /// Serialises this shortcut to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'direction': direction.name,
      'packageName': packageName,
    };
  }

  /// Returns a copy of this shortcut with the specified fields replaced.
  ShortcutConfig copyWith({
    SwipeDirection? direction,
    String? packageName,
  }) {
    return ShortcutConfig(
      direction: direction ?? this.direction,
      packageName: packageName ?? this.packageName,
    );
  }

  @override
  List<Object> get props => [direction, packageName];
}
