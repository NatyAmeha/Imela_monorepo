import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'list_componenet.viewmodel.dart';

class AppListView<T> extends StatelessWidget {
  final Axis scrollDirection;
  final Widget? header;
  final CustomListController<T>? controller;
  final List<T>? items;
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
    this.controller,
    this.items,
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null) ...[
          header!,
        ],
        if (shrinkWrap) ...[
          SizedBox(
            height: height,
            width: width,
            child: ListView.separated(
              shrinkWrap: shrinkWrap,
              primary: primary,
              physics: !primary ? const NeverScrollableScrollPhysics() : null,
              scrollDirection: scrollDirection,
              padding: padding,
              itemCount: controller?.items.length ?? items!.length,
              separatorBuilder: (context, index) => separator,
              itemBuilder: (context, index) {
                return Padding(
                  padding: contentPadding,
                  child: itemBuilder(context, controller?.items.elementAt(index) ?? items![index], index),
                );
              },
            ),
          ),
        ] else ...[
          Expanded(
            child: Obx(
              () => ListView.separated(
                primary: primary,
                physics: !primary ? const NeverScrollableScrollPhysics() : null,
                scrollDirection: scrollDirection,
                padding: padding,
                itemCount: controller?.items.length ?? items!.length,
                separatorBuilder: (context, index) => separator,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: contentPadding,
                    child: itemBuilder(context, controller?.items.elementAt(index) ?? items![index], index),
                  );
                },
              ),
            ),
          ),
        ]
      ],
    );
  }
}
