import 'package:flutter/material.dart';
import 'package:imela/presentation/ui/shared/app_image.dart';
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
      // padding: const EdgeInsets.all(4),
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
                widgetFactory.createText(context, name, style: Theme.of(context).textTheme.bodySmall),
                widgetFactory.createText(context, price, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          Positioned(
            child: Align(
              alignment: Alignment.topRight,
              child: widgetFactory.createIcon(
                materialIcon: Icons.close,
                color: Colors.red,
                onPressed: () {
                  onRemove?.call();
                },
              ),
            ),
          ),
          Positioned(
            bottom: 0,right: 0,
            child: widgetFactory.createText(context, '${qty}', style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }
}
