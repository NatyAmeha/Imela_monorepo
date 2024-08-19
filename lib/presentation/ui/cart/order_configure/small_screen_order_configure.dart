import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melegna_customer/domain/business/model/payment_option.model.dart';
import 'package:melegna_customer/domain/order/model/cart.model.dart';
import 'package:melegna_customer/presentation/ui/cart/order_configure/order_configure.viewmodel.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/payment/components/payment_option_item.dart';
import 'package:melegna_customer/presentation/ui/shared/list/listview.component.dart';

class SmallScreenOrderConfigure extends StatelessWidget {
  final OrderConfigureViewmodel viewmodel;
  final WidgetFactory widgetFactory;
  final Cart cart;
  const SmallScreenOrderConfigure({super.key, required this.viewmodel, required this.widgetFactory, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Configure'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  AppListView<PaymentOption>(
                    items: cart.paymentOptions ?? [],
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    shrinkWrap: true,
                    itemBuilder: (context, item, index) {
                      return Obx(
                        () => PaymentOptionListItem(
                          paymentOption: item,
                          selectedPaymentOptionId: viewmodel.selectedPaymentOptionId,
                          widgetFactory: widgetFactory,
                          onSelected: () {
                            viewmodel.selectPaymentOption(item);
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  widgetFactory.createText(context, "Payment method"),
                  widgetFactory.createRadioListTile(context, title: "Online payment", value: "1", groupValue: "1", onChanged: (value) {}),
                  widgetFactory.createRadioListTile(context, title: "Cash on delivery", value: "2", groupValue: "1", onChanged: (value) {}),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Positioned(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: widgetFactory.createCard(
                padding: const EdgeInsets.all(16),
                border: Border.all(color: Theme.of(context).colorScheme.primaryContainer, width: 1),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          widgetFactory.createText(context, "Total", style: Theme.of(context).textTheme.bodyMedium),
                          widgetFactory.createText(context, "${viewmodel.cartInfo.value?.getFormattedTotalPrice(context)}", style: Theme.of(context).textTheme.titleLarge),
                        ],
                      ),
                    ),
                    widgetFactory.createButton(
                      context: context,
                      content: Text("Place order"),
                      onPressed: () {
                        viewmodel.placeOrder(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
