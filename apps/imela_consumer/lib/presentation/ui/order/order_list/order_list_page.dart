import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/order/order_list/order_list.viewmodel.dart';
import 'package:imela/presentation/ui/order/order_list/small_screen_order_list.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/components/page_loading_utils/responsive_wrapper.dart';
import 'package:imela/l10n/l10n.dart';

class OrderListPage extends StatefulWidget {
  static const routeName = '/orders';

  OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();

  static void navigate(BuildContext context) {
    final router = AppController.getInstance.router;
    router.navigateTo(context, routeName);
  }
}

class _OrderListPageState extends State<OrderListPage> {
  OrderListViewmodel get viewmodel => OrderListViewmodel.getInstance();

  void initializeViewmodel() {
    Future.delayed(Duration.zero, () {
      viewmodel.initViewmodel(data: {'context': context});
    });
  }

  @override
  void initState() {
    super.initState();
    initializeViewmodel();
  }

  @override
  Widget build(BuildContext context) {
    final appWidgetfactory = AppController.getInstance.getWidgetFactory(context);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.orders)),
      body: Obx(
        () => PageContentLoader(
          isLoading: viewmodel.isLoading.value,
          hasError: viewmodel.exception.value?.isMainError ?? false,
          showContent: viewmodel.orderList.value.isNotEmpty,
          exception: viewmodel.exception.value,
          onTryAgain: () {
            viewmodel.exception.value?.onAction?.call() ?? viewmodel.getUserOrders(context);
          },
          content: ResponsiveWrapper(
            smallScreen: SmallScreenOrderList(viewmodel: viewmodel, widgetFactory: appWidgetfactory),
          ),
        ),
      ),
    );
  }
}
