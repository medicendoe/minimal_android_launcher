import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:launcher/app/theme/app_theme.dart';
import 'package:launcher/app/route/router.dart';
import 'package:launcher/app/route/route_constants.dart';
import 'package:launcher/features/app_list/app_list_feature.dart';
import 'package:launcher/features/config/config_feature.dart';

/// Entry point. Locks the device to portrait orientation, initialises the
/// root-level Cubits, and mounts the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final appListCubit = AppListCubit();
  final configCubit = ConfigCubit(ConfigRepository());

  runApp(MyApp(appListCubit: appListCubit, configCubit: configCubit));
}

/// Root widget. Provides [AppListCubit] and [ConfigCubit] to the entire tree.
class MyApp extends StatelessWidget {
  final AppListCubit appListCubit;
  final ConfigCubit configCubit;

  const MyApp({
    super.key,
    required this.appListCubit,
    required this.configCubit,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: appListCubit),
        BlocProvider.value(value: configCubit),
      ],
      child: MaterialApp(
        title: 'Launcher',
        theme: AppTheme.lightTheme,
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: RouteConstants.home,
      ),
    );
  }
}
