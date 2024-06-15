import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:melegna_customer/presentation/ui/factory/android_widget.facotry.dart';
import 'package:melegna_customer/presentation/ui/factory/ios_widget.factory.dart';

abstract class WidgetFactory {
  Widget createButton({required BuildContext context, required Widget content, Widget? icon, ButtonStyle? style, bool showLoadingIndicator = true, bool isLoading = false, Function? onPressed});
  Widget createCard({required Widget child, EdgeInsetsGeometry? margin, EdgeInsetsGeometry? padding, double? width, double? height, Color? color, double? elevation, BorderRadius? borderRadius, List<BoxShadow>? boxShadow, final Border? border, Function()? onTap});
  Widget createLoadingIndicator(BuildContext context, {double? width = 20, double height = 20});
  Widget createText(BuildContext context, String text, {TextStyle? style, TextDecoration? textDecoration, EdgeInsetsGeometry? padding, TextAlign? textAlign, TextOverflow? overflow, int? maxLines, Color? color});
  Widget createIcon({required IconData materialIcon, IconData? cupertinoIcon, double size = 24, Color? color, String? semanticLabel, EdgeInsets? padding, Function()? onPressed});

  Widget createCheckboxListTile(BuildContext context, {required String title, String? subtitle, required bool value, required Function(bool?) onChanged});
  Widget createRadioListTile<T>(BuildContext context, {required String title, String? subtitle, required T value, required T groupValue, required Function(T? p1) onChanged});
  Widget createDropDown<T>({required BuildContext context, required Map<T, Widget> options, T? value, required ValueChanged<T?> onChanged, double height = 200});
  Widget createSwitch(bool value, Function(bool) onChanged);

  Widget createAppbar();

  // dialog related widgets
  Future<T?> createAlertDialog<T>(BuildContext context, {String? title, Widget? titleWidget, String content, Widget? contentWidget, required String confirmText, required String cancelText, VoidCallback? onConfirm, VoidCallback? onCancel, bool dismissable = true});
  Future<T?> createModalBottomSheet<T>(BuildContext context, {required Widget content, bool dismissable = true});

  Widget createListTile({required Widget title, Widget? subtitle, Widget? leading, Widget? trailing, Function()? onTap});

  Widget createPageView(BuildContext context, {required int itemCount, required IndexedWidgetBuilder itemBuilder, required PageController controller, required double width, required double height, Axis? scrollDirection, ValueChanged<int>? onPageChanged});

  Widget createTextField(
      {required TextEditingController controller,
      required String hintText,
      bool obscureText = false,
      TextInputType keyboardType = TextInputType.text,
      bool enabled = true,
      bool autocorrect = true,
      int maxLines = 1,
      int maxLength = 0,
      String? Function(String?)? validator,
      void Function(String)? onChanged,
      Widget? suffixIcon,
      Widget? prefixIcon,
      InputDecoration? decoration});

  factory WidgetFactory(TargetPlatform currentPlatform) {
    switch (currentPlatform) {
      case TargetPlatform.android:
        return AndroidWidgetFactory();
      case TargetPlatform.iOS:
        return IosWidgetFactory();
      default:
        return AndroidWidgetFactory();
    }
  }
}
