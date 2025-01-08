import 'package:flutter/material.dart';
import 'package:imela/presentation/ui/shared/list/listview.component.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_core/business/model/payment_method.model.dart';

class PaymentMethodListItem extends StatelessWidget {
  final PaymentMethod paymentMethod;
  final String? selectedPaymentId;
  final double width;
  final double? height;
  final WidgetFactory widgetFactory;
  final Function(PaymentMethod)? onSelected;
  const PaymentMethodListItem({
    super.key,
    required this.paymentMethod,
    this.selectedPaymentId,
    this.width = double.infinity,
    this.height,
    required this.widgetFactory,
    this.onSelected,
  });

  bool get isSelected => paymentMethod.id == selectedPaymentId;

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      onTap: () {
        onSelected?.call(paymentMethod);
      },
      border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widgetFactory.createIcon(materialIcon: isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widgetFactory.createText(context, paymentMethod.name.localize('ENGLISH'), style: Theme.of(context).textTheme.bodyLarge),
                    if (paymentMethod.description != null) widgetFactory.createText(context, paymentMethod.description.localize('ENGLISH'), style: Theme.of(context).textTheme.bodyMedium),
                    if (paymentMethod.options?.isNotEmpty == true) ...[
                      const Divider(),
                      _buildPaymentMethodOption(context, paymentMethod.options ?? []),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption(BuildContext context, List<PaymentMethodOption> paymentMethodOptions) {
    return widgetFactory.createCard(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: AppListView(
        shrinkWrap: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
        items: paymentMethodOptions,
        itemBuilder: (context, paymentMethodOption, index) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, paymentMethodOption.name.localize('ENGLISH'), style: Theme.of(context).textTheme.bodyLarge),
              if (paymentMethodOption.account != null) widgetFactory.createText(context, paymentMethodOption.account.toString(), style: Theme.of(context).textTheme.bodyLarge),
            ],
          );
        },
      ),
    );
  }
}
