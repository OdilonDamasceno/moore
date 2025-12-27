import 'package:flutter/material.dart';

abstract final class AppColors {
  static const MaterialColor primary = MaterialColor(0xFFC52613, {
    50: Color(0xFFFFEDEB),
    100: Color(0xFFFFDBD6),
    200: Color(0xFFFFB8B0),
    300: Color(0xFFFF8A80),
    400: Color(0xFFFF584D),
    500: Color(0xFFC52613),
    600: Color(0xFFA12110),
    700: Color(0xFF7C1A0C),
    800: Color(0xFF5C1309),
    900: Color(0xFF3D0C06),
  });

  static const Color black = Colors.black;

  static const Color black10 = Color(0xff101010);

  static const Color white = Colors.white;

  static const MaterialColor grey = MaterialColor(0xFF9E9E9E, {
    50: Color(0xFFFAFAFA),
    100: Color(0xFFF5F5F5),
    200: Color(0xFFEEEEEE),
    300: Color(0xFFE0E0E0),
    400: Color(0xFFBDBDBD),
    500: Color(0xFF9E9E9E),
    600: Color(0xFF757575),
    700: Color(0xFF616161),
    800: Color(0xFF424242),
    900: Color(0xFF212121),
  });
}
