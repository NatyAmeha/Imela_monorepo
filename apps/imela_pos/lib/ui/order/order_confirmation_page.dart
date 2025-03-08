import 'package:flutter/material.dart';
import 'package:imela_core/business/model/business_order_status.dart';
import 'package:imela_core/order/model/order.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_pos/ui/home/home_page.dart';
import 'package:imela_pos/ui/payment/payment_page.viewmodel.dart';
import 'package:imela_ui_kit/components/badge/status_ladder.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/ui/order/components/order_item_list_item.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class OrderConfirmationPage extends StatefulWidget {
  static const routeName = '/order-confirmation';
  static const orderKey = 'order';
  final Order? order;
  const OrderConfirmationPage({super.key, this.order});

  @override
  State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();

  static void navigate(BuildContext context, {required Order order}) {
    final router = AppViewmodel.getInstance().appRouter;
    final queryParam = order.getOrderQueryParam();
    router.navigateTo(context, routeName, extra: {orderKey: order}, queryParam: {orderKey: queryParam});
  }
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  late WidgetFactory widgetFactory;
  var paymentViewmodel = PaymentPageViewmodel.getInstance();

  List<BusinessOrderStatus> get orderStatuses => paymentViewmodel.appViewmodel.selectedBusiness.value?.orderStatuses ?? [];
  String get selectedLanguage => paymentViewmodel.appViewmodel.selectedLanguage;
  String get selectedCurrency => paymentViewmodel.appViewmodel.selectedCurrency;
  @override
  @override
  void initState() {
    super.initState();
    widgetFactory = AppViewmodel.getWidgetFactory(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widgetFactory.createText(context, 'Order Confirmation', style: Theme.of(context).textTheme.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            HomePage.navigate(context, replace: true);
          },
        ),
      ),
      body: Responsive.isLargeScreen(context)
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildSuccessIcon(),
                      _buildStatusLadder(),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      _buildOrderSummary(),
                      _buildItemList(),
                    ],
                  ),
                ),
              ],
            )
          : SingleChildScrollView(
              padding: Responsive.paddingSymetric(context, smallHorizontal: 16, smallVertical: 16),
              child: Column(
                children: [
                  _buildSuccessIcon(),
                  const SizedBox(height: 16),
                  _buildStatusLadder(),
                  const SizedBox(height: 16),
                  _buildOrderSummary(),
                  const SizedBox(height: 16),
                  _buildItemList(),
                ],
              ),
            ),
    );
  }

  Widget _buildSuccessIcon() {
    return Column(
      children: [
        widgetFactory.createIcon(materialIcon: Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 80),
        const SizedBox(height: 8),
        widgetFactory.createText(context, 'Order Success', style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }

  Widget _buildStatusLadder() {
    final statuses = orderStatuses.map((status) => status.status.localize(selectedLanguage)).toList();
    return widgetFactory.createCard(
      padding: Responsive.paddingSymetric(context, smallHorizontal: 16),
      border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerLowest),
      child: Column(
        children: [
          StatusLadder(
            items: statuses.map((status) => widgetFactory.createText(context, status)).toList(),
            currentIndex: 0,
            widgetFactory: widgetFactory,
            onTap: (index) {
              print('index: $index');
            },
          ),
          const SizedBox(height: 16),
          widgetFactory.createButton(
            context: context,
            content: const Text('Update Order status'),
            style: AppButtonStyle.textButtonStyle(context),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return widgetFactory.createCard(
      padding: const EdgeInsets.all(16),
      border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerLowest),
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widgetFactory.createText(context, 'Order Summary', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _buildSummaryRow('Total Items', '${widget.order!.items?.length} items'),
          _buildSummaryRow('Total Amount', 'ETB ${widget.order!.totalAmount}'),
          // _buildSummaryRow('Customer', widget.order!.),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        widgetFactory.createText(context, label, style: Theme.of(context).textTheme.bodyMedium),
        widgetFactory.createText(context, value, style: Theme.of(context).textTheme.titleSmall),
      ],
    ).withPaddingSymetric(vertical: 6);
  }

  Widget _buildItemList() {
    return widgetFactory.createCard(
      border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerLowest),
      borderRadius: BorderRadius.circular(8),
      child: AppListView(
        shrinkWrap: true,
        primary: false,
        // contentPadding: const EdgeInsets.symmetric(vertical: 4),
        items: widget.order!.items,
        itemBuilder: (context, item, index) {
          return OrderItemListItem(orderItem: item, widgetFactory: widgetFactory, selectedCurrency: selectedCurrency, selectedLanguage: selectedLanguage);
        },
      ),
    );
  }
}
