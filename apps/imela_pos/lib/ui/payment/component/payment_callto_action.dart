import 'package:flutter/material.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class PaymentCallToAction extends StatelessWidget {
  final WidgetFactory widgetFactory;
  final String totalPaidAmount;
  final String remainingAmount;
  final bool canEnablePlaceOrder;
  final Function() onPlaceOrderPressed;
  const PaymentCallToAction({
    super.key,
    required this.widgetFactory,
    required this.totalPaidAmount,
    required this.remainingAmount,
    required this.canEnablePlaceOrder,
    required this.onPlaceOrderPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            widgetFactory.createText(context, 'Paid Amount', style: Theme.of(context).textTheme.titleSmall),
            widgetFactory.createText(context, totalPaidAmount, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            widgetFactory.createText(context, 'Remaining Amount', style: Theme.of(context).textTheme.titleSmall),
            widgetFactory.createText(context, remainingAmount, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 16),
        widgetFactory.createButton(
          context: context,
          content: const Text('Place Order'),
          onPressed: canEnablePlaceOrder
              ? () {
                  onPlaceOrderPressed();
                }
              : null,
        ),
      ],
    );
  }
}
