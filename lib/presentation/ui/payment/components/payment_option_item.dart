import 'package:flutter/material.dart';
import 'package:melegna_customer/domain/business/model/payment_option.model.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/utils/widget_extesions.dart';

class PaymentOptionListItem extends StatelessWidget {
  final PaymentOption paymentOption;
  final String selectedPaymentOptionId;
  final WidgetFactory widgetFactory;
  final double width;
  final double? height;
  final Function? onSelected;
  const PaymentOptionListItem({
    super.key,
    required this.paymentOption,
    required this.selectedPaymentOptionId,
    required this.widgetFactory,
    this.width = double.infinity,
    this.height,
    this.onSelected,
  });

  IconData get icon {
    return paymentOption.id == selectedPaymentOptionId ? Icons.check_circle : Icons.radio_button_unchecked;
  }

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      onTap: () {
        onSelected?.call();
      },
      padding: const EdgeInsets.all(16),
      border: Border.all(color: Theme.of(context).colorScheme.primaryContainer, width: 1),
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
                    widgetFactory.createText(context, paymentOption.name.localize(), style: Theme.of(context).textTheme.titleLarge),
                    widgetFactory.createText(context, paymentOption.type.toString(), style: Theme.of(context).textTheme.bodyMedium),
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
              widgetFactory.createText(context, "Current payment", style: Theme.of(context).textTheme.bodyMedium),
              widgetFactory.createText(context, "130 Birr", style: Theme.of(context).textTheme.bodyLarge, color: Theme.of(context).colorScheme.primary),
            ],
          ).withPaddingSymetric(vertical: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, "Remaining amount", style: Theme.of(context).textTheme.bodyMedium),
              widgetFactory.createText(context, "400 Birr", style: Theme.of(context).textTheme.bodyLarge, color: Theme.of(context).colorScheme.primary),
            ],
          ).withPaddingSymetric(vertical: 4),
          Row(
            children: [
              widgetFactory.createIcon(materialIcon: Icons.read_more_outlined),
              const SizedBox(width: 8),
              widgetFactory.createText(context, "Pay remaining on delivery", style: Theme.of(context).textTheme.bodyLarge, color: Theme.of(context).colorScheme.primary),
            ],
          ).withPaddingSymetric(vertical: 4)
        ],
      ),
    );
  }
}
