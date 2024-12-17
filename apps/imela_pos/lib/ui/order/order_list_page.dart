import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/order/model/order.model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/ui/order/components/order_list_item.dart';
import 'package:imela_pos/ui/order/order.viewmodel.dart';
import 'package:imela_pos/ui/order/order_details_page.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class OrderListPage extends StatefulWidget {
  static const routeName = '/order-list';
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();

  static void navigate(BuildContext context) {
    final router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, routeName);
  }
}

class _OrderListPageState extends State<OrderListPage> {
  OrderViewmodel get viewmodel => OrderViewmodel.getInstance();
  late WidgetFactory widgetFactory;
  @override
  void initState() {
    widgetFactory = AppViewmodel.getWidgetFactory(context);
    super.initState();
    viewmodel.initViewmodel(data: {'context': context});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      body: Obx(
        () => PageContentLoader(
          isLoading: viewmodel.isLoading.value,
          exception: viewmodel.exception.value,
          hasError: viewmodel.exception.value?.isMainError ?? false,
          onTryAgain: () {
            viewmodel.getOrders(context);
          },
          content: widgetFactory.createCard(
            padding: EdgeInsets.symmetric(horizontal: Responsive.getHeight(context, small: 16)),
            child: Row(
              children: [
                Expanded(
                  flex: 7,
                  child: Obx(
                    () => AppListView(
                      items: viewmodel.orders.value,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      itemBuilder: (context, order, index) {
                        final status = order.getOrderStatus(viewmodel.selectedLanguage, viewmodel.appViewmodel.businessOrderStatuses);
                        return Obx(
                          () => OrderListItem(
                            order: order,
                            statusMsg: status,
                            widgetFactory: widgetFactory,
                            isSelected: viewmodel.selectedOrder.value?.id == order.id,
                            actions: viewmodel.getOrderActions(),
                            onActionClick: (value) {
                              viewmodel.setSelectedOrder(context, order);
                              viewmodel.handleOrderAction(context, value);
                            },
                            onTap: () {
                              viewmodel.setSelectedOrder(context, order);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (!Responsive.isSmallScreen(context))
                  Obx(
                    () => viewmodel.selectedOrder.value != null
                        ? const Expanded(
                            flex: 2,
                            child: OrderDetailsPage(showAppbar: false),
                          )
                        : const SizedBox.shrink(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
