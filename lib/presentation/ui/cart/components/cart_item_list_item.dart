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
  final double width;
  final double? height;
  final WidgetFactory widgetFactory;
  final String selectedCurrency;
  final Function(double)? onQtyChange;
  final Function? onRemove;
  const CartItemListItem({
    super.key,
    required this.item,
    required this.widgetFactory,
    required this.selectedCurrency,
    this.width = double.infinity,
    this.onQtyChange,
    this.onRemove,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      padding: const EdgeInsets.all(16),
      width: width,
      height: height,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppImage(imageUrl: item.image, width: 50, height: 50, borderRadius: BorderRadius.circular(8)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              widgetFactory.createText(context, item.name.localize(), style: Theme.of(context).textTheme.titleSmall),
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              widgetFactory.createIcon(materialIcon: Icons.delete, color: ColorManager.error, onPressed: () {
                 onRemove?.call();
              })
            ],
          ),
          const SizedBox(height: 16),
          if (item.config?.isNotEmpty == true)
            widgetFactory.createCard(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              child: Column(
                children: item.config!.map((config) {
                  return OrderItemConfigListITemTile(config: config, widgetFactory: widgetFactory, selectedCurrency: selectedCurrency);
                }).toList(),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: QuantityModifierComponent(
                  currentQty: item.quantity,
                  onQtyChange: (newValue) {
                    onQtyChange?.call(newValue);
                  },
                  widgetFactory: widgetFactory,
                ),
              ),
              const Spacer(),
              widgetFactory.createText(context, item.getTotalAmount.toString(), style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ],
      ),
    );
  }
}
