import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/factory/widget.factory.dart';
import 'package:imela/presentation/ui/order/order_list/order_list.viewmodel.dart';
import 'package:imela/presentation/ui/order/order_list/small_screen_order_list.dart';
import 'package:imela/presentation/ui/shared/page_loading_utils/page_content_loader.dart';
import 'package:imela/presentation/ui/shared/page_loading_utils/responsive_wrapper.dart';

import '../../../../injection.dart';

class OrderListPage extends StatefulWidget {
  static const routeName = '/orders';
  late OrderListViewmodel? orderListViewmodel;

  OrderListPage({super.key, this.orderListViewmodel}) {
    orderListViewmodel ??= Get.put(getIt<OrderListViewmodel>());
  }

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  OrderListViewmodel get viewmodel => widget.orderListViewmodel!;

  void initializeViewmodel() {
    Future.delayed(Duration.zero, () {
      viewmodel.initViewmodel();
    });
  }

  @override
  void initState() {
    super.initState();
    initializeViewmodel();
  }

  @override
  Widget build(BuildContext context) {
    final appWidgetfactory = WidgetFactory(Theme.of(context).platform);
    return Scaffold(
      body: Obx(
        () => PageContentLoader(
          isDataLoading: viewmodel.isLoading.value,
          hasError: viewmodel.exception.value?.isMainError ?? false,
          showContent: true,
          exception: viewmodel.exception.value,
          onTryAgain: () {
            initializeViewmodel();
          },
          content: ResponsiveWrapper(
            smallScreen: SmallScreenOrderList(viewmodel: viewmodel, widgetFactory: appWidgetfactory),
          ),
        ),
      ),
    );
  }
}
