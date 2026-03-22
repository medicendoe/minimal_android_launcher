import 'package:flutter/material.dart';

/// Provides the application's [ThemeData] configuration.
///
/// The app uses a single dark-background theme with the Hermit monospaced font
/// and a fixed white text palette to match the minimal launcher aesthetic.
class AppTheme {
  AppTheme._();

  /// The light theme used throughout the app.
  ///
  /// Despite the name, the scaffold background is black to create an
  /// immersive full-screen launcher feel.
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: Colors.black,
      brightness: Brightness.light,
      primaryColor: Colors.blue,
      fontFamily: 'Hermit',
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 55.0, fontWeight: FontWeight.bold, color: Colors.white),
        displayMedium: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold, color: Colors.white),
        displaySmall: TextStyle(fontSize: 23.0, fontWeight: FontWeight.bold, color: Colors.white),
        bodyLarge: TextStyle(fontSize: 20.0, color: Colors.white),
        bodyMedium: TextStyle(fontSize: 14.0, color: Colors.white),
      ),
    );
  }
}
