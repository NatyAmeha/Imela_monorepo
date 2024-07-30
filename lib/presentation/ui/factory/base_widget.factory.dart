import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:melegna_customer/presentation/resources/colors.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
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
  Widget createButton({required BuildContext context, required Widget content, Widget? icon, ButtonStyle? style, bool showLoadingIndicator = true, bool isLoading = false, Function? onPressed}) {
    // TODO: implement createButton
    throw UnimplementedError();
  }

  @override
  Widget createCard({required Widget child, EdgeInsetsGeometry? margin, EdgeInsetsGeometry? padding, double? width, double? height, Color? color, double? elevation, BorderRadius? borderRadius, List<BoxShadow>? boxShadow, Border? border, Function()? onTap}) {
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
  Widget createIcon({required IconData materialIcon, IconData? cupertinoIcon, double size = 24, Color? color, String? semanticLabel, Color? backgroundColor, EdgeInsets? padding, Function()? onPressed}) {
    // TODO: implement createIcon
    throw UnimplementedError();
  }

  @override
  Widget createListTile({required Widget title, Widget? subtitle, Widget? leading, Widget? trailing, Function()? onTap}) {
    // TODO: implement createListTile
    throw UnimplementedError();
  }

  @override
  Widget createLoadingIndicator(BuildContext context, {double? width = 20, double height = 20}) {
    // TODO: implement createLoadingIndicator
    throw UnimplementedError();
  }

  @override
  Future<T?> createModalBottomSheet<T>(BuildContext context, {required Widget content, bool dismissable = true}) {
    // TODO: implement createModalBottomSheet
    throw UnimplementedError();
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
      child: enableResize ? AutoSizeText(text, style: style?.copyWith(color: color), textAlign: textAlign, maxLines: maxLines, overflow: overflow, minFontSize: 10) : Text(text, style: style?.copyWith(color: color), textAlign: textAlign, maxLines: maxLines, overflow: overflow),
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

  Widget createPageView(BuildContext context, {required int itemCount, required IndexedWidgetBuilder itemBuilder, required PageController controller, required double width, required double height, Axis? scrollDirection, ValueChanged<int>? onPageChanged}) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned.fill(child: PageView.builder(itemBuilder: itemBuilder, itemCount: itemCount, controller: controller, scrollDirection: scrollDirection = Axis.horizontal, onPageChanged: onPageChanged)),
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
                  radius: 16,
                  dotWidth: 8,
                  dotHeight: 8,
                  dotColor: ColorManager.accent1,
                  activeDotColor: Theme.of(context).colorScheme.primary,
                  paintStyle: PaintingStyle.fill,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
