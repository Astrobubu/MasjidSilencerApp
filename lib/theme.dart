import 'package:flutter/material.dart';

class AppTheme {
  /// Dark palette that works on **all** stable Flutter releases.
  static ThemeData dark() {
    // In pre-3.16 SDKs we have to build a ColorScheme manually.
    const primary = Colors.teal;

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: primary,
      ),
      fontFamily: 'Roboto',
    );
  }
}
