import 'package:flutter/material.dart';
import 'package:melegna_customer/domain/product/model/product.model.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/shared/app_image.dart';
import 'package:melegna_customer/presentation/utils/localization_utils.dart';

class ProductOptionItemComponent extends StatelessWidget {
  final Product productOption;
  final bool isOptionSelected;
  final double height;
  final double width;
  final WidgetFactory widgetFactory;
  final AppLanguage locale;
  final Function? onOptionSelected;
  const ProductOptionItemComponent({
    super.key,
    required this.productOption,
    required this.widgetFactory,
    this.height = 40,
    this.width = 250,
    this.isOptionSelected = false,
    this.locale = AppLanguage.ENGLISH,
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
            AppImage(imageUrl: productOption.getImageUrl(), width: 80, height: double.infinity, borderRadius: BorderRadius.circular(6)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  widgetFactory.createText(context, '${productOption.getLocalizedProductName(locale.name)}', style: Theme.of(context).textTheme.labelMedium),
                  widgetFactory.createText(context, '412 Birr', style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),
          ],
        ));
  }
}
