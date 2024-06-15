import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:melegna_customer/presentation/ui/factory/base_widget.factory.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class IosWidgetFactory extends BaseWidgetFactory {
  @override
  Widget createButton({required BuildContext context, required Widget content, Widget? icon, ButtonStyle? style, bool showLoadingIndicator = true, bool isLoading = false, Function? onPressed}) {
    return CupertinoButton.filled(
      onPressed: (onPressed == null || isLoading)
          ? null
          : () async {
              await onPressed.call();
            },
      
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLoadingIndicator && isLoading) ...[createLoadingIndicator(context), const SizedBox(width: 8)],
          content,
        ],
      ),
      
    );
  }

  @override
  Widget createCard({required Widget child, EdgeInsetsGeometry? margin, EdgeInsetsGeometry? padding, double? width, double? height, Color? color, double? elevation, BorderRadius? borderRadius, List<BoxShadow>? boxShadow, final Border? border, Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        margin: margin,
        width: width,
        height: height,
        decoration: BoxDecoration(color: color, border: border, borderRadius: borderRadius ?? BorderRadius.circular(8.0), boxShadow: boxShadow),
        child: child,
      ),
    );
  }

  @override
  Widget createLoadingIndicator(BuildContext context, {double? width = 20, double height = 20}) {
    return SizedBox(width: width, height: height, child: const CupertinoActivityIndicator());
  }

  @override
  Widget createIcon({required IconData materialIcon, IconData? cupertinoIcon, double size = 24, Color? color, String? semanticLabel, EdgeInsets? padding, Function()? onPressed}) {
    if (onPressed != null) {
      return IconButton(onPressed: onPressed, icon: Icon(cupertinoIcon ?? materialIcon, size: size, color: color, semanticLabel: semanticLabel));
    }
    return Icon(cupertinoIcon ?? materialIcon, size: size, color: color, semanticLabel: semanticLabel);
  }

  @override
  Widget createAppbar() {
    // TODO: implement createAppbar
    throw UnimplementedError();
  }

  @override
  Widget createCheckboxListTile(BuildContext context, {required String title, String? subtitle, required bool value, required Function(bool? p1) onChanged}) {
    return CheckboxListTile.adaptive(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      value: value,
      onChanged: onChanged,
    );
  }

  @override
  Widget createDropDown<T>({required BuildContext context, required Map<T, Widget> options, T? value, required ValueChanged<T?> onChanged, double height = 200}) {
    return GestureDetector(
      onTap: () {
        showCupertinoModalPopup<void>(
          context: context,
          builder: (BuildContext context) {
            return SizedBox(
              height: height,
              child: CupertinoPicker(
                itemExtent: 32.0,
                onSelectedItemChanged: (int index) {
                  onChanged(options.keys.elementAt(index));
                },
                scrollController: FixedExtentScrollController(initialItem: value != null ? options.keys.toList().indexOf(value!) : 0),
                children: options.values.toList(),
              ),
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: CupertinoColors.systemGrey),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(value.toString()),
      ),
    );
  }

  @override
  Widget createRadioListTile<T>(BuildContext context, {required String title, String? subtitle, required T value, required T groupValue, required Function(T? p1) onChanged}) {
    return RadioListTile<T>.adaptive(
      title: Text(title),
      groupValue: groupValue,
      subtitle: subtitle != null ? Text(subtitle) : null,
      value: value,
      onChanged: onChanged,
    );
  }

  @override
  Widget createSwitch(bool value, Function(bool) onChanged) {
    return CupertinoSwitch(value: value, onChanged: onChanged);
  }

  @override
  Widget createListTile({required Widget title, Widget? subtitle, Widget? leading, Widget? trailing, Function()? onTap}) {
    return CupertinoListTile(leading: leading, title: title, subtitle: subtitle, trailing: trailing, onTap: onTap);
  }

  @override
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
      InputDecoration? decoration}) {
    return CupertinoTextField(
      controller: controller,
      placeholder: hintText,
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: enabled,
      autocorrect: autocorrect,
      maxLines: maxLines,
      maxLength: maxLength,
      onChanged: onChanged,
      suffix: suffixIcon,
      prefix: prefixIcon,
      decoration: BoxDecoration(
        border: Border.all(color: CupertinoColors.lightBackgroundGray),
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  @override
  Widget createText(BuildContext context, String text, {TextStyle? style, TextDecoration? textDecoration, EdgeInsetsGeometry? padding, TextAlign? textAlign, TextOverflow? overflow, int? maxLines, Color? color}) {
    final defaultTextStyle = CupertinoTheme.of(context).textTheme.textStyle;
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Text(
        text,
        style: style?.copyWith(color: color) ?? defaultTextStyle.copyWith(color: color),
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }

  // Dialog related widgets

  @override
  Future<T?> createModalBottomSheet<T>(BuildContext context, {required Widget content, bool dismissable = true}) {
    return showCupertinoModalBottomSheet(context: context, builder: (context) => content, isDismissible: dismissable);
  }

  @override
  Future<T?> createAlertDialog<T>(BuildContext context, {String? title, Widget? titleWidget, String? content, Widget? contentWidget, required String confirmText, required String cancelText, VoidCallback? onConfirm, VoidCallback? onCancel, bool dismissable = true}) {
    return showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: titleWidget ?? Text(title ?? ''),
          content: contentWidget ?? Text(content ?? ''),
          actions: [
            CupertinoDialogAction(
              onPressed: onCancel ?? () => Navigator.of(context).pop(),
              child: Text(cancelText),
            ),
            CupertinoDialogAction(
              onPressed: onConfirm,
              child: Text(confirmText),
            )
          ],
        );
      },
    );
  }

  @override
    Widget createPageView(BuildContext context, {required int itemCount, required IndexedWidgetBuilder itemBuilder, required PageController controller, required double width, required double height, Axis? scrollDirection, ValueChanged<int>? onPageChanged}) {
      return super.createPageView(context, itemCount: itemCount, itemBuilder: itemBuilder, controller: controller, width: width, height: height);
    }
}
