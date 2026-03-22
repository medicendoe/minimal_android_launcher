import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/battery_cubit.dart';
import 'package:battery_plus/battery_plus.dart' as bp;
import 'package:launcher/app/theme/app_colors.dart';
import 'arc_painter.dart';

/// Displays the current battery level as a full-screen circular arc.
///
/// The arc color reflects the current battery status:
/// - Charging → [AppColors.batteryCharging]
/// - ≤ 15 % → [AppColors.batteryLow]
/// - ≤ 35 % → [AppColors.batteryMedium]
/// - Otherwise → white
class BatteryDisplayWidget extends StatelessWidget {
  const BatteryDisplayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BatteryCubit, BatteryState>(
      builder: (context, state) {
        if (state is BatteryInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is BatteryLoaded) {
          return _buildBatteryArc(context, state.level, state.chargingState);
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildBatteryArc(
      BuildContext context, int level, bp.BatteryState chargingState) {
    // Choose arc colour based on charging state and level.
    final Color arcColor;
    if (chargingState == bp.BatteryState.charging) {
      arcColor = AppColors.batteryCharging;
    } else if (level <= 15) {
      arcColor = AppColors.batteryLow;
    } else if (level <= 35) {
      arcColor = AppColors.batteryMedium;
    } else {
      arcColor = Colors.white;
    }

    final size = MediaQuery.of(context).size;
    final double canvasSize =
        size.width < size.height ? size.width : size.height;
    const double margin = 10.0;

    return ClipOval(
      child: SizedBox(
        width: canvasSize - margin * 2,
        height: canvasSize - margin * 2,
        child: CustomPaint(
          painter: ArcPainter(
            percentage: level,
            foregroundColor: arcColor,
            strokeWidth: 10.0,
          ),
        ),
      ),
    );
  }
}
