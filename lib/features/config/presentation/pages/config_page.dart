import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/app_config.dart';
import '../../domain/models/window_config.dart';
import '../../domain/models/shortcut_config.dart';
import '../bloc/config_cubit.dart';
import '../../../app_list/app_list_feature.dart';

/// Full-screen configuration page for the launcher.
///
/// Organises settings into collapsible cards:
/// - **Home Screen** — tap and long-press app actions for the central widget
/// - **App Page** — swipe shortcuts for the app-list screen
/// - **Windows** — per-window app lists and swipe shortcuts
///
/// Changes are staged in memory and persisted only when the user taps the
/// save icon in the app bar.
class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          BlocBuilder<ConfigCubit, ConfigState>(
            builder: (context, state) {
              return IconButton(
                icon: state.isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                onPressed: state.isSaving
                    ? null
                    : () => context.read<ConfigCubit>().saveConfig(),
              );
            },
          ),
        ],
      ),
      body: BlocListener<ConfigCubit, ConfigState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
              ),
            );
            context.read<ConfigCubit>().clearMessages();
          }
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Colors.green,
              ),
            );
            context.read<ConfigCubit>().clearMessages();
          }
        },
        child: BlocBuilder<ConfigCubit, ConfigState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildClockSection(context, state.config),
                  const SizedBox(height: 24),
                  ...state.config.windowConfigs.map(
                    (windowConfig) => Column(
                      children: [
                        _buildWindowSection(context, windowConfig),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section builders
  // ---------------------------------------------------------------------------

  Widget _buildClockSection(BuildContext context, AppConfig config) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Home Screen', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildActionTile(
              context,
              icon: Icons.touch_app,
              label: 'Tap',
              packageName: config.clockTapPackageName,
              onEdit: (pkg) => context.read<ConfigCubit>().updateClockTap(pkg),
              onClear: () => context.read<ConfigCubit>().updateClockTap(null),
            ),
            _buildActionTile(
              context,
              icon: Icons.pan_tool,
              label: 'Hold',
              packageName: config.clockHoldPackageName,
              onEdit: (pkg) => context.read<ConfigCubit>().updateClockHold(pkg),
              onClear: () => context.read<ConfigCubit>().updateClockHold(null),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWindowSection(BuildContext context, WindowConfig windowConfig) {
    final reserved = _reservedDirection(windowConfig.type);
    final configurableShortcuts = windowConfig.shortcuts
        .where((s) => s.direction != reserved)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_windowArrow(windowConfig.type)}  Window ${windowConfig.type.name.toUpperCase()}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text('Apps:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () =>
                  _showSelectAppsDialog(context, windowConfig),
              icon: const Icon(Icons.apps),
              label: Text(
                  'Configure apps (${windowConfig.appPackageNames.length})'),
            ),
            const SizedBox(height: 16),
            Text('Swipe shortcuts:',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...configurableShortcuts.map(
              (shortcut) => _buildShortcutTile(
                context,
                shortcut,
                onChanged: (pkg) => context
                    .read<ConfigCubit>()
                    .updateWindowShortcut(
                        windowConfig.type, shortcut.direction, pkg),
                onRemove: () => context
                    .read<ConfigCubit>()
                    .removeWindowShortcut(windowConfig.type, shortcut.direction),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () =>
                  _showAddShortcutDialog(context, windowConfig.type),
              icon: const Icon(Icons.add),
              label: const Text('Add shortcut'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Reusable tile widgets
  // ---------------------------------------------------------------------------

  /// A [ListTile] for a single tap/hold action with edit and optional clear buttons.
  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String? packageName,
    required Function(String) onEdit,
    required VoidCallback onClear,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(packageName ?? 'No app assigned'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showSelectAppDialog(context, onEdit),
          ),
          if (packageName != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onClear,
            ),
        ],
      ),
    );
  }

  /// A [Card]-wrapped [ListTile] showing a single [ShortcutConfig].
  Widget _buildShortcutTile(
    BuildContext context,
    ShortcutConfig shortcut, {
    required Function(String) onChanged,
    required VoidCallback onRemove,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Text(
          _directionArrow(shortcut.direction),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        title: Text(_directionLabel(shortcut.direction)),
        subtitle: Text(shortcut.packageName.isEmpty
            ? 'No app assigned'
            : shortcut.packageName),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showSelectAppDialog(context, onChanged),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Returns the [SwipeDirection] that is reserved for returning to the home
  /// screen in [windowType], or `null` for the app-list page.
  SwipeDirection? _reservedDirection(WindowType? windowType) {
    switch (windowType) {
      case WindowType.up:
        return SwipeDirection.down;
      case WindowType.down:
        return SwipeDirection.up;
      case WindowType.right:
        return SwipeDirection.left;
      case WindowType.left:
        return SwipeDirection.right;
      case null:
        return null;
    }
  }

  String _windowArrow(WindowType type) {
    switch (type) {
      case WindowType.up:
        return '↑';
      case WindowType.down:
        return '↓';
      case WindowType.left:
        return '←';
      case WindowType.right:
        return '→';
    }
  }

  String _directionArrow(SwipeDirection direction) {
    switch (direction) {
      case SwipeDirection.up:
        return '↑';
      case SwipeDirection.down:
        return '↓';
      case SwipeDirection.left:
        return '←';
      case SwipeDirection.right:
        return '→';
    }
  }

  String _directionLabel(SwipeDirection direction) {
    switch (direction) {
      case SwipeDirection.up:
        return '↑  Swipe up';
      case SwipeDirection.down:
        return '↓  Swipe down';
      case SwipeDirection.left:
        return '←  Swipe left';
      case SwipeDirection.right:
        return '→  Swipe right';
    }
  }

  // ---------------------------------------------------------------------------
  // Dialogs
  // ---------------------------------------------------------------------------

  void _showSelectAppsDialog(
      BuildContext context, WindowConfig windowConfig) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: context.read<ConfigCubit>(),
          child: _SelectAppsDialog(windowConfig: windowConfig),
        );
      },
    );
  }

  void _showSelectAppDialog(
      BuildContext context, Function(String) onSelected) {
    showDialog(
      context: context,
      builder: (_) => _SelectAppDialog(onSelected: onSelected),
    );
  }

  void _showAddShortcutDialog(BuildContext context, WindowType? windowType) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: context.read<ConfigCubit>(),
          child: _AddShortcutDialog(windowType: windowType),
        );
      },
    );
  }
}

