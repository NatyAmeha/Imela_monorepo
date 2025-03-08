import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/ui/order/components/order_list_item.dart';
import 'package:imela_pos/ui/order/order.viewmodel.dart';
import 'package:imela_pos/ui/order/order_details_page.dart';
import 'package:imela_ui_kit/components/app_choicechip_group.component.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';
import 'package:intl/intl.dart';

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
                  flex: 3,
                  child: Column(
                    children: [
                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: SearchBar(
                          trailing: const [Icon(Icons.search)],
                          hintText: 'Search orders...',
                          onChanged: viewmodel.updateSearch,
                          leading: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Obx(
                              () => DropdownButtonHideUnderline(
                                child: DropdownButton<OrderSearchType>(
                                  isDense: true,
                                  value: viewmodel.selectedSearchType.value,
                                  items: OrderSearchType.values
                                      .map((type) => DropdownMenuItem(
                                            value: type,
                                            child: Text(type.label),
                                          ))
                                      .toList(),
                                  onChanged: (type) {
                                    if (type != null) viewmodel.updateSearchType(type);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Existing Status Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Obx(
                          () => AppChoiceChipGroup(
                            choices: viewmodel.orderStatusTabs,
                            selectedChoices: viewmodel.selectedOrderStatus,
                            onSelectionChanged: (selected, unselected) {
                              viewmodel.filterOrdersByStatus(context, selected);
                            },
                          ),
                        ),
                      ),

                      // Existing Order List
                      Expanded(
                        child: Obx(
                          () => ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: viewmodel.groupedOrders.length,
                            itemBuilder: (context, index) {
                              final date = viewmodel.groupedOrders.keys.elementAt(index);
                              final ordersForDate = viewmodel.groupedOrders[date]!;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Date Header
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      DateFormat('MMMM dd, yyyy').format(date),
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  // Orders for this date
                                  ...ordersForDate.map((order) {
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
                                  }).toList(),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!Responsive.isSmallScreen(context))
                  Obx(
                    () => Expanded(
                      flex: 4,
                      child: viewmodel.selectedOrder.value != null ? OrderDetailsPage(showAppbar: false) : const SizedBox.shrink(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
