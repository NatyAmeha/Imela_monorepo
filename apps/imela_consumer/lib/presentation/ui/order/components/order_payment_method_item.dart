import 'package:flutter/material.dart';
import 'package:imela_core/business/model/payment_method.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/components/image/app_image.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class OrderPaymentMethodItem extends StatelessWidget {
  final SelectedPaymentMethod orderPaymentMethod;
  final WidgetFactory widgetFactory;
  final String selectedLanguage;
  final double receiptImageWidth;
  const OrderPaymentMethodItem({
    super.key,
    required this.orderPaymentMethod,
    required this.widgetFactory,
    required this.selectedLanguage,
    this.receiptImageWidth = 50,
  });

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, orderPaymentMethod.name.localize(selectedLanguage), style: Theme.of(context).textTheme.titleSmall),
              widgetFactory.createText(context, orderPaymentMethod.amount.amount.toString(), style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
          if (orderPaymentMethod.receiptImages?.isNotEmpty == true)
            AppImage(
              imageUrl: orderPaymentMethod.receiptImages!.first,
              width: receiptImageWidth,
              height: receiptImageWidth,
            )
        ],
      ),
    );
  }
}
