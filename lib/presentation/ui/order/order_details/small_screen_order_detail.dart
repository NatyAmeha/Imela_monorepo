import 'package:flutter/cupertino.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/order/order_details/order_details.viewmodel.dart';

class SmallScreenOrderDetail extends StatelessWidget {
  final OrderDetailviewmodel viewmodel;
  final WidgetFactory widgetFactory;
  const SmallScreenOrderDetail({super.key, required this.viewmodel, required this.widgetFactory});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}