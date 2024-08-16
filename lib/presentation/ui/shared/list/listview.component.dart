import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melegna_customer/presentation/ui/shared/list/list_componenet.viewmodel.dart';

class AppListView<T> extends StatelessWidget {
  final Axis scrollDirection;
  final Widget? header;
  final CustomListController<T> controller;
  final ItemBuilder<T> itemBuilder;
  final double? width;
  final double? height;
  final bool shrinkWrap;
  final Widget separator;
  final bool primary;

  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry contentPadding;

  const AppListView({
    super.key,
    this.scrollDirection = Axis.vertical,
    this.header,
    required this.controller,
    required this.itemBuilder,
    this.width = double.infinity,
    this.height,
    this.shrinkWrap = false,
    this.separator = const SizedBox(),
    this.primary = true,
    this.padding = const EdgeInsets.all(0),
    this.contentPadding = const EdgeInsets.all(0),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null) ...[
            header!,
          ],
          Expanded(
            child: Obx(
              () => ListView.separated(
                shrinkWrap: shrinkWrap,
                primary: primary,
                physics: !primary ? const NeverScrollableScrollPhysics() : null,
                scrollDirection: scrollDirection,
                padding: padding,
                itemCount: controller.items.length,
                separatorBuilder: (context, index) => separator,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: contentPadding,
                    child: itemBuilder(context, controller.items[index], index),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
