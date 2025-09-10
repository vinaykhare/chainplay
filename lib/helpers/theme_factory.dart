import 'package:chain_activities/helpers/constants.dart';

import 'package:flutter/material.dart';

class ThemeFactory {
  final MaterialColor paletteLigthAmber = MaterialColor(
    0xFFFFD54F,
    const <int, Color>{
      50: Color(0xFFFFF8E1),
      100: Color(0xFFFFECB3),
      200: Color(0xFFFFE082),
      300: Color(0xFFFFD54F),
      400: Color(0xFFFFCA28),
      500: Color(0xFFF6E5B3),
      600: Color(0xFFFFB300),
      700: Color(0xFFFFA000),
      800: Color(0xFFFF8F00),
      900: Color(0xFFFF6F00),
    },
  );
  final MaterialColor paletteWhiteAndBlack = MaterialColor(
    0xFFFFFFFF,
    <int, Color>{
      50: Color(0xFFF5F5F5),
      100: Color(0xFFEEEEEE),
      200: Color(0xFFE0E0E0),
      300: Color(0xFFBDBDBD),
      400: Color(0xFF9E9E9E),
      500: Color(0xFF616161),
      600: Color(0xFF424242),
      700: Color(0xFF303030),
      800: Color(0xFF212121),
      900: Color(0xFF000000),
    },
  );

