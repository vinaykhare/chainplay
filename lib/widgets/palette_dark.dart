//palette.dart
import 'package:flutter/material.dart';

class PaletteDark {
  static int primaryColor = 0xFF000000;
  static MaterialColor lightGrey = MaterialColor(
    primaryColor,
    const <int, Color>{
      50: Color(0xFFFAFAFA),
      100: Color(0xFFF5F5F5),
      200: Color(0xFFEEEEEE),
      300: Color.fromARGB(255, 0, 0, 0),
      350: Color(
          0xFF000000), // only for raised button while pressed in light theme
      400: Color(0xFFBDBDBD),
      500: Color(0xFF9E9E9E),
      600: Color(0xFF757575),
      700: Color(0xFF616161),
      800: Color(0xFF424242),
      850: Color(0xFF303030), // only for background color in dark theme
      900: Color(0xFF212121),
    },
  );
} //
