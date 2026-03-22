part of "battery_cubit.dart";

/// Base class for all battery states.
abstract class BatteryState extends Equatable {
  const BatteryState();

  @override
  List<Object> get props => [];
}

/// Emitted before the first battery reading is available.
class BatteryInitial extends BatteryState {}

/// Emitted once the battery level and charging state are known.
class BatteryLoaded extends BatteryState {
  /// Battery charge level from 0 to 100.
  final int level;

  /// Current charging state (charging, discharging, full, etc.).
  final bp.BatteryState chargingState;

  const BatteryLoaded(this.level, this.chargingState);

  @override
  List<Object> get props => [level, chargingState];
}
