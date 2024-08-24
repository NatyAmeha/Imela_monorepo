import 'package:flutter/material.dart';
import 'package:melegna_customer/presentation/resources/colors.dart';
import 'package:melegna_customer/presentation/ui/factory/base_widget.factory.dart';
import 'package:melegna_customer/presentation/utils/button_style.dart';

class AndroidWidgetFactory extends BaseWidgetFactory {
  final GlobalKey _key = GlobalKey();

  @override
  Widget createButton({required BuildContext context, required Widget content, Widget? icon, Key? key, ButtonStyle? style, bool showLoadingIndicator = true, bool isLoading = false, Function? onPressed}) {
    if (icon != null) {
      return FilledButton.icon(
        key: key,
        icon: (showLoadingIndicator && isLoading) ? createLoadingIndicator(context) : icon,
        label: content,
        style: style ?? AppButtonStyle.filledbuttonStyle(),
        onPressed: (onPressed == null || isLoading)
            ? null
            : () async {
                await onPressed.call();
              },
      );
    }
    return FilledButton(
      key: key,
      style: style ?? AppButtonStyle.filledbuttonStyle(),
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
  Widget createCard({required Widget child, EdgeInsetsGeometry? margin, EdgeInsetsGeometry? padding, double? width, double? height, Color? color, double? elevation, BorderRadius? borderRadius, List<BoxShadow>? boxShadow, Border? border, Gradient? gradient, Function()? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: padding,
        margin: margin,
        width: width,
        height: height,
        
        decoration: BoxDecoration(color: color, border: border, borderRadius: borderRadius ?? BorderRadius.circular(8.0), boxShadow: boxShadow, gradient: gradient),
        child: child,
      ),
    );
  }

  @override
  Widget createLoadingIndicator(BuildContext context, {double? width = 20, double height = 20}) {
    return createCard(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: ColorManager.primaryBackground, width: 1),
      color: Colors.grey[100],
      padding: const EdgeInsets.all(12),
      width: 60,
      height: 60,
      child: SizedBox(width: width, height: height, child: const CircularProgressIndicator()),
    );
  }

  @override
  Widget createIcon({required IconData materialIcon, IconData? cupertinoIcon, double size = 24, Color? color, String? semanticLabel, Color? backgroundColor, EdgeInsets? padding, Function()? onPressed, bool showIconOnly = true}) {
    var decoration = backgroundColor != null ? BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(50)) : null;
    Icon iconWidget = Icon(materialIcon, size: size, color: color, semanticLabel: semanticLabel);
    if (backgroundColor != null) {
      return Container(padding: padding, decoration: decoration, child: showIconOnly ? iconWidget : IconButton(onPressed: onPressed, icon: iconWidget, padding: padding));
    }
    if (onPressed == null && showIconOnly) {
      return iconWidget;
    }
    return IconButton(onPressed: onPressed, icon: iconWidget, padding: padding ?? const EdgeInsets.all(0));
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
      int? maxLength,
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
  Future<T?> createModalBottomSheet<T>(BuildContext context, {required Widget Function(ScrollController) content, bool dismissable = true, double initialHeight = 0.5, double minHeight = 0, double? maxHeight = 1.0, BorderRadius? borderRadius}) {
    return super.createModalBottomSheet(context, content: content, dismissable: dismissable, initialHeight: initialHeight, minHeight: minHeight, maxHeight: maxHeight, borderRadius: borderRadius);
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
  Widget createText(BuildContext context, String text, {TextStyle? style, TextDecoration? textDecoration, EdgeInsetsGeometry? padding, TextAlign? textAlign, TextOverflow? overflow, int? maxLines, Color? color, bool enableResize = false}) {
    final defaultTextStyle = Theme.of(context).textTheme.bodyMedium;
    return super.createText(context, text, style: style ?? defaultTextStyle, textDecoration: textDecoration, padding: padding, textAlign: textAlign, overflow: overflow, maxLines: maxLines, color: color, enableResize: enableResize);
  }

  @override
  Widget createPageView(BuildContext context, {required int itemCount, required IndexedWidgetBuilder itemBuilder, required PageController controller, required double width, required double height, Axis? scrollDirection, ValueChanged<int>? onPageChanged}) {
    return super.createPageView(context, itemCount: itemCount, itemBuilder: itemBuilder, controller: controller, width: width, height: height);
  }

  @override
  Future<DateTime?> showDateTimePicker(BuildContext context, DateTime? initialDate, DateTime? firstDate, DateTime? lastDate, String? confirmText, String? cancelText, bool dismissable) async {
    var pickedDate = await showDatePicker(context: context, initialDate: initialDate ?? DateTime.now(), firstDate: firstDate ?? DateTime(2000), lastDate: lastDate ?? DateTime(2100), confirmText: confirmText, cancelText: cancelText);
    if (pickedDate == null) return null;
    final pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(pickedDate));
    if (pickedTime == null) return null;
    pickedDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
    return pickedDate;
  }

  @override
  Future<DateTimeRange?> showDateRangePickerUI(BuildContext context, {DateTimeRange? initialDateRange, DateTime? firstDate, DateTime? lastDate, String? confirmText, String? cancelText, bool dismissable = true}) async {
    return await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange ?? DateTimeRange(start: DateTime.now(), end: DateTime.now().add(const Duration(days: 1))),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
      confirmText: confirmText,
      cancelText: cancelText,
    );
  }
}
