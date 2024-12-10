import 'package:flutter/material.dart';
import 'package:imela_core/business/model/business_order_status.dart';
import 'package:imela_core/order/model/order.model.dart';
import 'package:imela_pos/ui/order/components/order_item_list_item.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/date_utils.dart';

class OrderDetailModal extends StatelessWidget {
  final Order orderInfo;
  final WidgetFactory widgetFactory;
  final String selectedLanguage;
  final String selectedCurrency;
  final List<BusinessOrderStatus> businessOrderStatuses;
  const OrderDetailModal({
    super.key,
    required this.orderInfo,
    required this.widgetFactory,
    required this.selectedLanguage,
    required this.selectedCurrency,
    required this.businessOrderStatuses,
  });

  @override
  Widget build(BuildContext context) {
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
                    widgetFactory.createText(context, '${orderInfo.createdAt?.toFormattedString()}', style: Theme.of(context).textTheme.titleSmall),
                  ],
                ).withPaddingSymetric(vertical: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widgetFactory.createText(context, 'Status', style: Theme.of(context).textTheme.bodyMedium),
                    widgetFactory.createText(context, '${orderInfo.getOrderStatus(selectedLanguage, businessOrderStatuses)}', style: Theme.of(context).textTheme.titleSmall),
                  ],
                ).withPaddingSymetric(vertical: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widgetFactory.createText(context, 'total Items', style: Theme.of(context).textTheme.bodyMedium),
                    widgetFactory.createText(context, '${orderInfo.items?.length} items', style: Theme.of(context).textTheme.titleSmall),
                  ],
                ).withPaddingSymetric(vertical: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widgetFactory.createText(context, 'Total Amount', style: Theme.of(context).textTheme.bodyMedium),
                    widgetFactory.createText(context, 'ETB ${orderInfo.totalAmount}', style: Theme.of(context).textTheme.titleSmall),
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
                    widgetFactory.createText(context, '${orderInfo.paidAmountString(selectedCurrency, selectedLanguage)}', style: Theme.of(context).textTheme.titleSmall),
                  ],
                ).withPaddingSymetric(vertical: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widgetFactory.createText(context, 'Remaining Amount', style: Theme.of(context).textTheme.bodyMedium),
                    widgetFactory.createText(context, '${orderInfo.remainingAmountString(selectedCurrency, selectedLanguage)} items', style: Theme.of(context).textTheme.titleSmall),
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
                  items: orderInfo.items ?? [],
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
  }
}
