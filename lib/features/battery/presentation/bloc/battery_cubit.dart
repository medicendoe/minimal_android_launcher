// ignore_for_file: depend_on_referenced_packages
import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:battery_plus/battery_plus.dart' as bp;
import 'package:equatable/equatable.dart';

part 'battery_state.dart';

/// Monitors the device battery level and charging state, emitting a new
/// [BatteryLoaded] state whenever either value changes.
class BatteryCubit extends Cubit<BatteryState> {
  final bp.Battery _battery;
  StreamSubscription<bp.BatteryState>? _batteryStateSubscription;

  /// Creates a [BatteryCubit] using the provided [battery] plugin instance.
  BatteryCubit({required bp.Battery battery})
      : _battery = battery,
        super(BatteryInitial()) {
    _initialize();
  }

  /// Fetches the initial battery status and subscribes to charging-state changes.
  Future<void> _initialize() async {
    emit(BatteryInitial());
    await _updateBatteryStatus();
    _listenToBatteryChanges();
  }

  /// Re-reads battery level and state whenever the charging state stream fires.
  void _listenToBatteryChanges() {
    _batteryStateSubscription = _battery.onBatteryStateChanged.listen((_) {
      _updateBatteryStatus();
    });
  }

  /// Reads the current battery level and charging state and emits [BatteryLoaded].
  Future<void> _updateBatteryStatus() async {
    try {
      final level = await _battery.batteryLevel;
      final chargingState = await _battery.batteryState;
      emit(BatteryLoaded(level, chargingState));
    } catch (e) {
      log('BatteryCubit: failed to read battery status — $e');
    }
  }

  @override
  Future<void> close() {
    _batteryStateSubscription?.cancel();
    return super.close();
  }
}
