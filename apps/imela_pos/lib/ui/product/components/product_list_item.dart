import 'package:flutter/material.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/resources/colors.dart';
import 'package:imela_ui_kit/components/image/app_image.dart';

class HorizontalProductListItem extends StatelessWidget {
  final Product product;
  final Function onTap;
  final bool isSelected;
  final String selectedLanguage;
  final String currency;
  const HorizontalProductListItem({super.key, required this.product, required this.onTap, this.isSelected = false, required this.selectedLanguage, required this.currency});

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.secondaryContainer;
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    return widgetFactory.createCard(
      onTap: () => onTap(),
      padding: const EdgeInsets.all(16),
      border: Border.all(color: borderColor),
      child: Row(
        children: [
          AppImage(imageUrl: product.getImageUrl(), width: 60, height: 60),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widgetFactory.createText(context, product.name.localize(selectedLanguage), style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                widgetFactory.createText(context, product.getTotalPriceUpdatedString(currency), style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
