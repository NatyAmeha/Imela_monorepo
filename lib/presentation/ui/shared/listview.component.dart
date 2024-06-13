import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melegna_customer/presentation/ui/shared/list.viewmodel.dart';

typedef ItemBuilder<T> = Widget Function(BuildContext context, T item, int index);

class CustomListView<T> extends StatelessWidget {
  final Axis scrollDirection;
  final Widget header;
  final CustomListController<T> controller;
  final ItemBuilder<T> itemBuilder;
  final double? width;
  final double? height;
  final bool shrinkWrap;

  const CustomListView({
    super.key,
    required this.scrollDirection,
    required this.header,
    required this.controller,
    required this.itemBuilder,
    this.width = double.infinity,
    this.height,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          header,
          Expanded(
            child: Obx(
              () => ListView.builder(
                shrinkWrap: shrinkWrap,
                scrollDirection: scrollDirection,
                itemCount: controller.items.length,
                itemBuilder: (context, index) {
                  return itemBuilder(context, controller.items[index], index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
