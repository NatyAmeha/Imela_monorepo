import 'package:flutter/material.dart';

class AppButtonStyle {
  static ButtonStyle filledbuttonStyle({Color? color, double borderRadius = 10, EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12), BorderSide border = BorderSide.none}) {
    return FilledButton.styleFrom(
      backgroundColor: color,
      // textStyle: TextStyle(color: Colors.white, fontSize: 20),
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: border,
      ),
    );
  }

  static ButtonStyle outlinedButtonStyle(BuildContext context, {Color? color, double borderRadius = 10, EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12), BorderSide? border}) {
    return OutlinedButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: color ?? Theme.of(context).colorScheme.secondary,
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: border ?? BorderSide(color: color ?? Theme.of(context).colorScheme.onSecondary, width: 1),
      ),
    );
  }

  static ButtonStyle textButtonStyle(BuildContext context, {Color? color, double borderRadius = 10, EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12), BorderSide border = BorderSide.none}) {
    return TextButton.styleFrom(
      // textStyle: TextStyle(color: Colors.white, fontSize: 20),
      backgroundColor: Colors.transparent,
      foregroundColor: color ?? Theme.of(context).colorScheme.secondary,
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: border,
      ),
    );
  }
}

enum ButtonType { FILLED, OUTLINED, ICON, TEXT }
