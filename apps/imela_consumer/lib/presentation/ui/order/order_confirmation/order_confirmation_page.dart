import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/ui/cart/order_configure/order_configure.viewmodel.dart';
import 'package:imela/presentation/ui/order/order_confirmation/small_screen_order_confirmation.dart';
import 'package:imela/presentation/ui/shared/page_loading_utils/page_content_loader.dart';
import 'package:imela/presentation/ui/shared/page_loading_utils/responsive_wrapper.dart';
import 'package:imela/services/routing_service.dart';
import 'package:imela_core/order/model/order.model.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class OrderConfirmationPage extends StatefulWidget {
  static const routeName = '/order-confirmation';
  static const ORDER_INFO_KEY = 'order_info';
  late  OrderConfigureViewmodel? cartDetailViewmodel;

  OrderConfirmationPage({super.key, this.cartDetailViewmodel}) {
    cartDetailViewmodel ??= Get.put(getIt<OrderConfigureViewmodel>());
  }

  @override
  State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();

  static void navigate(BuildContext context, IRoutingService router, Order order ){
    router.navigateTo(context, routeName, extra: {ORDER_INFO_KEY: order});
  }
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  OrderConfigureViewmodel get viewmodel => widget.cartDetailViewmodel!;

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
    final widgetFactory = WidgetFactory(Theme.of(context).platform);
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
            smallScreen: SmallScreenOrderConfirmation(viewmodel: viewmodel, widgetFactory: widgetFactory),
          ),
        ),
      ),
    );
  }
}
