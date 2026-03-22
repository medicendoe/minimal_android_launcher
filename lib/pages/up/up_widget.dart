import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:launcher/features/app_list/app_list_feature.dart';
import 'package:launcher/features/config/config_feature.dart';
import 'package:installed_apps/installed_apps.dart';

/// Thematic window reached by swiping up from the home screen.
///
/// When no apps are configured for [WindowType.up], displays the full
/// searchable app list with pull-to-refresh. When apps are configured,
/// displays only those apps.
///
/// Horizontal drag and overscroll gestures trigger shortcuts configured
/// in [WindowType.up]; overscrolling down returns to the home screen.
class UpPageWidget extends StatefulWidget {
  const UpPageWidget({super.key});

  @override
  State<UpPageWidget> createState() => _UpPageWidgetState();
}

class _UpPageWidgetState extends State<UpPageWidget> {
  String searchQuery = '';

  void _refreshAppList() {
    context.read<AppListCubit>().refreshAppList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConfigCubit, ConfigState>(
      builder: (context, configState) {
        final config = configState.config;
        final windowConfig = config.getWindowConfig(WindowType.up);
        final appList = windowConfig?.appPackageNames ?? [];
        final hasFilter = appList.isNotEmpty;

        return GestureDetector(
          onHorizontalDragEnd: (details) {
            final dx = details.velocity.pixelsPerSecond.dx;
            if (dx > 300) {
              // Swipe right.
              final shortcut =
                  config.getShortcut(SwipeDirection.right, windowType: WindowType.up);
              if (shortcut != null && shortcut.packageName.isNotEmpty) {
                InstalledApps.startApp(shortcut.packageName);
                Navigator.pop(context);
              }
            } else if (dx < -300) {
              // Swipe left.
              final shortcut =
                  config.getShortcut(SwipeDirection.left, windowType: WindowType.up);
              if (shortcut != null && shortcut.packageName.isNotEmpty) {
                InstalledApps.startApp(shortcut.packageName);
                Navigator.pop(context);
              }
            }
          },
          child: NotificationListener<OverscrollNotification>(
            onNotification: (notification) {
              // overscroll > 0: user physically swiped UP past the bottom —
              // trigger the up shortcut if configured.
              if (notification.overscroll > 0) {
                final shortcut =
                    config.getShortcut(SwipeDirection.up, windowType: WindowType.up);
                if (shortcut != null && shortcut.packageName.isNotEmpty) {
                  InstalledApps.startApp(shortcut.packageName);
                  Navigator.pop(context);
                }
              } else if (notification.overscroll < 0) {
                // overscroll < 0: user physically swiped DOWN past the top —
                // return to home screen (reserved back gesture for this page).
                Navigator.pop(context);
              }
              return true;
            },
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => Navigator.pushNamed(context, '/config'),
                  ),
                ],
              ),
              body: hasFilter
                  ? Center(
                      child: AppListWidget(
                        filter: appList,
                        scrollEnabled: false,
                      ),
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
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
                            onRefresh: _refreshAppList,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}
