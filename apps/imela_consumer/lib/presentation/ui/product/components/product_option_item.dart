import 'package:flutter/material.dart';
import 'package:imela/presentation/ui/shared/app_image.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/currency_utils.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class ProductOptionItemComponent extends StatelessWidget {
  final Product productOption;
  final bool isOptionSelected;
  final double height;
  final double width;
  final WidgetFactory widgetFactory;
  final Function? onOptionSelected;
  const ProductOptionItemComponent({
    super.key,
    required this.productOption,
    required this.widgetFactory,
    this.height = 40,
    this.width = 250,
    this.isOptionSelected = false,
    this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
        onTap: () {
          onOptionSelected?.call();
        },
        border: Border.all(color: isOptionSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primaryContainer, width: 2),
        borderRadius: BorderRadius.circular(8),
        width: width,
        height: 20,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppImage(imageUrl: productOption.getImageUrl(), width: 75, height: double.infinity, borderRadius: BorderRadius.circular(6)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  widgetFactory.createText(context, productOption.name.localize('ENGLISH'), style: Theme.of(context).textTheme.labelMedium),
                  widgetFactory.createText(context, productOption.getPrice().toSelectedPriceString('ETB'), style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),
          ],
        ));
  }
}
