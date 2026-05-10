import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:launcher/features/app_list/app_list_feature.dart';
import 'package:launcher/features/config/config_feature.dart';
import 'package:installed_apps/installed_apps.dart';

/// Thematic window reached by swiping left from the home screen.
///
/// When no apps are configured for [WindowType.left], displays the full
/// searchable app list. When apps are configured, displays only those apps.
///
/// Swipe **right** to return to the home screen (no shortcut).
/// Swipe up, down, or left to trigger the configured shortcut for that
/// direction in [WindowType.left]; swiping with no shortcut assigned also
/// returns to the home screen.
class LeftPageWidget extends StatefulWidget {
  const LeftPageWidget({super.key});

  @override
  State<LeftPageWidget> createState() => _LeftPageWidgetState();
}

class _LeftPageWidgetState extends State<LeftPageWidget> {
  String searchQuery = '';
  static const double _kEdgeFrameWidth = 30.0;
  Offset? _gestureStart;

  bool _isEdgeGesture(BuildContext context) {
    if (_gestureStart == null) return false;
    final size = MediaQuery.of(context).size;
    final p = _gestureStart!;
    return p.dx < _kEdgeFrameWidth ||
        p.dx > size.width - _kEdgeFrameWidth ||
        p.dy < _kEdgeFrameWidth ||
        p.dy > size.height - _kEdgeFrameWidth;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConfigCubit, ConfigState>(
      builder: (context, configState) {
        final windowConfig =
            configState.config.getWindowConfig(WindowType.left);
        final appList = windowConfig?.appPackageNames ?? [];
        final hasFilter = appList.isNotEmpty;

        return GestureDetector(
          onVerticalDragStart: (d) => _gestureStart = d.localPosition,
          onHorizontalDragStart: (d) => _gestureStart = d.localPosition,
          onHorizontalDragEnd: (details) {
            if (_isEdgeGesture(context)) return;
            final dx = details.velocity.pixelsPerSecond.dx;
            if (dx > 300) {
              // Swipe right — return to home screen.
              Navigator.pop(context);
            } else if (dx < -300) {
              // Swipe left — shortcut.
              final shortcut = windowConfig?.shortcuts
                  .where((s) => s.direction == SwipeDirection.left)
                  .firstOrNull;
              if (shortcut != null && shortcut.packageName.isNotEmpty) {
                InstalledApps.startApp(shortcut.packageName);
              }
              Navigator.pop(context);
            }
          },
          onVerticalDragEnd: (details) {
            if (_isEdgeGesture(context)) return;
            final dy = details.velocity.pixelsPerSecond.dy;
            if (dy > 300) {
              // Swipe down — shortcut.
              final shortcut = windowConfig?.shortcuts
                  .where((s) => s.direction == SwipeDirection.down)
                  .firstOrNull;
              if (shortcut != null && shortcut.packageName.isNotEmpty) {
                InstalledApps.startApp(shortcut.packageName);
              }
              Navigator.pop(context);
            } else if (dy < -300) {
              // Swipe up — shortcut.
              final shortcut = windowConfig?.shortcuts
                  .where((s) => s.direction == SwipeDirection.up)
                  .firstOrNull;
              if (shortcut != null && shortcut.packageName.isNotEmpty) {
                InstalledApps.startApp(shortcut.packageName);
              }
              Navigator.pop(context);
            }
          },
          child: Scaffold(
            body: hasFilter
                ? Center(
                    child: AppListWidget(filter: appList, scrollEnabled: false),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 48.0, 16.0, 8.0),
                        child: TextField(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.filter_list),
                            border: UnderlineInputBorder(),
                          ),
                          onChanged: (value) =>
                              setState(() => searchQuery = value),
                        ),
                      ),
                      Expanded(
                        child: AppListWidget(
                          searchQuery: searchQuery,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
