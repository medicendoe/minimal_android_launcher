part of 'clock_cubit.dart';

/// Represents a point-in-time snapshot of the current date and time.
class ClockState extends Equatable {
  /// Hour of day (0–23).
  final int hour;

  /// Minute of hour (0–59).
  final int minute;

  /// Day of month (1–31).
  final int day;

  /// Month of year (1–12).
  final int month;

  /// Four-digit year.
  final int year;

  /// ISO weekday: Monday = 1 … Sunday = 7.
  final int weekday;

  const ClockState({
    required this.hour,
    required this.minute,
    required this.day,
    required this.month,
    required this.year,
    required this.weekday,
  });

  /// Creates a [ClockState] initialised to the current wall-clock time.
  factory ClockState.initial() {
    final now = DateTime.now();
    return ClockState(
      hour: now.hour,
      minute: now.minute,
      day: now.day,
      month: now.month,
      year: now.year,
      weekday: now.weekday,
    );
  }

  /// Returns a copy with the specified fields replaced.
  ClockState copyWith({
    int? hour,
    int? minute,
    int? day,
    int? month,
    int? year,
    int? weekday,
  }) {
    return ClockState(
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      day: day ?? this.day,
      month: month ?? this.month,
      year: year ?? this.year,
      weekday: weekday ?? this.weekday,
    );
  }

  @override
  List<Object> get props => [hour, minute, day, month, year, weekday];
}
