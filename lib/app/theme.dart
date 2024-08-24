import 'package:flutter/material.dart';
import 'package:melegna_customer/presentation/resources/colors.dart';
import 'package:melegna_customer/presentation/resources/typography.dart';

class AppThemeManager {
  late BuildContext context;
  static final AppThemeManager _instance = AppThemeManager._internal();
  static AppThemeManager getInstance(BuildContext context) {
    _instance.context = context;
    return _instance;
  }

  AppThemeManager._internal();

  ThemeData getLightTheme() {
    return ThemeData(
      colorScheme: const ColorScheme.light(
        primary: ColorManager.primary,
        secondary: ColorManager.secondary,
        secondaryContainer: ColorManager.secondaryBackground,
        primaryContainer: ColorManager.primaryBackground,
        tertiary: ColorManager.tertiary,
        surface: ColorManager.primaryBackground,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.of(context).displayLarge.copyWith(color: ColorManager.primaryText),
        displayMedium: AppTypography.of(context).displayMedium.copyWith(color: ColorManager.primaryText),
        displaySmall: AppTypography.of(context).displaySmall.copyWith(color: ColorManager.primaryText),
        headlineLarge: AppTypography.of(context).headlineLarge.copyWith(color: ColorManager.primaryText),
        headlineMedium: AppTypography.of(context).headlineMedium.copyWith(color: ColorManager.primaryText),
        headlineSmall: AppTypography.of(context).headlineSmall.copyWith(color: ColorManager.primaryText),
        titleLarge: AppTypography.of(context).titleLarge.copyWith(color: ColorManager.primaryText),
        titleMedium: AppTypography.of(context).titleMedium.copyWith(color: ColorManager.primaryText),
        titleSmall: AppTypography.of(context).titleSmall.copyWith(color: ColorManager.secondaryText),
        bodyLarge: AppTypography.of(context).bodyLarge.copyWith(color: ColorManager.primaryText),
        bodyMedium: AppTypography.of(context).bodyMedium.copyWith(color: ColorManager.primaryText),
        bodySmall: AppTypography.of(context).bodySmall.copyWith(color: ColorManager.primaryText),
        labelLarge: AppTypography.of(context).labelLarge.copyWith(color: ColorManager.secondaryText),
        labelMedium: AppTypography.of(context).labelMedium.copyWith(color: ColorManager.secondaryText),
        labelSmall: AppTypography.of(context).labelSmall.copyWith(color: ColorManager.secondaryText),
      ),
      appBarTheme: const AppBarTheme().copyWith(
        backgroundColor: ColorManager.alternate,
        centerTitle: true,
        elevation: 2,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.of(context).headlineSmall.copyWith(color: ColorManager.primaryText),
      ),
    );
  }

  ThemeData getDarkTheme() {
    return ThemeData(
      colorScheme: const ColorScheme.dark(
        primary: ColorManager.primaryDark,
        secondary: ColorManager.secondaryDark,
        secondaryContainer: ColorManager.secondaryBackgroundDark,
        primaryContainer: ColorManager.primaryBackgroundDark,
        tertiary: ColorManager.tertiaryDark,
        surface: ColorManager.primaryBackgroundDark,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.of(context).displayLarge.copyWith(color: ColorManager.primaryTextDark),
        displayMedium: AppTypography.of(context).displayMedium.copyWith(color: ColorManager.primaryTextDark),
        displaySmall: AppTypography.of(context).displaySmall.copyWith(color: ColorManager.primaryTextDark),
        headlineLarge: AppTypography.of(context).headlineLarge.copyWith(color: ColorManager.primaryTextDark),
        headlineMedium: AppTypography.of(context).headlineMedium.copyWith(color: ColorManager.primaryTextDark),
        headlineSmall: AppTypography.of(context).headlineSmall.copyWith(color: ColorManager.primaryTextDark),
        titleLarge: AppTypography.of(context).titleLarge.copyWith(color: ColorManager.primaryTextDark),
        titleMedium: AppTypography.of(context).titleMedium.copyWith(color: ColorManager.primaryTextDark),
        titleSmall: AppTypography.of(context).titleSmall.copyWith(color: ColorManager.secondaryTextDark),
        bodyLarge: AppTypography.of(context).bodyLarge.copyWith(color: ColorManager.primaryTextDark),
        bodyMedium: AppTypography.of(context).bodyMedium.copyWith(color: ColorManager.primaryTextDark),
        bodySmall: AppTypography.of(context).bodySmall.copyWith(color: ColorManager.primaryTextDark),
        labelLarge: AppTypography.of(context).labelLarge.copyWith(color: ColorManager.secondaryTextDark),
        labelMedium: AppTypography.of(context).labelMedium.copyWith(color: ColorManager.secondaryTextDark),
        labelSmall: AppTypography.of(context).labelSmall.copyWith(color: ColorManager.secondaryTextDark),
      ),
      
      appBarTheme: const AppBarTheme().copyWith(
        backgroundColor: ColorManager.alternateDark,
        centerTitle: true,
        elevation: 2,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.of(context).headlineMedium, //.copyWith(color: ColorManager.primaryTextDark),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20))),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20))),
    );
  }
}
