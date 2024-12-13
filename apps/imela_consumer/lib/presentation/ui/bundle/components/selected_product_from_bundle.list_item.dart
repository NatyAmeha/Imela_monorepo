import 'package:flutter/material.dart';
import 'package:imela/presentation/ui/shared/app_image.dart';
import 'package:imela/presentation/utils/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class SelectedProductFromBundlListItem extends StatelessWidget {
  final String name;
  final String image;
  final String price;
  final double width;
  final double? height;
  final double? qty;
  final WidgetFactory widgetFactory;
  final Function? onRemove;
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
          Positioned.fill(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppImage(imageUrl: image, borderRadius: BorderRadius.circular(6), width: double.infinity, height: 50),
                widgetFactory.createText(context, name, style: Theme.of(context).textTheme.bodyMedium, maxLines: 2).withPaddingSymetric(horizontal: 4),
                widgetFactory.createText(context, price, style: Theme.of(context).textTheme.titleSmall).withPaddingSymetric(horizontal: 4),
              ],
            ),
          ),
          Positioned(
            child: Align(
              alignment: Alignment.topRight,
              child: widgetFactory.createIcon(
                materialIcon: Icons.close,
                color: Colors.red,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                onPressed: () {
                  onRemove?.call();
                },
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 4,
            child: widgetFactory.createCard(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: widgetFactory.createText(context, 'Qty - ${qty}', style: Theme.of(context).textTheme.bodySmall),
            ),
          ),
        ],
      ),
    );
  }
}
