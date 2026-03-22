import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:installed_apps/index.dart';
import '../bloc/app_list_cubit.dart';

/// Displays a filtered, scrollable list of installed apps.
///
/// Supports:
/// - Filtering by a list of package names ([filter])
/// - Searching by app name ([searchQuery])
/// - Pull-to-refresh via an optional [onRefresh] callback
/// - Disabling scroll so the list can be embedded inside a parent scroller
/// - Long-pressing an app to open its Android settings page
class AppListWidget extends StatelessWidget {
  /// When non-null, only apps whose package name is in this list are shown.
  final List<String>? filter;

  /// When `false`, the list uses [NeverScrollableScrollPhysics].
  final bool scrollEnabled;

  /// Filters the visible apps to those whose name contains this string
  /// (case-insensitive).
  final String searchQuery;

  /// Called when the user pulls to refresh. If `null` the pull-to-refresh
  /// wrapper is omitted.
  final VoidCallback? onRefresh;

  const AppListWidget({
    super.key,
    this.filter,
    this.scrollEnabled = true,
    this.searchQuery = '',
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppListCubit, AppListState>(
      builder: (context, state) {
        var filteredApps = state.installedApps;

        // Apply package-name filter.
        if (filter != null && filter!.isNotEmpty) {
          filteredApps = filteredApps
              .where((app) => filter!.contains(app.packageName))
              .toList();
        }

        // Apply text search filter.
        if (searchQuery.isNotEmpty) {
          filteredApps = filteredApps
              .where((app) =>
                  app.name.toLowerCase().contains(searchQuery.toLowerCase()))
              .toList();
        }

        // Show a loading indicator on first launch before any apps are cached.
        if (state.isInitialLoad && state.installedApps.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading apps…'),
              ],
            ),
          );
        }

        // Empty state after filtering.
        if (filteredApps.isEmpty) {
          return Center(
            child: Text(
              state.installedApps.isEmpty
                  ? 'No apps available'
                  : searchQuery.isNotEmpty
                      ? 'No apps match "$searchQuery"'
                      : 'No apps available with the current filter',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        return _buildListView(context, filteredApps, state);
      },
    );
  }

  Widget _buildListView(
      BuildContext context, List<AppInfo> filteredApps, AppListState state) {
    Widget listView = NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is OverscrollNotification) {
          return false; // Let overscroll propagate to the parent.
        }
        return true;
      },
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (notification) {
          notification.disallowIndicator();
          return true;
        },
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: filteredApps.length,
          physics: scrollEnabled
              ? const ClampingScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final app = filteredApps[index];
            return ListTile(
              title: Text(app.name,
                  style: Theme.of(context).textTheme.bodyLarge),
              onTap: () {
                InstalledApps.startApp(app.packageName);
                Navigator.pop(context);
              },
              onLongPress: () => InstalledApps.openSettings(app.packageName),
            );
          },
        ),
      ),
    );

    // Wrap in RefreshIndicator when a refresh callback is provided.
    if (onRefresh != null && scrollEnabled) {
      return RefreshIndicator(
        onRefresh: () async {
          onRefresh!();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: listView,
      );
    }

    return listView;
  }
}
