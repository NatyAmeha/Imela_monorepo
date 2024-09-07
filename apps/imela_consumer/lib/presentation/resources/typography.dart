import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTypography {
  late TextStyle displayLarge;
  late TextStyle displayMedium;
  late TextStyle displaySmall;
  late TextStyle headlineLarge;
  late TextStyle headlineMedium;
  late TextStyle headlineSmall;
  late TextStyle titleLarge;
  late TextStyle titleMedium;

  late TextStyle titleSmall;

  late TextStyle labelLarge;

  late TextStyle labelMedium;

  late TextStyle labelSmall;
  late TextStyle bodyLarge;
  late TextStyle bodyMedium;
  late TextStyle bodySmall;

  static AppTypography of(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    if (size.width < 600) {
      return MobileTypography();
    } else if (size.width < 1200) {
      return TabletTypography();
    } else {
      return DesktopTypography();
    }
  }
}

class MobileTypography extends AppTypography {
  MobileTypography();

  @override
  TextStyle get displayLarge => GoogleFonts.getFont('Inter', color: ColorManager.primaryText, fontWeight: FontWeight.normal, fontSize: 57.0);
  @override
  TextStyle get displayMedium => GoogleFonts.getFont('Inter', color: ColorManager.primaryText, fontWeight: FontWeight.bold, fontSize: 45.0);
  @override
  TextStyle get displaySmall => GoogleFonts.getFont('Inter', color: ColorManager.primaryText, fontWeight: FontWeight.bold, fontSize: 30.0);
  @override
  TextStyle get headlineLarge => GoogleFonts.getFont('Inter', color: ColorManager.primaryText, fontWeight: FontWeight.normal, fontSize: 32.0);
  @override
  TextStyle get headlineMedium => GoogleFonts.getFont('Inter', color: ColorManager.primaryText, fontWeight: FontWeight.w800, fontSize: 23.0);
  @override
  TextStyle get headlineSmall => GoogleFonts.getFont('Inter', color: ColorManager.primaryText, fontWeight: FontWeight.w600, fontSize: 20.0);
  @override
  TextStyle get titleLarge => GoogleFonts.getFont('Readex Pro', color: ColorManager.primaryText, fontWeight: FontWeight.w500, fontSize: 21.0);
  @override
  TextStyle get titleMedium => GoogleFonts.getFont('Readex Pro', color: ColorManager.info, fontWeight: FontWeight.w500, fontSize: 18.0);
  @override
  TextStyle get titleSmall => GoogleFonts.getFont('Readex Pro', color: ColorManager.info, fontWeight: FontWeight.w500, fontSize: 15.0);
  @override
  TextStyle get labelLarge => GoogleFonts.getFont('Readex Pro', color: ColorManager.secondaryText, fontWeight: FontWeight.w500, fontSize: 16.0);
  @override
  TextStyle get labelMedium => GoogleFonts.getFont('Readex Pro', color: ColorManager.secondaryText, fontWeight: FontWeight.w500, fontSize: 14.0);
  @override
  TextStyle get labelSmall => GoogleFonts.getFont('Readex Pro', color: ColorManager.secondaryText, fontWeight: FontWeight.w500, fontSize: 12.0);
  @override
  TextStyle get bodyLarge => GoogleFonts.getFont('Readex Pro', color: ColorManager.primaryText, fontSize: 16.0);
  @override
  TextStyle get bodyMedium => GoogleFonts.getFont('Readex Pro', color: ColorManager.primaryText, fontWeight: FontWeight.normal, fontSize: 14.0);
  @override
  TextStyle get bodySmall => GoogleFonts.getFont('Readex Pro', color: ColorManager.primaryText, fontWeight: FontWeight.normal, fontSize: 12.0);
}

