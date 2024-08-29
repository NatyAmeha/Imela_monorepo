import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/factory/widget.factory.dart';
import 'package:imela/presentation/ui/order/components/order_list_item.dart';
import 'package:imela/presentation/ui/order/order_list/order_list.viewmodel.dart';
import 'package:imela/presentation/ui/shared/list/listview.component.dart';

class SmallScreenOrderList extends StatelessWidget {
  final OrderListViewmodel viewmodel;
  final WidgetFactory widgetFactory;
  const SmallScreenOrderList({super.key, required this.viewmodel, required this.widgetFactory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Orders")),
      body: AppListView(
        controller: viewmodel.orderListController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
        itemBuilder: (context, item, index) {
          return OrderListItem(
            order: item,
            widgetFactory: widgetFactory,
            onSelected: () {
              viewmodel.navigateToOrderDetailPage(context, item);
            },
          );
        },
      ),
    );
  }
}
