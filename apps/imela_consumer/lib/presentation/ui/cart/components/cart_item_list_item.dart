import 'package:flutter/material.dart';
import 'package:imela/presentation/resources/colors.dart';
import 'package:imela/presentation/ui/cart/components/cart_dynamic_pricing_componenet.dart';
import 'package:imela/presentation/ui/cart/components/order_item_config.list_tile.dart';
import 'package:imela/presentation/ui/shared/app_image.dart';
import 'package:imela/presentation/ui/shared/qty_modifier.component.dart';
import 'package:imela_core/order/model/order_item.model.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class CartItemListItem extends StatelessWidget {
  final OrderItem item;
  final double width;
  final double? height;
  final WidgetFactory widgetFactory;
  final String selectedCurrency;
  final String selectedLanguage;
  final Function(double)? onQtyChange;
  final bool canRemoveItem;
  final List<DiscountInfo> appliedDiscounts;
  final Function? onRemove;
  final Function(OrderItem)? onDiscountClicked;
  final Function(Product)? onAddonProductTap;
  const CartItemListItem({
    super.key,
    required this.item,
    required this.widgetFactory,
    required this.selectedCurrency,
    this.selectedLanguage = 'ENGLISH',
    this.width = double.infinity,
    this.canRemoveItem = true,
    this.onQtyChange,
    this.onRemove,
    this.height,
    this.appliedDiscounts = const [],
    this.onDiscountClicked,
    this.onAddonProductTap,
  });

  bool get isDeductQtyDisabled => item.quantity <= (item.product?.minimumOrderQty ?? 0);
  List<Discount> get dynamicPriceDiscount => item.product?.sortedDynamicPricingDiscounts ?? [];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widgetFactory.createCard(
          padding: const EdgeInsets.all(16),
          width: width,
          // height: height,
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
                                  widgetFactory.createText(context, item.name.localize('ENGLISH'), style: Theme.of(context).textTheme.titleSmall),
                                  const SizedBox(height: 2),
                                  if (dynamicPriceDiscount.isNotEmpty) CartDynamicPricingComponenet(dynamicPricingDiscounts: dynamicPriceDiscount, selectedDynamicPriceDiscount: dynamicPriceDiscount.first, cartItem: item),
                                ],
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (item.config?.isNotEmpty == true) ...[
                widgetFactory.createCard(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  child: Column(
                    children: item.config!.map((config) {
                      return OrderItemConfigListITemTile(
                        config: config,
                        widgetFactory: widgetFactory,
                        selectedCurrency: selectedCurrency,
                        product: item.product,
                        orderAddons: item.product?.addons,
                        selectedLanguage: selectedLanguage,
                        onProductTap: (product) => onAddonProductTap?.call(product),
                      ).withPaddingSymetric(horizontal: 6, vertical: 4);
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
                      deductQtyDisabled: isDeductQtyDisabled,
                      onQtyChange: (newValue) {
                        onQtyChange?.call(newValue);
                      },
                      widgetFactory: widgetFactory,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      widgetFactory.createText(context, item.subtotalAmountString(selectedCurrency), style: Theme.of(context).textTheme.titleMedium),
                      if (item.discount?.isNotEmpty == true)
                        widgetFactory.createCard(
                          onTap: () => onDiscountClicked?.call(item),
                          child: Row(
                            children: [
                              widgetFactory.createText(context, item.getTotalDiscountAmountPOSString(currency: selectedCurrency), style: Theme.of(context).textTheme.bodySmall),
                              const SizedBox(width: 8),
                              widgetFactory.createIcon(materialIcon: Icons.keyboard_arrow_down),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        if (canRemoveItem)
          Positioned(
            right: 16,
            top: 4,
            child: widgetFactory.createButton(
              context: context,
              content: const Text('Remove'),
              style: AppButtonStyle.textButtonStyle(context, padding: const EdgeInsets.all(0), color: ColorManager.error),
              onPressed: canRemoveItem ? () => onRemove?.call() : null,
            ),
          ),
      ],
    );
  }
}