class DesktopTypography extends AppTypography {
  @override
  TextStyle get displayLarge => GoogleFonts.getFont('Inter', color: ColorManager.primaryText, fontWeight: FontWeight.normal, fontSize: 57.0);
  @override
  TextStyle get displayMedium => GoogleFonts.getFont('Inter', color: ColorManager.primaryText, fontWeight: FontWeight.bold, fontSize: 45.0);
  @override
  TextStyle get displaySmall => GoogleFonts.getFont('Inter', color: ColorManager.primaryText, fontWeight: FontWeight.bold, fontSize: 30.0);
  @override
  TextStyle get headlineLarge => GoogleFonts.getFont('Inter', color: ColorManager.primaryText, fontWeight: FontWeight.normal, fontSize: 32.0);
  @override
  TextStyle get headlineMedium => GoogleFonts.getFont('Inter', color: ColorManager.primaryText, fontWeight: FontWeight.w500, fontSize: 24.0);
  @override
  TextStyle get headlineSmall => GoogleFonts.getFont('Inter', color: ColorManager.primaryText, fontWeight: FontWeight.w500, fontSize: 20.0);
  @override
  TextStyle get titleLarge => GoogleFonts.getFont('Readex Pro', color: ColorManager.primaryText, fontWeight: FontWeight.w500, fontSize: 21.0);
  @override
  TextStyle get titleMedium => GoogleFonts.getFont('Readex Pro', color: ColorManager.info, fontWeight: FontWeight.w500, fontSize: 18.0);
  @override
  TextStyle get titleSmall => GoogleFonts.getFont('Readex Pro', color: ColorManager.info, fontWeight: FontWeight.w500, fontSize: 15.0);
  @override
  TextStyle get labelLarge => GoogleFonts.getFont('Readex Pro', color: ColorManager.secondaryText, fontWeight: FontWeight.w500, fontSize: 16.0);
  @override
  TextStyle get labelMedium => GoogleFonts.getFont('Readex Pro', color: ColorManager.secondaryText, fontWeight: FontWeight.w500, fontSize: 14.0);
  @override
  TextStyle get labelSmall => GoogleFonts.getFont('Readex Pro', color: ColorManager.secondaryText, fontWeight: FontWeight.w500, fontSize: 12.0);
  @override
  TextStyle get bodyLarge => GoogleFonts.getFont('Readex Pro', color: ColorManager.primaryText, fontSize: 16.0);
  @override
  TextStyle get bodyMedium => GoogleFonts.getFont('Readex Pro', color: ColorManager.primaryText, fontWeight: FontWeight.normal, fontSize: 14.0);
  @override
  TextStyle get bodySmall => GoogleFonts.getFont('Readex Pro', color: ColorManager.primaryText, fontWeight: FontWeight.normal, fontSize: 12.0);
}

class TabletTypography extends AppTypography {
  @override
  TextStyle get displayLarge => GoogleFonts.getFont('Inter', color: ColorManager.primaryText, fontWeight: FontWeight.normal, fontSize: 57.0);
  @override
  TextStyle get displayMedium => GoogleFonts.getFont('Inter', color: ColorManager.primaryText, fontWeight: FontWeight.bold, fontSize: 45.0);
  @override
  TextStyle get displaySmall => GoogleFonts.getFont('Inter', color: ColorManager.primaryText, fontWeight: FontWeight.bold, fontSize: 30.0);
  @override
  TextStyle get headlineLarge => GoogleFonts.getFont('Inter', color: ColorManager.primaryText, fontWeight: FontWeight.normal, fontSize: 32.0);
  @override
  TextStyle get headlineMedium => GoogleFonts.getFont('Inter', color: ColorManager.primaryText, fontWeight: FontWeight.w500, fontSize: 24.0);
  @override
  TextStyle get headlineSmall => GoogleFonts.getFont('Inter', color: ColorManager.primaryText, fontWeight: FontWeight.w500, fontSize: 20.0);
  @override
  TextStyle get titleLarge => GoogleFonts.getFont('Readex Pro', color: ColorManager.primaryText, fontWeight: FontWeight.w500, fontSize: 22.0);
  @override
  TextStyle get titleMedium => GoogleFonts.getFont('Readex Pro', color: ColorManager.info, fontWeight: FontWeight.w500, fontSize: 16.0);
  @override
  TextStyle get titleSmall => GoogleFonts.getFont('Readex Pro', color: ColorManager.info, fontWeight: FontWeight.w500, fontSize: 14.0);
  @override
  TextStyle get labelLarge => GoogleFonts.getFont('Readex Pro', color: ColorManager.secondaryText, fontWeight: FontWeight.w500, fontSize: 16.0);
  @override
  TextStyle get labelMedium => GoogleFonts.getFont('Readex Pro', color: ColorManager.secondaryText, fontWeight: FontWeight.w500, fontSize: 14.0);
  @override
  TextStyle get labelSmall => GoogleFonts.getFont('Readex Pro', color: ColorManager.secondaryText, fontWeight: FontWeight.w500, fontSize: 12.0);
  @override
  TextStyle get bodyLarge => GoogleFonts.getFont('Readex Pro', color: ColorManager.primaryText, fontSize: 16.0);
  @override
  TextStyle get bodyMedium => GoogleFonts.getFont('Readex Pro', color: ColorManager.primaryText, fontWeight: FontWeight.normal, fontSize: 14.0);
  @override
  TextStyle get bodySmall => GoogleFonts.getFont('Readex Pro', color: ColorManager.primaryText, fontWeight: FontWeight.normal, fontSize: 12.0);
}
