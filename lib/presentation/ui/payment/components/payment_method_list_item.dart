import 'package:flutter/cupertino.dart';
import 'package:imela/domain/business/model/payment_method.model.dart';
import 'package:imela/domain/shared/localized_field.model.dart';
import 'package:imela/presentation/ui/factory/widget.factory.dart';

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
            title: paymentMethod.name.localize(),
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
