import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:imela/presentation/ui/factory/widget.factory.dart';
import 'package:imela/presentation/ui/shared/app_image.dart';

class SelectedProductFromBundlListItem extends StatelessWidget {
  final String name;
  final String image;
  final String price;
  final double width;
  final double? height;
  final WidgetFactory widgetFactory;
  final Function? onRemove;
  const SelectedProductFromBundlListItem({
    super.key,
    required this.name,
    required this.image,
    required this.price,
    required this.widgetFactory,
    required this.width,
    this.height,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      borderRadius: BorderRadius.circular(6),
      padding: const EdgeInsets.all(4),
      margin: const EdgeInsets.only(right: 8),
      border: Border.all(color: Theme.of(context).colorScheme.primaryContainer, width: 1),
      width: width,
      child: Stack(
        children: [
          Positioned.fill(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppImage(imageUrl: image, borderRadius: BorderRadius.circular(6)),
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
        ],
      ),
    );
  }
}
