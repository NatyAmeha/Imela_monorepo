import 'package:flutter/material.dart';
import 'package:imela_core/order/model/order_config.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/components/image/app_image.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class OrderItemConfigListITemTile extends StatelessWidget {
  final WidgetFactory widgetFactory;
  final OrderConfig config;
  final String selectedCurrency;
  final Product? product;
  final String selectedLanguage;
  final List<ProductAddon>? orderAddons;
  final Function(Product)? onProductTap;
  const OrderItemConfigListITemTile({
    super.key,
    required this.config,
    required this.widgetFactory,
    required this.selectedCurrency,
    this.product,
    required this.selectedLanguage,
    this.onProductTap,
    this.orderAddons = const [],
  });

  @override
  Widget build(BuildContext context) {
    final configValue = config.selectedConfigValue(orderAddons, selectedLanguage);
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widgetFactory.createText(context, config.name.localize('ENGLISH'), style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 2),
              widgetFactory.createText(context, configValue, style: Theme.of(context).textTheme.bodySmall, color: Theme.of(context).colorScheme.secondary).showIfTrue(configValue.isNotEmpty),
              if (config.products?.isNotEmpty == true) ...[
                const SizedBox(height: 4),
                SizedBox(
                  height: 50,
                  child: Wrap(
                    spacing: 8,
                    children: config.products!.map((product) => InkWell(onTap: () => onProductTap?.call(product), child: AppImage(imageUrl: product.getImageUrl(), borderRadius: BorderRadius.circular(8), width: 40, height: 40))).toList(),
                  ),
                )
              ],
            ],
          ),
        ),
        const SizedBox(width: 16),
        widgetFactory.createText(context, config.getAdditionalPriceStringUpdated(orderAddons, selectedCurrency), style: Theme.of(context).textTheme.titleSmall).showIfTrue(config.additionalPrice > 0)
      ], 
    );
  } 
} 
