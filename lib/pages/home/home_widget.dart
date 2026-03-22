import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:launcher/features/clock/clock_feature.dart';
import 'package:launcher/features/battery/battery_feature.dart';
import 'package:launcher/features/config/config_feature.dart';
import 'package:launcher/app/route/route_constants.dart';

/// The home screen — the central hub of the launcher.
///
/// Displays a full-screen clock with a battery arc overlay.
/// Swiping in any direction navigates to one of the four themed windows:
///
/// | Gesture      | Destination              |
/// |:-------------|:-------------------------|
/// | Swipe up     | Up window (`/up`)        |
/// | Swipe down   | Down window (`/down`)    |
/// | Swipe right  | Right window (`/right`)  |
/// | Swipe left   | Left window (`/left`)    |
///
/// Tapping launches the app configured in [AppConfig.clockTapPackageName].
/// Long-pressing launches the app configured in [AppConfig.clockHoldPackageName].
class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  late final Battery _battery;

  @override
  void initState() {
    super.initState();
    _battery = Battery();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConfigCubit, ConfigState>(
      builder: (context, configState) {
        final config = configState.config;
        return GestureDetector(
          onTap: config.clockTapPackageName != null
              ? () => InstalledApps.startApp(config.clockTapPackageName!)
              : null,
          onLongPress: config.clockHoldPackageName != null
              ? () => InstalledApps.startApp(config.clockHoldPackageName!)
              : null,
          onVerticalDragEnd: (details) {
            final dy = details.velocity.pixelsPerSecond.dy;
            if (dy > 300) {
              Navigator.pushNamed(context, RouteConstants.down);
            } else if (dy < -300) {
              Navigator.pushNamed(context, RouteConstants.up);
            }
          },
          onHorizontalDragEnd: (details) {
            final dx = details.velocity.pixelsPerSecond.dx;
            if (dx > 300) {
              Navigator.pushNamed(context, RouteConstants.right);
            } else if (dx < -300) {
              Navigator.pushNamed(context, RouteConstants.left);
            }
          },
          child: Scaffold(
            body: MultiBlocProvider(
              providers: [
                BlocProvider<ClockCubit>(create: (_) => ClockCubit()),
                BlocProvider<BatteryCubit>(
                    create: (_) => BatteryCubit(battery: _battery)),
              ],
              child: const Stack(
                alignment: Alignment.center,
                children: [
                  ClockWidget(),
                  BatteryDisplayWidget(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
