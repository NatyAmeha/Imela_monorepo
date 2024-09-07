import 'package:auto_size_text/auto_size_text.dart';
import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';


class BaseWidgetFactory implements WidgetFactory {
  @override
  Future<T?> createAlertDialog<T>(BuildContext context, {String? title, Widget? titleWidget, String content = '', Widget? contentWidget, required String confirmText, required String cancelText, VoidCallback? onConfirm, VoidCallback? onCancel, bool dismissable = true}) {
    // TODO: implement createAlertDialog
    throw UnimplementedError();
  }

  @override
  Widget createAppbar() {
    // TODO: implement createAppbar
    throw UnimplementedError();
  }

  @override
  Widget createButton({required BuildContext context, required Widget content, Widget? icon, Key? key, ButtonStyle? style, bool showLoadingIndicator = true, bool isLoading = false, Function? onPressed}) {
    // TODO: implement createButton
    throw UnimplementedError();
  }

  @override
  Widget createCard({required Widget child, EdgeInsetsGeometry? margin, EdgeInsetsGeometry? padding, double? width, double? height, Color? color, double? elevation, BorderRadius? borderRadius, List<BoxShadow>? boxShadow, Border? border, Gradient? gradient, Function()? onTap}) {
    // TODO: implement createCard
    throw UnimplementedError();
  }

  @override
  Widget createCheckboxListTile(BuildContext context, {required String title, String? subtitle, required bool value, required Function(bool? p1) onChanged}) {
    // TODO: implement createCheckboxListTile
    throw UnimplementedError();
  }

  @override
  Widget createDropDown<T>({required BuildContext context, required Map<T, Widget> options, T? value, required ValueChanged<T?> onChanged, double height = 200}) {
    // TODO: implement createDropDown
    throw UnimplementedError();
  }

  @override
  Widget createIcon({required IconData materialIcon, IconData? cupertinoIcon, double size = 24, Color? color, String? semanticLabel, Color? backgroundColor, EdgeInsets? padding, Function()? onPressed, bool showIconOnly = true}) {
    // TODO: implement createIcon
    throw UnimplementedError();
  }

  @override
  Widget createListTile({required Widget title, Widget? subtitle, Widget? leading, Widget? trailing, Function()? onTap}) {
    // TODO: implement createListTile
    throw UnimplementedError();
  }

  @override
  Widget createLoadingIndicator(BuildContext context, {Color? color, double? width = 20, double height = 20}) {
    // TODO: implement createLoadingIndicator
    throw UnimplementedError();
  }

  @override
  Future<T?> createModalBottomSheet<T>(BuildContext context, {required Widget Function(ScrollController) content, bool dismissable = true, double initialHeight = 0.5, double minHeight = 0, double? maxHeight = 1.0, BorderRadius? borderRadius}) {
    return showFlexibleBottomSheet(
        context: context, builder: (context, controller, _) => content(controller), minHeight: minHeight, initHeight: initialHeight, maxHeight: maxHeight, isSafeArea: true, isDismissible: dismissable, anchors: [0, (maxHeight! - 0.01), (maxHeight)], bottomSheetBorderRadius: borderRadius ?? BorderRadius.circular(16), isModal: true);
  }

  @override
  Widget createRadioListTile<T>(BuildContext context, {required String title, String? subtitle, required T value, required T groupValue, required Function(T? p1) onChanged}) {
    // TODO: implement createRadioListTile
    throw UnimplementedError();
  }

  @override
  Widget createSwitch(bool value, Function(bool p1) onChanged) {
    // TODO: implement createSwitch
    throw UnimplementedError();
  }

  @override
  Widget createText(BuildContext context, String text, {TextStyle? style, TextDecoration? textDecoration, EdgeInsetsGeometry? padding, TextAlign? textAlign, TextOverflow? overflow, int? maxLines, Color? color, bool enableResize = false}) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: enableResize ? AutoSizeText(text, style: style?.copyWith(color: color, decoration: textDecoration), textAlign: textAlign, maxLines: maxLines, overflow: overflow, minFontSize: 10) : Text(text, style: style?.copyWith(color: color, decoration: textDecoration), textAlign: textAlign, maxLines: maxLines, overflow: overflow),
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
      String? Function(String? p1)? validator,
      void Function(String p1)? onChanged,
      Widget? suffixIcon,
      Widget? prefixIcon,
      InputDecoration? decoration}) {
    // TODO: implement createTextField
    throw UnimplementedError();
  }

  @override
  Widget createPageView(BuildContext context, {required int itemCount, required IndexedWidgetBuilder itemBuilder, required PageController controller, required double width, required double height, Axis? scrollDirection, ValueChanged<int>? onPageChanged}) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              itemBuilder: itemBuilder,
              itemCount: itemCount,
              controller: controller,
              scrollDirection: scrollDirection = Axis.horizontal,
              onPageChanged: onPageChanged,
            ),
          ),
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Align(
              alignment: const AlignmentDirectional(0, 1),
              child: SmoothPageIndicator(
                controller: controller,
                count: itemCount,
                effect: ExpandingDotsEffect(
                  expansionFactor: 3,
                  spacing: 6,
                  dotWidth: 8,
                  dotHeight: 8,
                  dotColor: Theme.of(context).colorScheme.secondary,
                  activeDotColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Future<DateTime?> showDateTimePicker(BuildContext context, DateTime? initialDate, DateTime? firstDate, DateTime? lastDate, String? confirmText, String? cancelText, bool dismissable) {
    throw UnimplementedError();
  }

  @override
  Future<DateTimeRange?> showDateRangePickerUI(BuildContext context, {DateTimeRange? initialDateRange, DateTime? firstDate, DateTime? lastDate, String? confirmText, String? cancelText, bool dismissable = true}) async {
    throw UnimplementedError();
  }

  Future<void> showFlashMessage(BuildContext context, {required String message, IconData? icon, EdgeInsets? margin, Color? backgroundColor, Color? textColor, int durationInSecond = 4, bool isPersistent = false, String? actionText, ToastPosition position = ToastPosition.bottom, Function? onActinClicked}) async {
    FlashController<Object?>? flashController;
    showFlash(
      context: context,
      duration: isPersistent ? null : Duration(seconds: durationInSecond),
      builder: (context, controller) {
        flashController = controller;
        return FlashBar(
          controller: controller,
          backgroundColor: backgroundColor,
          position: position == ToastPosition.top ? FlashPosition.top : FlashPosition.bottom,
          behavior: FlashBehavior.floating,
          padding: const EdgeInsets.symmetric(vertical: 8),
          margin: margin ?? const EdgeInsets.all(0),
          icon: Icon(icon ?? Icons.info, color: textColor),
          content: Row(
            children: [
              Expanded(child: Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor))),
              createButton(
                context: context,
                content: Text(actionText ?? 'OK'),
                style: AppButtonStyle.textButtonStyle(context, padding: EdgeInsets.zero),
                onPressed: () {
                  onActinClicked?.call();
                  controller.dismiss();
                },
              ).showIfTrue(actionText != null)
            ],
          ),
          actions: null,
        );
      },
    );
  }
}
