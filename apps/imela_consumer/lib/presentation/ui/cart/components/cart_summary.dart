import 'package:flutter/material.dart';
import 'package:imela_core/order/model/cart.model.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class CartSummary extends StatelessWidget {
  final WidgetFactory widgetFactory;
  final double width;
  final Cart cart;
  final Function? onContinue;
  const CartSummary({
    super.key,
    required this.cart,
    required this.widgetFactory,
    this.width = double.infinity,
    this.onContinue,
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
          widgetFactory.createText(context, 'Price breakdown', style: Theme.of(context).textTheme.labelMedium),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, 'Subtotal', style: Theme.of(context).textTheme.bodySmall),
              widgetFactory.createText(context, '${cart.getSubtotal} ETB', style: Theme.of(context).textTheme.bodyLarge),
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
          widgetFactory.createButton(context: context, content: Text('Proceed to checkout'), onPressed: () {
            onContinue?.call();
          }),
        ],
      ),
    );
  }
}