// =============================================================================
// Private dialog widgets
// =============================================================================

/// Multi-select dialog for choosing which installed apps appear in a window.
class _SelectAppsDialog extends StatefulWidget {
  final WindowConfig windowConfig;

  const _SelectAppsDialog({required this.windowConfig});

  @override
  State<_SelectAppsDialog> createState() => _SelectAppsDialogState();
}

class _SelectAppsDialogState extends State<_SelectAppsDialog> {
  late Set<String> selectedApps;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    selectedApps = Set.from(widget.windowConfig.appPackageNames);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            AppBar(
              title: Text(
                  'Select apps for ${widget.windowConfig.type.name}'),
              automaticallyImplyLeading: false,
              actions: [
                TextButton(
                  onPressed: () {
                    context.read<ConfigCubit>().updateWindowApps(
                          widget.windowConfig.type,
                          selectedApps.toList(),
                        );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search apps…',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) =>
                    setState(() => searchQuery = value.toLowerCase()),
              ),
            ),
            Expanded(
              child: BlocBuilder<AppListCubit, AppListState>(
                builder: (context, state) {
                  var apps = state.installedApps;
                  if (searchQuery.isNotEmpty) {
                    apps = apps
                        .where((a) =>
                            a.name.toLowerCase().contains(searchQuery) ||
                            a.packageName.toLowerCase().contains(searchQuery))
                        .toList();
                  }
                  return ListView.builder(
                    itemCount: apps.length,
                    itemBuilder: (context, index) {
                      final app = apps[index];
                      return CheckboxListTile(
                        title: Text(app.name),
                        subtitle: Text(app.packageName),
                        value: selectedApps.contains(app.packageName),
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              selectedApps.add(app.packageName);
                            } else {
                              selectedApps.remove(app.packageName);
                            }
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Single-select dialog for picking one installed app by name or package.
class _SelectAppDialog extends StatefulWidget {
  final Function(String) onSelected;

  const _SelectAppDialog({required this.onSelected});

  @override
  State<_SelectAppDialog> createState() => _SelectAppDialogState();
}

class _SelectAppDialogState extends State<_SelectAppDialog> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            AppBar(
              title: const Text('Select app'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search apps…',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) =>
                    setState(() => searchQuery = value.toLowerCase()),
              ),
            ),
            Expanded(
              child: BlocBuilder<AppListCubit, AppListState>(
                builder: (context, state) {
                  var apps = state.installedApps;
                  if (searchQuery.isNotEmpty) {
                    apps = apps
                        .where((a) =>
                            a.name.toLowerCase().contains(searchQuery) ||
                            a.packageName.toLowerCase().contains(searchQuery))
                        .toList();
                  }
                  return ListView.builder(
                    itemCount: apps.length,
                    itemBuilder: (context, index) {
                      final app = apps[index];
                      return ListTile(
                        title: Text(app.name),
                        subtitle: Text(app.packageName),
                        onTap: () {
                          widget.onSelected(app.packageName);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog for adding a new swipe shortcut (direction + app) to a window or
/// the app page.
class _AddShortcutDialog extends StatefulWidget {
  /// The window to add the shortcut to, or `null` for the app-list page.
  final WindowType? windowType;

  const _AddShortcutDialog({this.windowType});

  @override
  State<_AddShortcutDialog> createState() => _AddShortcutDialogState();
}

class _AddShortcutDialogState extends State<_AddShortcutDialog> {
  SwipeDirection? selectedDirection;
  String selectedPackageName = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add shortcut'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<SwipeDirection>(
            hint: const Text('Direction'),
            value: selectedDirection,
            isExpanded: true,
            items: SwipeDirection.values
                .where((d) => d != _reservedDirectionFor(widget.windowType))
                .map((direction) {
              return DropdownMenuItem(
                value: direction,
                child: Text(_directionLabel(direction)),
              );
            }).toList(),
            onChanged: (value) => setState(() => selectedDirection = value),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showSelectAppDialog(context, (pkg) {
              setState(() => selectedPackageName = pkg);
            }),
            child: Text(selectedPackageName.isEmpty
                ? 'Select app'
                : selectedPackageName),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed:
              selectedDirection != null &&
                      selectedPackageName.isNotEmpty &&
                      widget.windowType != null
                  ? () {
                      context.read<ConfigCubit>().updateWindowShortcut(
                            widget.windowType!,
                            selectedDirection!,
                            selectedPackageName,
                          );
                      Navigator.of(context).pop();
                    }
                  : null,
          child: const Text('Add'),
        ),
      ],
    );
  }

  String _directionLabel(SwipeDirection direction) {
    switch (direction) {
      case SwipeDirection.up:
        return '↑  Swipe up';
      case SwipeDirection.down:
        return '↓  Swipe down';
      case SwipeDirection.left:
        return '←  Swipe left';
      case SwipeDirection.right:
        return '→  Swipe right';
    }
  }

  /// Returns the direction reserved for returning to home for [windowType],
  /// or `null` for the app-list page (no reserved direction).
  SwipeDirection? _reservedDirectionFor(WindowType? windowType) {
    switch (windowType) {
      case WindowType.up:
        return SwipeDirection.down;
      case WindowType.down:
        return SwipeDirection.up;
      case WindowType.right:
        return SwipeDirection.left;
      case WindowType.left:
        return SwipeDirection.right;
      case null:
        return null;
    }
  }

  void _showSelectAppDialog(
      BuildContext context, Function(String) onSelected) {
    showDialog(
      context: context,
      builder: (_) => _SelectAppDialog(onSelected: onSelected),
    );
  }
}
