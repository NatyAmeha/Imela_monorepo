import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/shared/app_image.dart';
import 'package:imela/presentation/utils/widget_extesions.dart';
import 'package:imela_core/order/model/order_item.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela/l10n/l10n.dart';

class SelectedProductFromBundlListItem extends StatelessWidget {
  final String name;
  final String image;
  final String price;
  final double width;
  final double? height;
  final double? qty;
  final WidgetFactory widgetFactory;
  final Function? onRemove;
  final double imageWidth;
  final double imageHeight;
  final List<OrderItem> additionalItems;
  const SelectedProductFromBundlListItem({
    super.key,
    required this.name,
    required this.image,
    required this.price,
    required this.widgetFactory,
    required this.width,
    this.qty = 1.0,
    this.height,
    this.onRemove,
    this.imageWidth = 100,
    this.imageHeight = 120,
    this.additionalItems = const [],
  });

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      borderRadius: BorderRadius.circular(6),
      margin: const EdgeInsets.only(right: 8),
      border: Border.all(color: Theme.of(context).colorScheme.primaryContainer, width: 1),
      width: width,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppImage(imageUrl: image, borderRadius: BorderRadius.circular(6), width: imageWidth, height: imageHeight),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        widgetFactory.createText(context, name, style: Theme.of(context).textTheme.labelLarge, maxLines: 2).withPaddingSymetric(horizontal: 4),
                        widgetFactory.createText(context, price, style: Theme.of(context).textTheme.titleSmall).withPaddingSymetric(horizontal: 4),
                        const SizedBox(height: 8),
                        widgetFactory.createCard(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: widgetFactory.createText(context, context.l10n.quantity('$qty'), style: Theme.of(context).textTheme.bodyMedium),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ).withPaddingSymetric(vertical: 4),
                  ),
                ],
              ),
              if (additionalItems.isNotEmpty) ...[
                const Divider(),
                AppListView(
                  header: widgetFactory.createText(context, context.l10n.additionalItems, style: Theme.of(context).textTheme.bodyMedium).paddingSymmetric(horizontal: 8),
                  items: additionalItems,
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  scrollDirection: Axis.horizontal,
                  width: double.infinity,
                  height: 45,
                  itemBuilder: (context, item, index) {
                    return AppImage(imageUrl: item.image, borderRadius: BorderRadius.circular(6), width: 45, height: 40);
                  },
                ),
              ],
            ],
          ),
          Positioned(
            child: Align(
              alignment: Alignment.topRight,
              child: widgetFactory.createIcon(
                materialIcon: Icons.close,
                color: Colors.red,
                size: 24,
                // backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                onPressed: () {
                  onRemove?.call();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
