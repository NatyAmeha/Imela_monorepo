import 'package:flutter/material.dart';
import 'package:imela/presentation/resources/colors.dart';
import 'package:imela_core/order/model/order.model.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/date_utils.dart';

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
      padding: const EdgeInsets.all(16),
      border: Border.all(color: ColorManager.primaryBackground, width: 1),
      borderRadius: BorderRadius.circular(8),
      width: width,
      height: height,
      child: Column(
        children: [
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                widgetFactory.createText(context, "Order #1", style: Theme.of(context).textTheme.bodyLarge),
                widgetFactory.createText(context, order.createdAt.toFormattedString(), style: Theme.of(context).textTheme.titleSmall),
              ]),
            ),
            Chip(label: widgetFactory.createText(context, "${order.status}", color: Colors.white
            , style: Theme.of(context).textTheme.bodySmall), backgroundColor: order.status == OrderStatus.PENDING.name ? Colors.orange : Colors.green),
          ]),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
            children: [
              widgetFactory.createText(context, '${order.items?.length} items', style: Theme.of(context).textTheme.labelMedium),
              widgetFactory.createText(context, "ETB ${order.subTotal}", style: Theme.of(context).textTheme.titleMedium, color: Theme.of(context).colorScheme.primary),
            ],
          ).withPaddingSymetric(vertical: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, "Remaining amount", style: Theme.of(context).textTheme.labelMedium),
              widgetFactory.createText(context, "400 Birr", style: Theme.of(context).textTheme.bodyLarge, color: Theme.of(context).colorScheme.primary),
            ],
          ),
        ],
      ),
    );
  }
}
