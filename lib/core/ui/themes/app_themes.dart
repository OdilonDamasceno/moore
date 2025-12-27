import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moore/core/ui/themes/app_colors.dart';
import 'package:moore/core/ui/themes/app_text_theme.dart';

final lightAppThemeProvider = Provider((ref) {
  final textTheme = ref.watch(appTextThemeProvider);

  final textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      textStyle: textTheme.bodyMedium,
    ),
  );

  final iconButtonTheme = IconButtonThemeData(
    style: IconButton.styleFrom(
      padding: EdgeInsets.zero,
      iconSize: 16.0,
      shape: const CircleBorder(),
    ),
  );

  return ThemeData(
    primarySwatch: AppColors.primary,
    brightness: Brightness.light,
    textButtonTheme: textButtonTheme,
    iconButtonTheme: iconButtonTheme,
    textTheme: textTheme,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
  );
}, dependencies: [appTextThemeProvider]);

final darkAppThemeProvider = Provider((ref) {
  final textTheme = ref.watch(appTextThemeProvider);

  const Size minimumTextButtonSize = .new(1, 34);

  final textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      minimumSize: minimumTextButtonSize,
      alignment: Alignment.center - const Alignment(0.0, 0.2),
      textStyle: textTheme.bodyMedium,
    ),
  );

  const Size iconButtonSize = .fromRadius(14);

  final iconButtonTheme = IconButtonThemeData(
    style: IconButton.styleFrom(
      padding: EdgeInsets.zero,
      iconSize: iconButtonSize.height / 2,
      maximumSize: iconButtonSize,
      minimumSize: iconButtonSize,
      tapTargetSize: .shrinkWrap,
      shape: const CircleBorder(),
    ),
  );

  final sliderTheme = SliderThemeData(
    trackHeight: 10,
    thumbSize: WidgetStateProperty.all(const Size(2, 20)),
    inactiveTrackColor: AppColors.grey.shade900,
    activeTrackColor: AppColors.primary.shade600,
    thumbColor: AppColors.primary.shade600,
  );

  return ThemeData(
    useMaterial3: true,
    primarySwatch: AppColors.primary,
    brightness: Brightness.dark,
    textTheme: textTheme,
    iconButtonTheme: iconButtonTheme,
    textButtonTheme: textButtonTheme,
    sliderTheme: sliderTheme,
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        for (final platform in TargetPlatform.values)
          platform: const FadeUpwardsPageTransitionsBuilder(),
      },
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      surface: AppColors.black,
    ),
  );
}, dependencies: [appTextThemeProvider]);
