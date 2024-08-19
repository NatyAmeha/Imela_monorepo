import 'package:flutter/cupertino.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/order/order_list/order_list.viewmodel.dart';

class SmallScreenOrderList extends StatelessWidget {
  final OrderListViewmodel orderListViewmodel;
  final WidgetFactory widgetFactory;
  const SmallScreenOrderList({super.key, required this.orderListViewmodel, required this.widgetFactory});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}