import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/clock_cubit.dart';
import 'package:launcher/app/theme/app_colors.dart';
import 'package:launcher/features/battery/battery_feature.dart';
import 'package:battery_plus/battery_plus.dart' as bp;

/// Displays the current time, date, and day of week as a full-screen widget.
///
/// The text colour reflects the battery status (via [BatteryCubit]):
/// - Charging → [AppColors.batteryCharging]
/// - ≤ 15 % → [AppColors.batteryLow]
/// - ≤ 35 % → [AppColors.batteryMedium]
/// - Otherwise → white
class ClockWidget extends StatelessWidget {
  // Index 0 is unused; weekday values run Monday (1) to Sunday (7).
  static const List<String> _weekdayNames = [
    '',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  const ClockWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClockCubit, ClockState>(
      builder: (context, state) {
        final batteryState = context.watch<BatteryCubit>().state;

        // Determine clock colour based on battery level / charging state.
        Color clockColor = Colors.white;
        if (batteryState is BatteryLoaded) {
          if (batteryState.chargingState == bp.BatteryState.charging) {
            clockColor = AppColors.batteryCharging;
          } else if (batteryState.level <= 15) {
            clockColor = AppColors.batteryLow;
          } else if (batteryState.level <= 35) {
            clockColor = AppColors.batteryMedium;
          }
        }

        return Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${state.hour.toString().padLeft(2, '0')}:${state.minute.toString().padLeft(2, '0')}',
                style: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(color: clockColor),
              ),
              const SizedBox(height: 8),
              Text(
                '${state.day.toString().padLeft(2, '0')}/${state.month.toString().padLeft(2, '0')}/${state.year}',
                style: Theme.of(context)
                    .textTheme
                    .displayMedium
                    ?.copyWith(color: clockColor),
              ),
              const SizedBox(height: 4),
              Text(
                _weekdayNames[state.weekday],
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(color: clockColor),
              ),
            ],
          ),
        );
      },
    );
  }
}
