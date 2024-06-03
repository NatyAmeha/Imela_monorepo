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
        titleMedium: AppTypography.of(context).titleMedium,
        titleSmall: AppTypography.of(context).titleSmall,
        bodyLarge: AppTypography.of(context).bodyLarge,
        bodyMedium: AppTypography.of(context).bodyMedium,
        bodySmall: AppTypography.of(context).bodySmall,
        labelLarge: AppTypography.of(context).labelLarge,
        labelMedium: AppTypography.of(context).labelLarge,
        labelSmall: AppTypography.of(context).labelLarge,
      ),
    );
  }

  ThemeData getDarkTheme() {
    return ThemeData(
      colorScheme: const ColorScheme.light(
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
        titleSmall: AppTypography.of(context).titleSmall,
        bodyLarge: AppTypography.of(context).bodyLarge,
        bodyMedium: AppTypography.of(context).bodyMedium,
        bodySmall: AppTypography.of(context).bodySmall,
        labelLarge: AppTypography.of(context).labelLarge,
        labelMedium: AppTypography.of(context).labelLarge,
        labelSmall: AppTypography.of(context).labelLarge,
      ),
    );
  }
}
