import 'package:flutter/material.dart';
import 'package:melegna_customer/presentation/ui/cart/order_configure/order_configure.viewmodel.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';

class SmallScreenOrderConfirmation extends StatelessWidget {
  final OrderConfigureViewmodel viewmodel;
  final WidgetFactory widgetFactory;
  const SmallScreenOrderConfirmation({super.key, required this.viewmodel, required this.widgetFactory});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (isPop) {
        viewmodel.navigateToHome(context);
      },
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Order Confirmation'),
            automaticallyImplyLeading: false,
            leading: widgetFactory.createIcon(
                materialIcon: Icons.arrow_back_ios,
                onPressed: () {
                  viewmodel.navigateToHome(context);
                }),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                widgetFactory.createCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      widgetFactory.createText(context, "Order Confirmation"),
                      const SizedBox(height: 16),
                      widgetFactory.createButton(
                        context: context,
                        content: Text("Back to Home"),
                        onPressed: () {
                          viewmodel.navigateToHome(context);
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }
}
