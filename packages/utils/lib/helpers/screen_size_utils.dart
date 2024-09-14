// lib/utils/responsive.dart
import 'package:flutter/material.dart';

enum ScreenSize { small, medium, large }

class Responsive {
  static ScreenSize getScreenSize(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) return ScreenSize.small;
    if (width < 1200) return ScreenSize.medium;
    return ScreenSize.large;
  }

  static bool isSmallScreen(BuildContext context) => getScreenSize(context) == ScreenSize.small;
  static bool isMediumScreen(BuildContext context) => getScreenSize(context) == ScreenSize.medium;
  static bool isLargeScreen(BuildContext context) => getScreenSize(context) == ScreenSize.large;
  static bool isLargeOrMediumScreen(BuildContext context) => isLargeScreen(context) || isMediumScreen(context);

  static int getGridCount(BuildContext context, {required double itemWidth}) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final crossAxisCount = (screenWidth / itemWidth).floor();
    return crossAxisCount > 0 ? crossAxisCount : 1;
  }

  static EdgeInsets paddingSymetric(BuildContext context, {double smallHorizontal = 16, double mediumHorizontal = 24, double largeHorizontal = 24, double smallVertical = 16, double mediumVertical = 24, double largeVertical = 24}) {
    if (isSmallScreen(context))
      return EdgeInsets.symmetric(horizontal: smallHorizontal, vertical: smallVertical);
    else if (isMediumScreen(context))
      return EdgeInsets.symmetric(horizontal: mediumHorizontal, vertical: mediumVertical);
    else if (isLargeScreen(context))
      return EdgeInsets.symmetric(horizontal: largeHorizontal, vertical: largeVertical);
    else
      return EdgeInsets.symmetric(horizontal: smallHorizontal, vertical: smallVertical);
  }
}

class Destination {
  final String title;
  final Widget icon;
  final Widget page;

  const Destination({required this.title, required this.icon, required this.page});
}
