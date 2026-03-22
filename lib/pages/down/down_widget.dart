import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:launcher/features/app_list/app_list_feature.dart';
import 'package:launcher/features/config/config_feature.dart';
import 'package:installed_apps/installed_apps.dart';

/// Thematic window reached by swiping down from the home screen.
///
/// When no apps are configured for [WindowType.down], displays the full
/// searchable app list. When apps are configured, displays only those apps.
///
/// Swipe **up** to return to the home screen (no shortcut).
/// Swipe down, left, or right to trigger the configured shortcut for that
/// direction in [WindowType.down]; swiping with no shortcut assigned also
/// returns to the home screen.
class DownPageWidget extends StatefulWidget {
  const DownPageWidget({super.key});

  @override
  State<DownPageWidget> createState() => _DownPageWidgetState();
}

class _DownPageWidgetState extends State<DownPageWidget> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConfigCubit, ConfigState>(
      builder: (context, configState) {
        final windowConfig =
            configState.config.getWindowConfig(WindowType.down);
        final appList = windowConfig?.appPackageNames ?? [];
        final hasFilter = appList.isNotEmpty;

        return GestureDetector(
          onVerticalDragEnd: (details) {
            final dy = details.velocity.pixelsPerSecond.dy;
            if (dy < -300) {
              // Swipe up — return to home screen.
              Navigator.pop(context);
            } else if (dy > 300) {
              // Swipe down — shortcut.
              final shortcut = windowConfig?.shortcuts
                  .where((s) => s.direction == SwipeDirection.down)
                  .firstOrNull;
              if (shortcut != null && shortcut.packageName.isNotEmpty) {
                InstalledApps.startApp(shortcut.packageName);
              }
              Navigator.pop(context);
            }
          },
          onHorizontalDragEnd: (details) {
            final dx = details.velocity.pixelsPerSecond.dx;
            if (dx > 300) {
              // Swipe right — shortcut.
              final shortcut = windowConfig?.shortcuts
                  .where((s) => s.direction == SwipeDirection.right)
                  .firstOrNull;
              if (shortcut != null && shortcut.packageName.isNotEmpty) {
                InstalledApps.startApp(shortcut.packageName);
              }
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