  final MaterialColor paletteBlackAndWhite = MaterialColor(
    0xFF212121,
    <int, Color>{
      50: Color(0xFFFAFAFA),
      100: Color(0xFFF5F5F5),
      200: Color(0xFFE0E0E0),
      300: Color(0xFFBDBDBD),
      400: Color(0xFF9E9E9E),
      500: Color(0xFF616161),
      600: Color(0xFF424242),
      700: Color(0xFF303030),
      800: Color(0xFF212121),
      900: Color(0xFF000000),
    },
  );
  ThemeData getTheme(BuildContext context, String chosenTheme) {
    switch (chosenTheme) {
      case themeLightAmber:
        return ThemeData(
          // useMaterial3: false,
          primarySwatch: paletteLigthAmber,
          scaffoldBackgroundColor: Colors.white,
          cardColor: paletteLigthAmber.shade300,
          canvasColor: paletteLigthAmber.shade100,
          colorScheme: ColorScheme.light(
            surface: paletteLigthAmber,
            primary: paletteLigthAmber.shade100,
            onPrimary: Colors.black,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              backgroundColor: WidgetStateProperty.resolveWith<Color>(
                  (states) => Colors.white),
              foregroundColor: WidgetStateProperty.resolveWith<Color>(
                (states) => Colors.black,
              ),
              textStyle: WidgetStateProperty.resolveWith(
                (states) => Theme.of(context).textTheme.labelLarge,
              ),
              iconColor: WidgetStateProperty.resolveWith<Color>(
                (states) => Colors.black,
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color>(
                  (states) => paletteLigthAmber.shade100),
              foregroundColor: WidgetStateProperty.resolveWith<Color>(
                (states) => Colors.black,
              ),
              textStyle: WidgetStateProperty.resolveWith(
                (states) => Theme.of(context).textTheme.labelLarge,
              ),
              iconColor: WidgetStateProperty.resolveWith<Color>(
                (states) => Colors.black,
              ),
            ),
          ),

          listTileTheme: ListTileThemeData(
            tileColor: Colors.white,
          ),
          switchTheme: SwitchThemeData(
            thumbColor: WidgetStateProperty.resolveWith<Color>(
              (states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                } else {
                  return paletteLigthAmber;
                }
              },
            ),
            trackColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return paletteLigthAmber;
              } else {
                return Colors.white;
              }
            }),
          ),

          drawerTheme: DrawerThemeData(
            backgroundColor: Colors.white,
          ),
          dividerTheme: DividerThemeData(
            color: paletteLigthAmber.shade200,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
          ),
          inputDecorationTheme: InputDecorationTheme(
            fillColor: paletteLigthAmber.shade200,
          ),
          textSelectionTheme: TextSelectionThemeData(
            selectionColor: paletteLigthAmber.shade400,
            cursorColor: Colors.black,
            selectionHandleColor: paletteLigthAmber,
          ),
          snackBarTheme: const SnackBarThemeData(
            actionTextColor: Colors.white,
          ),
          textTheme: const TextTheme(
            titleMedium: TextStyle(
              color: Colors.black,
            ),
            titleLarge: TextStyle(
              color: Colors.black,
            ),
            titleSmall: TextStyle(
              color: Colors.black,
            ),
            bodyMedium: TextStyle(
              color: Colors.black,
            ),
            bodyLarge: TextStyle(
              color: Colors.black,
            ),
            bodySmall: TextStyle(
              color: Colors.black,
            ),
            headlineMedium: TextStyle(
              color: Colors.black,
            ),
            headlineLarge: TextStyle(
              color: Colors.black,
            ),
            headlineSmall: TextStyle(
              color: Colors.black,
            ),
            displayMedium: TextStyle(
              color: Colors.black,
            ),
            displayLarge: TextStyle(
              color: Colors.black,
            ),
            displaySmall: TextStyle(
              color: Colors.black,
            ),
            labelMedium: TextStyle(
              color: Colors.black,
            ),
            labelLarge: TextStyle(
              color: Colors.black,
            ),
            labelSmall: TextStyle(
              color: Colors.black,
            ),
          ),
          dialogTheme: DialogThemeData(
            backgroundColor: Colors.white,
          ),
        );

      case themeBlack:
        return ThemeData(
          // useMaterial3: false, // Keep this if you are not using Material 3
          primarySwatch: paletteBlackAndWhite,
          scaffoldBackgroundColor: paletteBlackAndWhite.shade600,
          cardColor: paletteBlackAndWhite.shade900,
          canvasColor: paletteBlackAndWhite.shade700,
          colorScheme: ColorScheme.dark(
            surface: paletteBlackAndWhite.shade700,
            primary: paletteBlackAndWhite.shade600,
            onPrimary: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
              ),
              backgroundColor: WidgetStateProperty.resolveWith<Color>(
                (states) => paletteBlackAndWhite.shade500,
              ),
              foregroundColor: WidgetStateProperty.resolveWith<Color>(
                (states) => Colors.white,
              ),
              textStyle: WidgetStateProperty.resolveWith(
                (states) => const TextStyle(color: Colors.white),
              ),
            ),
          ),
          listTileTheme: const ListTileThemeData(tileColor: Colors.black),
          switchTheme: SwitchThemeData(
            thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.white;
              } else {
                return paletteBlackAndWhite.shade600;
              }
            }),
            trackColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return paletteBlackAndWhite.shade500;
              } else {
                return Colors.white;
              }
            }),
          ),
          drawerTheme: const DrawerThemeData(backgroundColor: Colors.black),
          dividerTheme: const DividerThemeData(color: Colors.white38),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            fillColor: Color.fromARGB(255, 33, 33, 33),
            labelStyle: TextStyle(color: Colors.white),
            hintStyle: TextStyle(color: Colors.white70),
          ),
          textSelectionTheme: TextSelectionThemeData(
            selectionColor: Colors.white.withValues(alpha: 0.5),
            cursorColor: Colors.white,
            selectionHandleColor: Colors.white,
          ),
          snackBarTheme: const SnackBarThemeData(
            actionTextColor: Colors.white,
            backgroundColor: Colors.black,
          ),
          textTheme: const TextTheme(
            titleMedium: TextStyle(color: Colors.white),
            titleLarge: TextStyle(color: Colors.white),
            titleSmall: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white),
            bodyLarge: TextStyle(color: Colors.white),
            bodySmall: TextStyle(color: Colors.white),
            headlineMedium: TextStyle(color: Colors.white),
            headlineLarge: TextStyle(color: Colors.white),
            headlineSmall: TextStyle(color: Colors.white),
            displayMedium: TextStyle(color: Colors.white),
            displayLarge: TextStyle(color: Colors.white),
            displaySmall: TextStyle(color: Colors.white),
            labelMedium: TextStyle(color: Colors.white),
            labelLarge: TextStyle(color: Colors.white),
            labelSmall: TextStyle(color: Colors.white),
          ),
          dialogTheme: const DialogThemeData(backgroundColor: Colors.black),
        );
      case themeWhite:
        return ThemeData(
          // useMaterial3: false, // Keep this if you are not using Material 3
          primarySwatch: paletteWhiteAndBlack,
          scaffoldBackgroundColor: Colors.white,
          cardColor: paletteWhiteAndBlack.shade300,
          canvasColor: paletteWhiteAndBlack.shade50,
          colorScheme: ColorScheme.light(
            surface: paletteWhiteAndBlack.shade50,
            primary: paletteWhiteAndBlack.shade100,
            onPrimary: Colors.black,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
              ),
              backgroundColor: WidgetStateProperty.resolveWith<Color>(
                (states) => Colors.white,
              ),
              foregroundColor: WidgetStateProperty.resolveWith<Color>(
                (states) => Colors.black,
              ),
              textStyle: WidgetStateProperty.resolveWith(
                (states) => const TextStyle(color: Colors.black),
              ),
              iconColor: WidgetStateProperty.resolveWith<Color>(
                (states) => Colors.black,
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color>(
                (states) => paletteWhiteAndBlack.shade100,
              ),
              foregroundColor: WidgetStateProperty.resolveWith<Color>(
                (states) => Colors.black,
              ),
              textStyle: WidgetStateProperty.resolveWith(
                (states) => const TextStyle(color: Colors.black),
              ),
              iconColor: WidgetStateProperty.resolveWith<Color>(
                (states) => Colors.black,
              ),
            ),
          ),
          listTileTheme: const ListTileThemeData(tileColor: Colors.white),
          switchTheme: SwitchThemeData(
            thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.black;
              } else {
                return paletteWhiteAndBlack.shade200;
              }
            }),
            trackColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return paletteWhiteAndBlack.shade200;
              } else {
                return Colors.black;
              }
            }),
          ),
          drawerTheme: const DrawerThemeData(backgroundColor: Colors.white),
          dividerTheme: const DividerThemeData(color: Colors.black26),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            fillColor: Color.fromARGB(255, 230, 230, 230),
            labelStyle: TextStyle(color: Colors.black),
            hintStyle: TextStyle(color: Colors.black54),
          ),
          textSelectionTheme: TextSelectionThemeData(
            selectionColor: Colors.black.withValues(alpha: 0.5),
            cursorColor: Colors.black,
            selectionHandleColor: Colors.black,
          ),
          snackBarTheme: const SnackBarThemeData(
            actionTextColor: Colors.black,
            backgroundColor: Colors.white,
          ),
          textTheme: const TextTheme(
            titleMedium: TextStyle(color: Colors.black),
            titleLarge: TextStyle(color: Colors.black),
            titleSmall: TextStyle(color: Colors.black),
            bodyMedium: TextStyle(color: Colors.black),
            bodyLarge: TextStyle(color: Colors.black),
            bodySmall: TextStyle(color: Colors.black),
            headlineMedium: TextStyle(color: Colors.black),
            headlineLarge: TextStyle(color: Colors.black),
            headlineSmall: TextStyle(color: Colors.black),
            displayMedium: TextStyle(color: Colors.black),
            displayLarge: TextStyle(color: Colors.black),
            displaySmall: TextStyle(color: Colors.black),
            labelMedium: TextStyle(color: Colors.black),
            labelLarge: TextStyle(color: Colors.black),
            labelSmall: TextStyle(color: Colors.black),
          ),
          dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
        );
      default:
        return ThemeData(
          // useMaterial3: false,
          primarySwatch: paletteLigthAmber,
          scaffoldBackgroundColor: Colors.white,
          cardColor: paletteLigthAmber.shade300,
          canvasColor: paletteLigthAmber.shade100,
          colorScheme: ColorScheme.light(
            surface: paletteLigthAmber,
            primary: paletteLigthAmber.shade100,
            onPrimary: Colors.black,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              backgroundColor: WidgetStateProperty.resolveWith<Color>(
                  (states) => Colors.white),
              foregroundColor: WidgetStateProperty.resolveWith<Color>(
                (states) => Colors.black,
              ),
              textStyle: WidgetStateProperty.resolveWith(
                (states) => Theme.of(context).textTheme.labelLarge,
              ),
              iconColor: WidgetStateProperty.resolveWith<Color>(
                (states) => Colors.black,
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color>(
                  (states) => paletteLigthAmber.shade100),
              foregroundColor: WidgetStateProperty.resolveWith<Color>(
                (states) => Colors.black,
              ),
              textStyle: WidgetStateProperty.resolveWith(
                (states) => Theme.of(context).textTheme.labelLarge,
              ),
              iconColor: WidgetStateProperty.resolveWith<Color>(
                (states) => Colors.black,
              ),
            ),
          ),

          listTileTheme: ListTileThemeData(
            tileColor: Colors.white,
          ),
          switchTheme: SwitchThemeData(
            thumbColor: WidgetStateProperty.resolveWith<Color>(
              (states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                } else {
                  return paletteLigthAmber;
                }
              },
            ),
            trackColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return paletteLigthAmber;
              } else {
                return Colors.white;
              }
            }),
          ),

          drawerTheme: DrawerThemeData(
            backgroundColor: Colors.white,
          ),
          dividerTheme: DividerThemeData(
            color: paletteLigthAmber.shade200,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
          ),
          inputDecorationTheme: InputDecorationTheme(
            fillColor: paletteLigthAmber.shade200,
          ),
          textSelectionTheme: TextSelectionThemeData(
            selectionColor: paletteLigthAmber.shade400,
            cursorColor: Colors.black,
            selectionHandleColor: paletteLigthAmber,
          ),
          snackBarTheme: const SnackBarThemeData(
            actionTextColor: Colors.white,
          ),
          textTheme: const TextTheme(
            titleMedium: TextStyle(
              color: Colors.black,
            ),
            titleLarge: TextStyle(
              color: Colors.black,
            ),
            titleSmall: TextStyle(
              color: Colors.black,
            ),
            bodyMedium: TextStyle(
              color: Colors.black,
            ),
            bodyLarge: TextStyle(
              color: Colors.black,
            ),
            bodySmall: TextStyle(
              color: Colors.black,
            ),
            headlineMedium: TextStyle(
              color: Colors.black,
            ),
            headlineLarge: TextStyle(
              color: Colors.black,
            ),
            headlineSmall: TextStyle(
              color: Colors.black,
            ),
            displayMedium: TextStyle(
              color: Colors.black,
            ),
            displayLarge: TextStyle(
              color: Colors.black,
            ),
            displaySmall: TextStyle(
              color: Colors.black,
            ),
            labelMedium: TextStyle(
              color: Colors.black,
            ),
            labelLarge: TextStyle(
              color: Colors.black,
            ),
            labelSmall: TextStyle(
              color: Colors.black,
            ),
          ),
          dialogTheme: DialogThemeData(
            backgroundColor: Colors.white,
          ),
        );
    }
  }
}
