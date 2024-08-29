import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/shared/list/list_componenet.viewmodel.dart';

class AppGridView<T> extends StatelessWidget {
  final Axis? scrollDirection;
  final Widget? header;
  final CustomListController<T>? controller;
  final List<T> items;
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
  final double? itemExtent;
  final bool primary;
  const AppGridView({
    super.key,
    this.scrollDirection,
    this.header,
    this.controller,
    this.items = const [],
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
    this.itemExtent,
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
          if (shrinkWrap) ...[
            if (controller != null) ...[
              isStaggered
                  ? Obx(() => MasonryGridView.builder(
                        primary: primary,
                        shrinkWrap: shrinkWrap,
                        padding: padding,
                        physics: !primary ? const NeverScrollableScrollPhysics() : null,
                        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount),
                        mainAxisSpacing: mainAxisSpacing,
                        crossAxisSpacing: crossAxisSpacing,
                        itemCount: controller?.items.length ?? items.length,
                        itemBuilder: (context, index) {
                          return itemBuilder(context, controller?.items[index] ?? items[index], index);
                        },
                      ))
                  : Obx(() => GridView.builder(
                        primary: primary,
                        shrinkWrap: shrinkWrap,
                        physics: !primary ? const NeverScrollableScrollPhysics() : null,
                        scrollDirection: scrollDirection ?? Axis.vertical,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, mainAxisSpacing: mainAxisSpacing, crossAxisSpacing: crossAxisSpacing, childAspectRatio: childAspectRatio, mainAxisExtent: itemExtent),
                        itemCount: controller?.items.length ?? items.length,
                        padding: padding,
                        itemBuilder: (context, index) {
                          if (controller != null) {}
                          return itemBuilder(context, controller?.items[index] ?? items[index], index);
                        },
                      )),
            ] else ...[
              isStaggered
                  ? MasonryGridView.builder(
                      primary: primary,
                      shrinkWrap: shrinkWrap,
                      padding: padding,
                      physics: !primary ? const NeverScrollableScrollPhysics() : null,
                      gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount),
                      mainAxisSpacing: mainAxisSpacing,
                      crossAxisSpacing: crossAxisSpacing,
                      itemCount: controller?.items.length ?? items.length,
                      itemBuilder: (context, index) {
                        return itemBuilder(context, controller?.items[index] ?? items[index], index);
                      },
                    )
                  : GridView.builder(
                      primary: primary,
                      shrinkWrap: shrinkWrap,
                      physics: !primary ? const NeverScrollableScrollPhysics() : null,
                      scrollDirection: scrollDirection ?? Axis.vertical,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, mainAxisSpacing: mainAxisSpacing, crossAxisSpacing: crossAxisSpacing, childAspectRatio: childAspectRatio, mainAxisExtent: itemExtent),
                      itemCount: controller?.items.length ?? items.length,
                      padding: padding,
                      itemBuilder: (context, index) {
                        if (controller != null) {}
                        return itemBuilder(context, controller?.items[index] ?? items[index], index);
                      },
                    ),
            ],
          ] else ...[
            Expanded(
              child: controller != null
                  ? isStaggered
                      ? Obx(() => MasonryGridView.builder(
                            primary: primary,
                            shrinkWrap: shrinkWrap,
                            padding: padding,
                            physics: !primary ? const NeverScrollableScrollPhysics() : null,
                            gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount),
                            mainAxisSpacing: mainAxisSpacing,
                            crossAxisSpacing: crossAxisSpacing,
                            itemCount: controller?.items.length ?? items.length,
                            itemBuilder: (context, index) {
                              return itemBuilder(context, controller?.items[index] ?? items[index], index);
                            },
                          ))
                      : Obx(() => GridView.builder(
                            primary: primary,
                            shrinkWrap: shrinkWrap,
                            physics: !primary ? const NeverScrollableScrollPhysics() : null,
                            scrollDirection: scrollDirection ?? Axis.vertical,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, mainAxisSpacing: mainAxisSpacing, crossAxisSpacing: crossAxisSpacing, childAspectRatio: childAspectRatio, mainAxisExtent: itemExtent),
                            itemCount: controller?.items.length ?? items.length,
                            padding: padding,
                            itemBuilder: (context, index) {
                              if (controller != null) {}
                              return itemBuilder(context, controller?.items[index] ?? items[index], index);
                            },
                          ))
                  : isStaggered
                      ? MasonryGridView.builder(
                          primary: primary,
                          shrinkWrap: shrinkWrap,
                          padding: padding,
                          physics: !primary ? const NeverScrollableScrollPhysics() : null,
                          gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount),
                          mainAxisSpacing: mainAxisSpacing,
                          crossAxisSpacing: crossAxisSpacing,
                          itemCount: controller?.items.length ?? items.length,
                          itemBuilder: (context, index) {
                            return itemBuilder(context, controller?.items[index] ?? items[index], index);
                          },
                        )
                      : GridView.builder(
                          primary: primary,
                          shrinkWrap: shrinkWrap,
                          physics: !primary ? const NeverScrollableScrollPhysics() : null,
                          scrollDirection: scrollDirection ?? Axis.vertical,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, mainAxisSpacing: mainAxisSpacing, crossAxisSpacing: crossAxisSpacing, childAspectRatio: childAspectRatio, mainAxisExtent: itemExtent),
                          itemCount: controller?.items.length ?? items.length,
                          padding: padding,
                          itemBuilder: (context, index) {
                            if (controller != null) {}
                            return itemBuilder(context, controller?.items[index] ?? items[index], index);
                          },
                        ),
            ),
          ],
        ],
      ),
    );
  }
}
