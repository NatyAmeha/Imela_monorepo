import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:imela/presentation/ui/factory/base_widget.factory.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class IosWidgetFactory extends BaseWidgetFactory {
  @override
  Widget createButton({required BuildContext context, required Widget content, Widget? icon, Key? key, ButtonStyle? style, bool showLoadingIndicator = true, bool isLoading = false, Function? onPressed}) {
    return CupertinoButton.filled(
      key: key,
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
  Widget createCard({required Widget child, EdgeInsetsGeometry? margin, EdgeInsetsGeometry? padding, double? width, double? height, Color? color, double? elevation, BorderRadius? borderRadius, List<BoxShadow>? boxShadow, final Border? border, Gradient? gradient, Function()? onTap}) {
    return GestureDetector(
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
    return SizedBox(width: width, height: height, child: const CupertinoActivityIndicator());
  }

  @override
  Widget createIcon({required IconData materialIcon, IconData? cupertinoIcon, double size = 24, Color? color, String? semanticLabel, Color? backgroundColor, EdgeInsets? padding, Function()? onPressed, bool showIconOnly = true}) {
    var decoration = backgroundColor != null ? BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(50)) : null;
    Icon iconWidget = Icon(cupertinoIcon ?? materialIcon, size: size, color: color, semanticLabel: semanticLabel);

    if (backgroundColor != null) {
      return Container(padding: padding, decoration: decoration, child: showIconOnly ? iconWidget : IconButton(onPressed: onPressed, icon: iconWidget, padding: padding));
    }
    if (showIconOnly) {
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
  Widget createText(BuildContext context, String text, {TextStyle? style, TextDecoration? textDecoration, EdgeInsetsGeometry? padding, TextAlign? textAlign, TextOverflow? overflow, int? maxLines, Color? color, bool enableResize = false}) {
    final defaultTextStyle = CupertinoTheme.of(context).textTheme.textStyle.copyWith(color: color);
    return super.createText(context, text, style: style ?? defaultTextStyle, textDecoration: textDecoration, padding: padding, textAlign: textAlign, overflow: overflow, maxLines: maxLines, color: color, enableResize: enableResize);
  }

  // Dialog related widgets

  @override
  Future<T?> createModalBottomSheet<T>(BuildContext context, {required Widget Function(ScrollController) content, bool dismissable = true, double initialHeight = 0.5, double minHeight = 0, double? maxHeight = 1.0, BorderRadius? borderRadius}) {
    return super.createModalBottomSheet(context, content: content, dismissable: dismissable, initialHeight: initialHeight, minHeight: minHeight, maxHeight: maxHeight, borderRadius: borderRadius);
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

  @override
  Future<DateTime?> showDateTimePicker(BuildContext context, DateTime? initialDate, DateTime? firstDate, DateTime? lastDate, String? confirmText, String? cancelText, bool dismissable) async {
    DateTime? pickedDate;
    await showCupertinoModalBottomSheet<DateTime>(
      context: context,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.sizeOf(context).height / 3,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.dateAndTime,
            initialDateTime: initialDate ?? DateTime.now(),
            minimumDate: firstDate,
            maximumDate: lastDate,
            onDateTimeChanged: (DateTime value) {
              pickedDate = value;
            },
          ),
        );
      },
    );
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
