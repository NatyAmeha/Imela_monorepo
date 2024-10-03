import 'package:flutter/material.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/ui/order/order_list.viewmodel.dart';

class OrderListPage extends StatefulWidget {
  static const routeName = '/order-list';
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();

  static void getInstance(BuildContext context) {
    final router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, routeName);
  }
}

class _OrderListPageState extends State<OrderListPage> {
  OrderListViewmodel get viewmodel => OrderListViewmodel.getInstance();
  @override
  void initState() {
    super.initState();
    viewmodel.initViewmodel(data: {});
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
