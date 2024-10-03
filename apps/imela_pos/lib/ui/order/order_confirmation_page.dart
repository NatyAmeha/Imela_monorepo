import 'package:flutter/material.dart';
import 'package:imela_pos/app/app_viewmodel.dart';

class OrderConfirmationPage extends StatefulWidget {
  static const routeName = "/order-confirmation"; 
  const OrderConfirmationPage({super.key});

  @override
  State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();

  static void navigate(BuildContext context) {
    final router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, routeName);
  }
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  // final viewmodel = OrderConfirmationViewmodel.getInstance();
  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    return Scaffold(
      body: Column(
        children: [
          Text("data")
        ],
      ),
    );
  }
}
