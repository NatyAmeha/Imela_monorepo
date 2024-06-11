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
}
