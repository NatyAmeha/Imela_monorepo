import 'package:flutter/material.dart';

class AppButtonStyle {
  static ButtonStyle applyBtnStyle({Color? color, EdgeInsets? padding, double? borderRadius, double? elevation}) {
    return ButtonStyle(
      backgroundColor: color != null ? WidgetStateProperty.all<Color>(color) : null,
      padding: padding != null ? WidgetStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.symmetric(horizontal: 16, vertical: 8)) : null,
      shape: WidgetStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius ?? 8))),
    );
  }
}
