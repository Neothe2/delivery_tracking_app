// main.dart
import 'package:flutter/material.dart';

import 'login_page.dart'; // Make sure to import login_page.dart here

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        inputDecorationTheme: const InputDecorationTheme(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey, // Set desired unfocused border color
                width: 1.0, // Set desired unfocused border width
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey, // Set desired unfocused border color
                width: 1.0, // Set desired unfocused border width
              ),
            )),
        outlinedButtonTheme: createOutlinedButtonTheme(),
        primarySwatch: ColorsManager.primary.getMaterialColorFromColor(),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: ColorsManager.primary.getMaterialColorFromColor(),
          accentColor: ColorsManager.accent,
          backgroundColor: ColorsManager.white,
          brightness: Brightness.light,
          cardColor: ColorsManager.offWhite,
          errorColor: ColorsManager.error,
        ),
      ),
      home: LoginPage(), // Replace MyHomePage with LoginPage
    );
  }
}

extension SuiizColors on Color {
  /// Returns a [MaterialColor] from a [Color] object
  MaterialColor getMaterialColorFromColor() {
    final colorShades = <int, Color>{
      50: ColorsManager.getShade(this, value: 0.5),
      100: ColorsManager.getShade(this, value: 0.4),
      200: ColorsManager.getShade(this, value: 0.3),
      300: ColorsManager.getShade(this, value: 0.2),
      400: ColorsManager.getShade(this, value: 0.1),
      500: this, //Primary value
      600: ColorsManager.getShade(this, value: 0.1, darker: true),
      700: ColorsManager.getShade(this, value: 0.15, darker: true),
      800: ColorsManager.getShade(this, value: 0.2, darker: true),
      900: ColorsManager.getShade(this, value: 0.25, darker: true),
    };
    return MaterialColor(value, colorShades);
  }
}

class ColorsManager {
  static Color primary = Colors.black87;
  static Color accent = Colors.lightBlue;
  static Color white = Colors.white;
  static Color offWhite = Colors.white;
  static Color error = Colors.red;

  static Color getShade(Color color, {bool darker = false, double value = .1}) {
    assert(value >= 0 && value <= 1, 'shade values must be between 0 and 1');

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness(
      (darker ? (hsl.lightness - value) : (hsl.lightness + value))
          .clamp(0.0, 1.0),
    );

    return hslDark.toColor();
  }
}

OutlinedButtonThemeData createOutlinedButtonTheme() {
  return OutlinedButtonThemeData(
    style: ButtonStyle(
      side: MaterialStateProperty.resolveWith<BorderSide>((states) {
        if (states.contains(MaterialState.focused)) {
          return BorderSide(
            color: Colors.blue, // Focused border color
            width: 2.0, // Focused border width
          );
        }
        return BorderSide(
          color: Colors.grey, // Unfocused border color
          width: 1.0, // Unfocused border width
        );
      }),
      // ... other ButtonStyle properties as needed (e.g., foreground color, padding)
    ),
  );
}
