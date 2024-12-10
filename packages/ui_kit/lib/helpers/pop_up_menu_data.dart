import 'package:flutter/widgets.dart';

class PopupMenuItemData<T> {
  final String label;
  final IconData? icon;
  final T value;
  final TextStyle? textStyle;
  final Function(BuildContext context)? onPressed;

  PopupMenuItemData({
    required this.label,
    this.icon,
    required this.value,
    this.textStyle,
    this.onPressed,
  });
}
