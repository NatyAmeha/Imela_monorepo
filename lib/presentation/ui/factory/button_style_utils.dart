import 'package:flutter/material.dart';

class AppButtonStyle {
  static ButtonStyle applyBtnStyle({Color? color, EdgeInsets? padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14), double? borderRadius, double? elevation}) {
    return ButtonStyle(
      backgroundColor: color != null ? WidgetStateProperty.all<Color>(color) : null,
      padding: padding != null ? WidgetStateProperty.all<EdgeInsetsGeometry>(padding) : null,
      shape: WidgetStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius ?? 8))),
    );
  }
}
