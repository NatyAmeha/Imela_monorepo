import 'package:flutter/material.dart';
import 'package:melegna_customer/domain/order/model/order_item.model.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';
import 'package:melegna_customer/presentation/resources/colors.dart';
import 'package:melegna_customer/presentation/ui/cart/components/order_item_config.list_tile.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/shared/app_image.dart';
import 'package:melegna_customer/presentation/ui/shared/qty_modifier.component.dart';

class CartItemListItem extends StatelessWidget {
  final OrderItem item;
  final WidgetFactory widgetFactory;
  final String selectedCurrency;
  const CartItemListItem({super.key, required this.item, required this.widgetFactory, required this.selectedCurrency});

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        AppImage(imageUrl: item.image, width: 100, height: 100, borderRadius: BorderRadius.circular(8)),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            widgetFactory.createText(context, item.name.localize(), style: Theme.of(context).textTheme.titleLarge),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
              widgetFactory.createIcon(materialIcon: Icons.delete, color: ColorManager.error, onPressed: () {})
            ],
          ),
          const SizedBox(height: 16),
          widgetFactory.createCard(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            child: Column(
              children: item.config!.map((config) {
                return OrderItemConfigListITemTile(config: config, widgetFactory: widgetFactory, selectedCurrency: selectedCurrency);
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              QuantityModifierComponent(
                currentQty: item.quantity,
                onQtyChange: (newValue) {},
                widgetFactory: widgetFactory,
              ), 
            ],
          ),
          widgetFactory.createText(context, item.subTotal.toString(), style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}
