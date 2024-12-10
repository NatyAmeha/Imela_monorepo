import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_pos/app/app_viewmodel.dart';

import 'package:imela_pos/ui/order/components/order_item_list_item.dart';
import 'package:imela_pos/ui/order/order.viewmodel.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/date_utils.dart';

class OrderDetailsPage extends StatefulWidget {
  static const routeName = '/order-details';

  final bool showAppbar;

  const OrderDetailsPage({super.key, this.showAppbar = true});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();

  static void navigateTo(BuildContext context) {
    final router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, routeName);
  }
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  late OrderViewmodel viewmodel;
  late WidgetFactory widgetFactory;

  

  var selectedCurrency = AppViewmodel.getInstance().selectedCurrency;
  var selectedLanguage = AppViewmodel.getInstance().selectedLanguage;

  @override
  void initState() {
    super.initState();
    widgetFactory = AppViewmodel.getWidgetFactory(context);
    viewmodel = OrderViewmodel.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppbar ? AppBar(
        title: widgetFactory.createText(context, 'Order Details', style: Theme.of(context).textTheme.titleMedium),
      ) : null,
      body: Obx(
        () {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                widgetFactory.createCard(
                  padding: const EdgeInsets.all(16),
                  border: Border.all(color: Theme.of(context).colorScheme.primary),
                  borderRadius: BorderRadius.circular(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widgetFactory.createText(context, 'Order Summary', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          widgetFactory.createText(context, 'Order Date', style: Theme.of(context).textTheme.bodyMedium),
                          widgetFactory.createText(context, '${viewmodel.selectedOrder.value?.createdAt?.toFormattedString()}', style: Theme.of(context).textTheme.titleSmall),
                        ],
                      ).withPaddingSymetric(vertical: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          widgetFactory.createText(context, 'Status', style: Theme.of(context).textTheme.bodyMedium),
                          widgetFactory.createText(context, '${viewmodel.selectedOrder.value?.getOrderStatus(selectedLanguage, viewmodel.appViewmodel.businessOrderStatuses)}', style: Theme.of(context).textTheme.titleSmall),
                        ],
                      ).withPaddingSymetric(vertical: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          widgetFactory.createText(context, 'total Items', style: Theme.of(context).textTheme.bodyMedium),
                          widgetFactory.createText(context, '${viewmodel.selectedOrder.value?.items?.length} items', style: Theme.of(context).textTheme.titleSmall),
                        ],
                      ).withPaddingSymetric(vertical: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          widgetFactory.createText(context, 'Total Amount', style: Theme.of(context).textTheme.bodyMedium),
                          widgetFactory.createText(context, 'ETB ${viewmodel.selectedOrder.value?.totalAmount}', style: Theme.of(context).textTheme.titleSmall),
                        ],
                      ).withPaddingSymetric(vertical: 6),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                widgetFactory.createCard(
                  padding: const EdgeInsets.all(16),
                  border: Border.all(color: Theme.of(context).colorScheme.primary),
                  borderRadius: BorderRadius.circular(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widgetFactory.createText(context, 'Payment summary', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          widgetFactory.createText(context, 'Paid amounts', style: Theme.of(context).textTheme.bodyMedium),
                          widgetFactory.createText(context, '${viewmodel.selectedOrder.value?.paidAmountString(selectedCurrency, selectedLanguage)}', style: Theme.of(context).textTheme.titleSmall),
                        ],
                      ).withPaddingSymetric(vertical: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          widgetFactory.createText(context, 'Remaining Amount', style: Theme.of(context).textTheme.bodyMedium),
                          widgetFactory.createText(context, '${viewmodel.selectedOrder.value?.remainingAmountString(selectedCurrency, selectedLanguage)} items', style: Theme.of(context).textTheme.titleSmall),
                        ],
                      ).withPaddingSymetric(vertical: 6),
                      const SizedBox(height: 16),
                      // AppListView(
                      //   shrinkWrap: true,
                      //   items: viewmodel.selectedOrder.value?.paymentMethods ?? [],
                      //   itemBuilder: (context, item, index) {
                      //     return SelectedPaymentMethodListItem(selectedPaymentMethod: item, selectedLanguage: selectedLanguage);
                      //   },
                      // )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                widgetFactory.createCard(
                  padding: const EdgeInsets.all(16),
                  border: Border.all(color: Theme.of(context).colorScheme.primary),
                  borderRadius: BorderRadius.circular(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widgetFactory.createText(context, 'Items', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 16),
                      AppListView(
                        shrinkWrap: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                        items: viewmodel.selectedOrder.value?.items ?? [],
                        itemBuilder: (context, item, index) {
                          return OrderItemListItem(orderItem: item, widgetFactory: widgetFactory, selectedCurrency: selectedCurrency, selectedLanguage: selectedLanguage);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
