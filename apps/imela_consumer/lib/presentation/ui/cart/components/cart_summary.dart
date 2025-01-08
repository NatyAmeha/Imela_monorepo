import 'package:flutter/material.dart';
import 'package:imela/presentation/resources/colors.dart';
import 'package:imela/presentation/ui/cart/components/order_item_config.list_tile.dart';
import 'package:imela/presentation/ui/shared/list/listview.component.dart';
import 'package:imela/presentation/utils/widget_extesions.dart';
import 'package:imela_core/order/model/cart.model.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class CartSummary extends StatelessWidget {
  final WidgetFactory widgetFactory;
  final double width;
  final Cart cart;
  final String selectedCurrency;
  final String selectedLanguage;
  final Function? onContinue;
  final String callToActionText;
  final Function? changeOrderConfigs;
  final Function? onViewRewards;
  final double usedLoyaltyPoints;
  final Function? onClearUsedPoints;

  const CartSummary({
    super.key,
    required this.cart,
    required this.widgetFactory,
    required this.selectedCurrency,
    required this.selectedLanguage,
    this.width = double.infinity,
    this.usedLoyaltyPoints = 0,
    this.callToActionText = 'Proceed to checkout',
    this.onContinue,
    this.changeOrderConfigs,
    this.onViewRewards,
    this.onClearUsedPoints,
  });

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      elevation: 2,
      width: width,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          widgetFactory.createText(context, 'Order Summary', style: Theme.of(context).textTheme.titleMedium),
          if (cart.configs?.isNotEmpty == true)
            Stack(
              children: [
                widgetFactory.createCard(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  margin: const EdgeInsets.only(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppListView(
                        shrinkWrap: true,
                        items: cart.configs,
                        itemBuilder: (context, item, index) {
                          return OrderItemConfigListITemTile(config: item, orderAddons: cart.orderAddons, widgetFactory: widgetFactory, selectedCurrency: selectedCurrency, selectedLanguage: selectedLanguage);
                        },
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 8,
                  child: widgetFactory.createCard(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    border: Border.all(color: Theme.of(context).colorScheme.secondary),
                    child: Row(
                      children: [
                        widgetFactory.createIcon(materialIcon: Icons.edit_outlined, color: Theme.of(context).colorScheme.secondary, size: 16),
                        const SizedBox(width: 4),
                        widgetFactory.createText(context, 'Change', style: Theme.of(context).textTheme.bodySmall, color: Theme.of(context).colorScheme.secondary),
                      ],
                    ),
                    onTap: () {
                      changeOrderConfigs?.call();
                    },
                  ),
                )
              ],
            ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, 'Subtotal', style: Theme.of(context).textTheme.bodyMedium),
              widgetFactory.createText(context, cart.getSubtotalPOSUpdatedFormatted('ETB'), style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
          if (usedLoyaltyPoints > 0)
            widgetFactory.createCard(
              color: Theme.of(context).colorScheme.primaryContainer,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.symmetric(vertical: 4),
              borderRadius: BorderRadius.zero,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widgetFactory.createText(context, 'Used points', style: Theme.of(context).textTheme.labelSmall),
                      widgetFactory.createText(context, '$usedLoyaltyPoints points', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  widgetFactory.createButton(
                    context: context,
                    content: const Text('Clear'),
                    style: AppButtonStyle.textButtonStyle(
                      context,
                      padding: const EdgeInsets.all(0),
                    ),
                    onPressed: () {
                      onClearUsedPoints?.call();
                    },
                  ),
                ],
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, 'Total discount', style: Theme.of(context).textTheme.bodyMedium),
              widgetFactory.createText(context, cart.getTotalDiscountAmountPOSFormatted(selectedCurrency), style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, 'Add-ons charges', style: Theme.of(context).textTheme.bodyMedium),
              widgetFactory.createText(context, cart.getAddonsAmountFormatted(selectedCurrency), style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, 'Total', style: Theme.of(context).textTheme.titleMedium),
              widgetFactory.createText(context, cart.getTotalAmountPOSFormatted(selectedCurrency), style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          Row(
            children: [
              Icon(Icons.loyalty_outlined, size: 16, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 4),
              widgetFactory.createText(context, cart.totalEarnedPointString(selectedLanguage), style: Theme.of(context).textTheme.bodyMedium, color: Theme.of(context).colorScheme.tertiary),
            ],
          ).withPaddingSymetric(vertical: 8),
          widgetFactory.createButton(
            context: context,
            content: Text(callToActionText),
            onPressed: () {
              onContinue?.call();
            },
          ),
        ],
      ),
    );
  }
}
