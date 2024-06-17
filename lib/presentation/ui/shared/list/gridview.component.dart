import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:melegna_customer/presentation/ui/shared/list/list_componenet.viewmodel.dart';

class AppGridView<T> extends StatelessWidget {
  final Axis? scrollDirection;
  final Widget? header;
  final CustomListController<T> controller;
  final ItemBuilder<T> itemBuilder;
  final bool isStaggered;
  final double? width;
  final double? height;
  final bool shrinkWrap;
  final EdgeInsetsGeometry padding;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final bool primary;
  const AppGridView({
    super.key,
    this.scrollDirection,
    this.header,
    required this.controller,
    required this.itemBuilder,
    this.width = double.infinity,
    this.height,
    this.shrinkWrap = false,
    this.isStaggered = false,
    this.padding = const EdgeInsets.all(0),
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 12,
    this.crossAxisSpacing = 10,
    this.childAspectRatio = 1.0,
    this.primary = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (header != null) ...[
            header!,
            const SizedBox(height: 16),
          ],
          Expanded(
            child: isStaggered
                ? Obx(
                    () => MasonryGridView.builder(
                      primary: primary,
                      padding: EdgeInsets.zero,
                      physics: !primary ? const NeverScrollableScrollPhysics() : null,
                      gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount),
                      mainAxisSpacing: mainAxisSpacing,
                      crossAxisSpacing: crossAxisSpacing,
                      itemCount: controller.items.length,
                      itemBuilder: (context, index) {
                        return itemBuilder(context, controller.items[index], index);
                      },
                    ),
                  )
                : Obx(
                    () => GridView.builder(
                      primary: primary,
                       physics: !primary ? const NeverScrollableScrollPhysics() : null,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: mainAxisSpacing,
                        crossAxisSpacing: crossAxisSpacing,
                        childAspectRatio: childAspectRatio,
                      ),
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
