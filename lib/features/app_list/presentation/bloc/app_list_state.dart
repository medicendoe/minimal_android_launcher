part of 'app_list_cubit.dart';

/// Immutable state for [AppListCubit].
class AppListState extends Equatable {
  /// The current list of installed apps.
  final List<AppInfo> installedApps;

  /// `true` while the first-ever fetch is in progress (no cached data yet).
  final bool isInitialLoad;

  /// `true` while a background refresh is running.
  final bool isUpdating;

  const AppListState({
    required this.installedApps,
    this.isUpdating = false,
    this.isInitialLoad = true,
  });

  /// Creates the initial empty state.
  factory AppListState.initial() {
    return const AppListState(
      installedApps: [],
      isUpdating: false,
      isInitialLoad: true,
    );
  }

  /// Returns a copy with the specified fields replaced.
  AppListState copyWith({
    List<AppInfo>? installedApps,
    bool? isUpdating,
    bool? isInitialLoad,
  }) {
    return AppListState(
      installedApps: installedApps ?? this.installedApps,
      isUpdating: isUpdating ?? this.isUpdating,
      isInitialLoad: isInitialLoad ?? this.isInitialLoad,
    );
  }

  @override
  List<Object> get props => [installedApps, isUpdating, isInitialLoad];
}
