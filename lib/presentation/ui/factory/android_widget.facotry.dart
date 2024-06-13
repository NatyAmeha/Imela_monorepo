import 'package:flutter/material.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class AndroidWidgetFactory implements WidgetFactory {
  final GlobalKey _key = GlobalKey();

  @override
  Widget createButton({required BuildContext context, required Widget content, Widget? icon, bool showLoadingIndicator = true, bool isLoading = false, Function? onPressed}) {
    if (icon != null) {
      return FilledButton.icon(
          key: _key,
          icon: (showLoadingIndicator && isLoading) ? createLoadingIndicator(context) : icon,
          label: content,
          onPressed: (onPressed == null || isLoading)
              ? null
              : () async {
                  await onPressed.call();
                });
    }
    return FilledButton(
      key: _key,
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
    return SizedBox(width: width, height: height, child: const CircularProgressIndicator());
  }

  @override
  Widget createIcon({required IconData materialIcon, IconData? cupertinoIcon, double size = 24, Color? color, String? semanticLabel}){
    return Icon(materialIcon, size: size, color: color, semanticLabel: semanticLabel);
  }

  @override
  Widget createAppbar() {
    // TODO: implement createAppbar
    throw UnimplementedError();
  }

  @override
  Widget createCheckboxListTile(BuildContext context, {required String title, String? subtitle, required bool value, required Function(bool? p1) onChanged}) {
    return CheckboxListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      value: value,
      onChanged: onChanged,
    );
  }

  @override
  Widget createDropDown<T>({required BuildContext context, required Map<T, Widget> options, T? value, required ValueChanged<T?> onChanged, double height = 200}) {
    return DropdownButton<T>(
      value: value,
      menuMaxHeight: height,
      onChanged: (value) {
        onChanged(value);
      },
      items: options.entries.map((item) {
        return DropdownMenuItem<T>(value: item.key, child: item.value);
      }).toList(),
    );
  }

  @override
  Widget createRadioListTile<T>(BuildContext context, {required String title, String? subtitle, required T value, required T groupValue, required Function(T? p1) onChanged}) {
    return RadioListTile<T>(
      title: Text(title),
      groupValue: groupValue,
      subtitle: subtitle != null ? Text(subtitle) : null,
      value: value,
      onChanged: onChanged,
    );
  }

  @override
  Widget createSwitch(bool value, Function(bool) onChanged) {
    return Switch(
      value: value,
      onChanged: onChanged,
    );
  }

  @override
  Widget createListTile({required Widget title, Widget? subtitle, Widget? leading, Widget? trailing, Function()? onTap}) {
    return ListTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: trailing,
      onTap: onTap,
    );
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
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: enabled,
      autocorrect: autocorrect,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: decoration ??
          InputDecoration(
            hintText: hintText,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
          ),
      onChanged: onChanged,
    );
  }

  // dialog related widgets

  @override
  Future<T?> createModalBottomSheet<T>(BuildContext context, {required Widget content, bool dismissable = true}) {
    return showMaterialModalBottomSheet<T>(context: context, builder: (context) => content, isDismissible: dismissable);
  }

  @override
  Future<T?> createAlertDialog<T>(BuildContext context, {String? title, Widget? titleWidget, String content = '', Widget? contentWidget, required String confirmText, required String cancelText, VoidCallback? onConfirm, VoidCallback? onCancel, bool dismissable = true}) {
    return showDialog<T>(
      context: context,
      barrierDismissible: dismissable,
      builder: (context) {
        return AlertDialog(
          title: titleWidget ?? Text(title ?? ''),
          content: contentWidget ?? Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: onCancel ?? () => Navigator.of(context).pop(),
              child: Text(cancelText),
            ),
            TextButton(
              onPressed: onConfirm ?? () => Navigator.of(context).pop(),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget createText(BuildContext context, String text, {TextStyle? style, TextDecoration? textDecoration, EdgeInsetsGeometry? padding, TextAlign? textAlign, TextOverflow? overflow, int? maxLines, Color? color}) {
    final defaultTextStyle = Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Text(text, style: style?.copyWith(color: color, decoration: textDecoration) ?? defaultTextStyle?.copyWith(color: color), textAlign: textAlign, overflow: overflow, maxLines: maxLines),
    );
  }
}
