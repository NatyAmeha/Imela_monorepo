import 'package:flutter/material.dart';
import 'package:imela/presentation/resources/colors.dart';
import 'package:imela_core/order/model/order.model.dart';
import 'package:imela_ui_kit/components/badge/badge_list.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/date_utils.dart';

class OrderListItem extends StatelessWidget {
  final Order order;
  final double width;
  final double? height;
  final WidgetFactory widgetFactory;
  final Function? onSelected;
  final String selectedCurrency;
  final String selectedLanguage;
  const OrderListItem({
    super.key,
    required this.order,
    required this.widgetFactory,
    this.width = double.infinity,
    this.height,
    this.onSelected,
    required this.selectedCurrency,
    required this.selectedLanguage,
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
                widgetFactory.createText(context, 'Order code ${order.code}', style: Theme.of(context).textTheme.bodyLarge),
                BadgeList(values: [order.status ?? ''], colors: [Theme.of(context).colorScheme.tertiary], widgetFactory: widgetFactory),
              ]),
            ),
            widgetFactory.createText(context, order.createdAt.toFormattedString(), style: Theme.of(context).textTheme.titleSmall),
          ]),
          const Divider(),
          Row( 
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, 'Total amount', style: Theme.of(context).textTheme.labelMedium),
              widgetFactory.createText(context, 'ETB ${order.totalAmount}', style: Theme.of(context).textTheme.bodyLarge),
            ],
          ).withPaddingSymetric(vertical: 4),
          if (order.remainingAmount > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widgetFactory.createText(context, 'Remaining amount', style: Theme.of(context).textTheme.labelMedium),
                widgetFactory.createText(context, order.remainingAmountString(selectedCurrency, selectedLanguage), style: Theme.of(context).textTheme.bodyLarge, color: ColorManager.warning),
              ],
            ),
        ],
      ),
    );
  }
}
