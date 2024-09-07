import 'package:flutter/material.dart';
import 'package:imela_core/business/model/payment_option.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class PaymentOptionListItem extends StatelessWidget {
  final double totalAmount;
  final PaymentOption paymentOption;
  final String selectedPaymentOptionId;
  final WidgetFactory widgetFactory;
  final double width;
  final double? height;
  final Function? onSelected;
  const PaymentOptionListItem({
    super.key,
    required this.totalAmount,
    required this.paymentOption,
    required this.selectedPaymentOptionId,
    required this.widgetFactory,
    this.width = double.infinity,
    this.height,
    this.onSelected,
  });

  bool get isSelected => paymentOption.id == selectedPaymentOptionId;

  IconData get icon {
    return isSelected ? Icons.check_circle : Icons.radio_button_unchecked;
  }



  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      onTap: () {
        onSelected?.call();
      },
      padding: const EdgeInsets.all(16),
      border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primaryContainer, width: 1),
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widgetFactory.createText(context, paymentOption.name.localize('ENGLISH'), style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ),
              widgetFactory.createIcon(materialIcon: icon, color: Colors.green),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, 'Current payment', style: Theme.of(context).textTheme.labelMedium),
              widgetFactory.createText(context, paymentOption.currentPayment(totalAmount).toString(), style: Theme.of(context).textTheme.bodyLarge, color: Theme.of(context).colorScheme.primary),
            ],
          ).withPaddingSymetric(vertical: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, 'Remaining amount', style: Theme.of(context).textTheme.labelMedium),
              widgetFactory.createText(context, paymentOption.remainingPayment(totalAmount).toString(), style: Theme.of(context).textTheme.bodyLarge, color: Theme.of(context).colorScheme.primary),
            ],
          ).withPaddingSymetric(vertical: 2).showIfTrue(paymentOption.isPartialPaymentOption()),
          Row(
            children: [
              widgetFactory.createText(context, 'Pay remaining on delivery', style: Theme.of(context).textTheme.labelMedium, color: Theme.of(context).colorScheme.tertiary),
            ],
          ).withPaddingSymetric(vertical: 2).showIfTrue(paymentOption.isPartialPaymentOption())
        ],
      ),
    );
  }
}
