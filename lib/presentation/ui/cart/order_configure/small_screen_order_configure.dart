import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/domain/business/model/payment_option.model.dart';
import 'package:imela/domain/order/model/cart.model.dart';
import 'package:imela/presentation/ui/cart/order_configure/order_configure.viewmodel.dart';
import 'package:imela/presentation/ui/factory/widget.factory.dart';
import 'package:imela/presentation/ui/payment/components/payment_option_item.dart';
import 'package:imela/presentation/ui/shared/list/listview.component.dart';

class SmallScreenOrderConfigure extends StatelessWidget {
  final OrderConfigureViewmodel viewmodel;
  final WidgetFactory widgetFactory;
  final Cart cart;
  const SmallScreenOrderConfigure({super.key, required this.viewmodel, required this.widgetFactory, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  widgetFactory.createText(context, 'Payment options', style: Theme.of(context).textTheme.titleLarge),
                  AppListView<PaymentOption>(
                    items: cart.paymentOptions ?? [],
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    shrinkWrap: true,
                    itemBuilder: (context, item, index) {
                      return Obx(
                        () => PaymentOptionListItem(
                          totalAmount: viewmodel.cartInfo.value?.getTotalPrice ?? 0,
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
                  widgetFactory.createText(context, 'Payment method', style: Theme.of(context).textTheme.titleLarge),
                  widgetFactory.createRadioListTile(context, title: 'Online payment', value: '1', groupValue: '1', onChanged: (value) {}),
                  widgetFactory.createRadioListTile(context, title: 'Cash on delivery', value: '2', groupValue: '1', onChanged: (value) {}),
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
                      child: Obx(
                        () => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            widgetFactory.createText(context, 'Total', style: Theme.of(context).textTheme.bodyMedium),
                            widgetFactory.createText(context, 'ETB ${viewmodel.totalAmount}', style: Theme.of(context).textTheme.titleLarge),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: widgetFactory.createButton(
                        context: context,
                        content: const Text('Place order'),
                        onPressed: () {
                          viewmodel.placeOrder(context);
                        },
                      ),
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
