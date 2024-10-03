import 'package:flutter/material.dart';
import 'package:imela/presentation/ui/cart/components/order_item_config.list_tile.dart';
import 'package:imela/presentation/ui/shared/list/listview.component.dart';
import 'package:imela_core/order/model/cart.model.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class CartSummary extends StatelessWidget {
  final WidgetFactory widgetFactory;
  final double width;
  final Cart cart;
  final String selectedCurrency;
  final Function? onContinue;
  final String callToActionText;
  final Function? changeOrderConfigs;
  const CartSummary({
    super.key,
    required this.cart,
    required this.widgetFactory,
    required this.selectedCurrency,
    this.width = double.infinity,
    this.callToActionText = 'Proceed to checkout',
    this.onContinue,
    this.changeOrderConfigs,
  });

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      margin: const EdgeInsets.all(16),
      elevation: 108,
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          widgetFactory.createText(context, 'Order Summary', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          if (cart.configs?.isNotEmpty == true)
            widgetFactory.createCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              color: Theme.of(context).cardColor,
              child: Stack(
                children: [
                  AppListView(
                    shrinkWrap: true,
                    items: cart.configs ?? [],
                    itemBuilder: (context, item, index) {
                      return OrderItemConfigListITemTile(config: item, widgetFactory: widgetFactory, selectedCurrency: selectedCurrency);
                    },
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: widgetFactory.createButton(
                      context: context,
                      content: const Text('Change'),
                      style: AppButtonStyle.textButtonStyle(context),
                      onPressed: () {
                        changeOrderConfigs?.call();
                      },
                    ),
                  )
                ],
              ),
            ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, 'Subtotal', style: Theme.of(context).textTheme.bodySmall),
              widgetFactory.createText(context, cart.getSubtotalFormatted('ETB'), style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, 'Taxes', style: Theme.of(context).textTheme.bodySmall),
              widgetFactory.createText(context, '${cart.getTotalTaxAmount} ETB', style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, 'Total discount', style: Theme.of(context).textTheme.bodySmall),
              widgetFactory.createText(context, '${cart.getTotalDiscountAmount} ETB', style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, 'Total', style: Theme.of(context).textTheme.titleMedium),
              widgetFactory.createText(context, '${cart.getTotalPrice} ETB', style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
          const SizedBox(height: 16),
          widgetFactory.createButton(
              context: context,
              content: Text(callToActionText),
              onPressed: () {
                onContinue?.call();
              }),
        ],
      ),
    );
  }
}
