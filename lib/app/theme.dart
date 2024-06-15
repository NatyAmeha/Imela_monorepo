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
        displayLarge: AppTypography.of(context).displayLarge,
        displayMedium: AppTypography.of(context).displayMedium,
        displaySmall: AppTypography.of(context).displaySmall,
        headlineLarge: AppTypography.of(context).headlineLarge,
        headlineMedium: AppTypography.of(context).headlineMedium,
        headlineSmall: AppTypography.of(context).headlineSmall,
        titleLarge: AppTypography.of(context).titleLarge,
        titleMedium: AppTypography.of(context).titleMedium.copyWith(color: ColorManager.primaryText),
        titleSmall: AppTypography.of(context).titleSmall.copyWith(color: ColorManager.secondaryText),
        bodyLarge: AppTypography.of(context).bodyLarge,
        bodyMedium: AppTypography.of(context).bodyMedium,
        bodySmall: AppTypography.of(context).bodySmall,
        labelLarge: AppTypography.of(context).labelLarge,
        labelMedium: AppTypography.of(context).labelLarge.copyWith(color: ColorManager.secondaryText),
        labelSmall: AppTypography.of(context).labelLarge,
      ),
      appBarTheme: const AppBarTheme().copyWith(
        backgroundColor: ColorManager.alternate,
        centerTitle: true,
        elevation: 2,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.of(context).headlineMedium.copyWith(color: ColorManager.primaryText),
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
        displayLarge: AppTypography.of(context).displayLarge,
        displayMedium: AppTypography.of(context).displayMedium,
        displaySmall: AppTypography.of(context).displaySmall,
        headlineLarge: AppTypography.of(context).headlineLarge,
        headlineMedium: AppTypography.of(context).headlineMedium,
        headlineSmall: AppTypography.of(context).headlineSmall,
        titleLarge: AppTypography.of(context).titleLarge,
        titleMedium: AppTypography.of(context).titleMedium,
        titleSmall: AppTypography.of(context).titleSmall.copyWith(color: ColorManager.infoDark),
        bodyLarge: AppTypography.of(context).bodyLarge,
        bodyMedium: AppTypography.of(context).bodyMedium,
        bodySmall: AppTypography.of(context).bodySmall,
        labelLarge: AppTypography.of(context).labelLarge,
        labelMedium: AppTypography.of(context).labelLarge.copyWith(color: ColorManager.secondaryTextDark),
        labelSmall: AppTypography.of(context).labelLarge,
      ),
      appBarTheme: const AppBarTheme().copyWith(
        backgroundColor: ColorManager.alternateDark,
        centerTitle: true,
        elevation: 2,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.of(context).headlineMedium.copyWith(color: ColorManager.primaryTextDark),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20))),
      filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20))),
    );
  }
}
