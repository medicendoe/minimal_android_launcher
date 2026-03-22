import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:launcher/features/app_list/app_list_feature.dart';
import 'package:launcher/features/config/config_feature.dart';
import 'package:installed_apps/installed_apps.dart';

/// Full app drawer with search, swipe shortcuts, and pull-to-refresh.
class AppPageWidget extends StatefulWidget {
  const AppPageWidget({super.key});

  @override
  State<AppPageWidget> createState() => _AppPageWidgetState();
}

class _AppPageWidgetState extends State<AppPageWidget> {
  String searchQuery = '';

  void _refreshAppList() {
    context.read<AppListCubit>().refreshAppList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConfigCubit, ConfigState>(
      builder: (context, configState) {
        return GestureDetector(
          onHorizontalDragEnd: (details) {
            final config = configState.config;
            final dx = details.velocity.pixelsPerSecond.dx;
            if (dx > 300) {
              // Swipe right.
              final shortcut = config.getShortcut(SwipeDirection.right, windowType: WindowType.up);
              if (shortcut != null && shortcut.packageName.isNotEmpty) {
                InstalledApps.startApp(shortcut.packageName);
                Navigator.pop(context);
              }
            } else if (dx < -300) {
              // Swipe left.
              final shortcut = config.getShortcut(SwipeDirection.left, windowType: WindowType.up);
              if (shortcut != null && shortcut.packageName.isNotEmpty) {
                InstalledApps.startApp(shortcut.packageName);
                Navigator.pop(context);
              }
            }
          },
          child: NotificationListener<OverscrollNotification>(
            onNotification: (notification) {
              final config = configState.config;
              if (notification.overscroll > 0) {
                // Overscroll down.
                final shortcut = config.getShortcut(SwipeDirection.down, windowType: WindowType.up);
                if (shortcut != null && shortcut.packageName.isNotEmpty) {
                  InstalledApps.startApp(shortcut.packageName);
                  Navigator.pop(context);
                }
              } else if (notification.overscroll < 0) {
                // Overscroll up.
                final shortcut = config.getShortcut(SwipeDirection.up, windowType: WindowType.up);
                if (shortcut != null && shortcut.packageName.isNotEmpty) {
                  InstalledApps.startApp(shortcut.packageName);
                  Navigator.pop(context);
                } else {
                  Navigator.pop(context);
                }
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
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                    child: TextField(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.filter_list),
                        border: UnderlineInputBorder(),
                      ),
                      onChanged: (value) => setState(() => searchQuery = value),
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
