import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:imela/presentation/ui/factory/widget.factory.dart';
import 'package:imela/presentation/ui/order/order_details/order_details.viewmodel.dart';
import 'package:imela/presentation/utils/date_utils.dart';
import 'package:imela/presentation/utils/widget_extesions.dart';

class SmallScreenOrderDetail extends StatelessWidget {
  final OrderDetailviewmodel viewmodel;
  final WidgetFactory widgetFactory;
  const SmallScreenOrderDetail({super.key, required this.viewmodel, required this.widgetFactory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Order details"),
        ), 
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: widgetFactory.createCard(
            padding: const EdgeInsets.all(16),
            border: Border.all(color: Theme.of(context).colorScheme.primary),
            borderRadius: BorderRadius.circular(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widgetFactory.createText(context, "Order Summary", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widgetFactory.createText(context, "Order Date", style: Theme.of(context).textTheme.bodyMedium),
                    widgetFactory.createText(context, '${viewmodel.orderInfo.value?.createdAt?.toFormattedString()}', style: Theme.of(context).textTheme.titleSmall),
                  ],
                ).withPaddingSymetric(vertical: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widgetFactory.createText(context, "Status", style: Theme.of(context).textTheme.bodyMedium),
                    widgetFactory.createText(context, '${viewmodel.orderInfo.value?.status}', style: Theme.of(context).textTheme.titleSmall),
                  ],
                ).withPaddingSymetric(vertical: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widgetFactory.createText(context, "total Items", style: Theme.of(context).textTheme.bodyMedium),
                    widgetFactory.createText(context, '${viewmodel.orderInfo.value?.items?.length} items', style: Theme.of(context).textTheme.titleSmall),
                  ],
                ).withPaddingSymetric(vertical: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widgetFactory.createText(context, "Total Amount", style: Theme.of(context).textTheme.bodyMedium),
                    widgetFactory.createText(context, 'ETB ${viewmodel.orderInfo.value?.totalAmount}', style: Theme.of(context).textTheme.titleSmall),
                  ],
                ).withPaddingSymetric(vertical: 6),
              ],
            ),
          ),
        ));
  }
}
