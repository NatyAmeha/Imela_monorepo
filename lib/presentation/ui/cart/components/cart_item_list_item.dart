import 'package:flutter/material.dart';
import 'package:imela/domain/order/model/order_item.model.dart';
import 'package:imela/domain/shared/localized_field.model.dart';
import 'package:imela/presentation/resources/colors.dart';
import 'package:imela/presentation/ui/cart/components/order_item_config.list_tile.dart';
import 'package:imela/presentation/ui/factory/widget.factory.dart';
import 'package:imela/presentation/ui/shared/app_image.dart';
import 'package:imela/presentation/ui/shared/qty_modifier.component.dart';
import 'package:imela/presentation/utils/button_style.dart';
import 'package:imela/presentation/utils/widget_extesions.dart';

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
            crossAxisAlignment: CrossAxisAlignment.start,
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
              widgetFactory.createButton(
                context: context,
                content: const Text('Remove'),
                style: AppButtonStyle.textButtonStyle(context, padding: const EdgeInsets.all(0), color: ColorManager.error),
                onPressed: () {
                  onRemove?.call();
                },
              )
            ],
          ),
          const SizedBox(height: 8),
          if (item.config?.isNotEmpty == true) ...[
            widgetFactory.createCard(
              color: Theme.of(context).colorScheme.primaryContainer,
              // borderRadius: BorderRadius.zero,
              padding: const EdgeInsets.all(8),
              child: Column(
                children: item.config!.map((config) {
                  return OrderItemConfigListITemTile(config: config, widgetFactory: widgetFactory, selectedCurrency: selectedCurrency).withPaddingSymetric(horizontal: 6, vertical: 4);
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 150,
                child: QuantityModifierComponent(
                  currentQty: item.quantity,
                  onQtyChange: (newValue) {
                    onQtyChange?.call(newValue);
                  },
                  widgetFactory: widgetFactory,
                ),
              ),
              widgetFactory.createText(context, item.getTotalAmount.toString(), style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ],
      ),
    );
  }
}
