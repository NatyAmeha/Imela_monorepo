import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:melegna_customer/domain/order/model/order.model.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/utils/date_utils.dart';
import 'package:melegna_customer/presentation/utils/widget_extesions.dart';

class OrderListItem extends StatelessWidget {
  final Order order;
  final double width;
  final double? height;
  final WidgetFactory widgetFactory;
  final Function? onSelected;
  const OrderListItem({
    super.key,
    required this.order,
    required this.widgetFactory,
    this.width = double.infinity,
    this.height,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      onTap: () {
        onSelected?.call();
      },
      border: Border.all(color: Theme.of(context).colorScheme.primaryContainer, width: 1),
      borderRadius: BorderRadius.circular(8),
      width: width,
      height: height,
      child: Column(
        children: [
          Row(children: [
            Expanded(
              child: Column(children: [
                widgetFactory.createText(context, "Order #1", style: Theme.of(context).textTheme.bodyLarge),
                widgetFactory.createText(context, order.createdAt.toFormattedString(), style: Theme.of(context).textTheme.titleSmall),
              ]),
            ),
            Chip(label: widgetFactory.createText(context, "${order.status}", style: Theme.of(context).textTheme.bodyMedium)),
            widgetFactory.createIcon(materialIcon: Icons.check_circle, color: Colors.green),
          ]),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, "${order.items} items", style: Theme.of(context).textTheme.bodyMedium),
              widgetFactory.createText(context, "${order.totalAmount} birr", style: Theme.of(context).textTheme.headlineSmall, color: Theme.of(context).colorScheme.primary),
            ],
          ).withPaddingSymetric(vertical: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, "Remaining amount", style: Theme.of(context).textTheme.bodyMedium),
              widgetFactory.createText(context, "400 Birr", style: Theme.of(context).textTheme.bodyLarge, color: Theme.of(context).colorScheme.primary),
            ],
          ),
        ],
      ),
    );
  }
}
