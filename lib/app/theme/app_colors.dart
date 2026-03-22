import 'package:flutter/material.dart';

/// Shared color constants used across battery and clock widgets to indicate
/// battery charge level and charging status.
class AppColors {
  AppColors._();

  /// Color shown when the device is actively charging.
  static const Color batteryCharging = Color(0xFFCCFFCC);

  /// Color shown when battery level is at or below 15 %.
  static const Color batteryLow = Color(0xFFFFCCCB);

  /// Color shown when battery level is at or below 35 %.
  static const Color batteryMedium = Color(0xFFFFDAB9);
}
