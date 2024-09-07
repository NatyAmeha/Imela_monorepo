import 'package:flutter/cupertino.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_core/business/model/payment_method.model.dart';

class PaymentMethodListItem extends StatelessWidget {
  final PaymentMethod paymentMethod;
  final String selectedPaymentId;
  final double width;
  final double? height;
  final WidgetFactory widgetFactory;
  final Function(String? selectedPaymentId)? onSelected;
  const PaymentMethodListItem({
    super.key,
    required this.paymentMethod,
    required this.selectedPaymentId,
    this.width = double.infinity,
    this.height,
    required this.widgetFactory,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      child: Column(
        children: [
          widgetFactory.createRadioListTile(
            context,
            title: paymentMethod.name.localize('ENGLISH'),
            value: paymentMethod.id!,
            groupValue: selectedPaymentId,
            subtitle: paymentMethod.type.toString(),
            onChanged: (value) {
              onSelected?.call(value);
            },
          )
        ],
      ),
    );
  }
}
