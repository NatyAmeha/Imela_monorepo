import 'package:flutter/material.dart';
import 'package:melegna_customer/domain/order/model/order_config.model.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/utils/widget_extesions.dart';

class OrderItemConfigListITemTile extends StatelessWidget {
  final WidgetFactory widgetFactory;
  final OrderConfig config;
  final String selectedCurrency;
  const OrderItemConfigListITemTile({super.key, required this.config, required this.widgetFactory, required this.selectedCurrency});

  @override
  Widget build(BuildContext context) {
    final configValue = config.selectedConfigValue();
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [widgetFactory.createText(context, config.name.localize(), style: Theme.of(context).textTheme.bodyLarge), widgetFactory.createText(context, configValue).showIfTrue(configValue.isNotEmpty)],
          ),
        ),
        const SizedBox(width: 24),
        widgetFactory.createText(context, config.getAdditionalPrice(selectedCurrency), style: Theme.of(context).textTheme.titleMedium)
      ],
    );
  }
}
