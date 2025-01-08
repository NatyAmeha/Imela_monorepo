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
  final ScrollController? scrollController;

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
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (shrinkWrap) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (header != null) ...[
            header!,
          ],
          SizedBox(
            height: height,
            width: width,
            child: ListView.separated(
              controller: scrollController,
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
        ],
      );
    } else {
      return Expanded(
        child: ListView.separated(
          controller: scrollController,
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
      );
    }
  }
}
