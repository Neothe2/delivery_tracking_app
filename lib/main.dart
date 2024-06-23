// main.dart
import 'package:delivery_tracking_app/colour_constants.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'login_page.dart'; // Make sure to import login_page.dart here

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); // Initialize Hive
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: ColorPalette.backgroundWhite,
        appBarTheme: const AppBarTheme(
          backgroundColor: ColorPalette.greenVibrant,
          foregroundColor: ColorPalette.greenDarkest, // Text color for app bar
        ),
        textTheme: TextTheme(
            bodyMedium: TextStyle(color: ColorsManager.textColor),
            bodyLarge: TextStyle(color: ColorsManager.textColor),
            bodySmall: TextStyle(color: ColorsManager.textColor),
            displayLarge: TextStyle(color: ColorsManager.textColor),
            displayMedium: TextStyle(color: ColorsManager.textColor),
            displaySmall: TextStyle(color: ColorsManager.textColor),
            headlineLarge: TextStyle(color: ColorsManager.textColor),
            headlineMedium: TextStyle(color: ColorsManager.textColor),
            headlineSmall: TextStyle(color: ColorsManager.textColor),
            labelLarge: TextStyle(color: ColorsManager.textColor),
            labelMedium: TextStyle(color: ColorsManager.textColor),
            labelSmall: TextStyle(color: ColorsManager.textColor),
            titleLarge: TextStyle(color: ColorsManager.textColor),
            titleMedium: TextStyle(color: ColorsManager.textColor),
            titleSmall: TextStyle(color: ColorsManager.textColor)
            // Apply text color to other text styles as needed
            ),
        inputDecorationTheme: const InputDecorationTheme(
            labelStyle: TextStyle(color: ColorsManager.textColor),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: ColorsManager.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: ColorsManager.textColor),
            ),
            filled: true),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: ColorsManager.backgroundColor,
            backgroundColor: ColorsManager.buttonColor,
            // Text color on button
            // side: BorderSide(color: ColorsManager.textColor),
          ),
        ),
        primarySwatch: ColorsManager.primaryColor.getMaterialColorFromColor(),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: ColorsManager.primaryColor.getMaterialColorFromColor(),
          accentColor: ColorsManager.accentColor,
          backgroundColor: ColorsManager.white,
          brightness: Brightness.light,
          cardColor: ColorsManager.offWhite,
          errorColor: ColorsManager.error,
        ),
      ),
      home: LoginPage(
        JWTAuthenticationService(
          SecureTokenStorage(),
        ),
      ), // Replace MyHomePage with LoginPage
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
  // static Color primary = Colors.black87;
  // static Color accent = Colors.lightBlue;
  static Color white = Colors.white;
  static Color offWhite = Colors.white;
  static Color error = Colors.red;

  static const Color backgroundColor = ColorPalette.backgroundWhite;
  static const Color primaryColor = ColorPalette.green; // Primary green
  static const Color accentColor = ColorPalette.greenVibrant; // Darker green
  static const Color textColor = ColorPalette.greenDarkest; // Dark text color
  static const Color buttonColor = ColorPalette.greenDark;
  static const Color borderColor = ColorPalette.greenDarker;
  static const Color cream = ColorPalette.cream;

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
          return const BorderSide(
            color: Colors.blue, // Focused border color
            width: 2.0, // Focused border width
          );
        }
        return const BorderSide(
          color: Colors.grey, // Unfocused border color
          width: 1.0, // Unfocused border width
        );
      }),
      // ... other ButtonStyle properties as needed (e.g., foreground color, padding)
    ),
  );
}
