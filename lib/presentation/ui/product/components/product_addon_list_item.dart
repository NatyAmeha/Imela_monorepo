import 'package:flutter/material.dart';
import 'package:melegna_customer/domain/product/model/product_addon.model.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/shared/qty_modifier.component.dart';
import 'package:melegna_customer/presentation/utils/localization_utils.dart';

class ProductAddonListItem extends StatelessWidget {
  final ProductAddon addon;
  final WidgetFactory widgetFactory;
  final AppLanguage locale;
  const ProductAddonListItem({super.key, required this.addon, this.locale = AppLanguage.ENGLISH, required this.widgetFactory});

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                widgetFactory.createText(context, addon.name.localize(), style: Theme.of(context).textTheme.bodyMedium),
                if (addon.description != null) widgetFactory.createText(context, addon.description.localize() * 3, style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              widgetFactory.createText(context, '40 Birr', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              QuantityModifierComponent(
                  currentQty: addon.minQty,
                  widgetFactory: widgetFactory,
                  onQtyChange: (value) {
                    print(value);
                  }),
            ],
          )
        ],
      ),
    );
  }
}
