import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'clock_state.dart';

/// Emits a new [ClockState] every second, keeping the displayed time current.
class ClockCubit extends Cubit<ClockState> {
  late final Timer _timer;

  ClockCubit() : super(ClockState.initial()) {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => updateClock());
  }

  /// Reads the current wall-clock time and emits an updated [ClockState].
  void updateClock() {
    final now = DateTime.now();
    emit(state.copyWith(
      hour: now.hour,
      minute: now.minute,
      day: now.day,
      month: now.month,
      year: now.year,
      weekday: now.weekday,
    ));
  }

  @override
  Future<void> close() {
    _timer.cancel();
    return super.close();
  }
}
