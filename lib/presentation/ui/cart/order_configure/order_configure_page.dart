import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melegna_customer/domain/order/model/cart.model.dart';
import 'package:melegna_customer/injection.dart';
import 'package:melegna_customer/presentation/ui/cart/order_configure/order_configure.viewmodel.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/cart/order_configure/small_screen_order_configure.dart';
import 'package:melegna_customer/presentation/ui/shared/page_loading_utils/page_content_loader.dart';
import 'package:melegna_customer/presentation/ui/shared/page_loading_utils/responsive_wrapper.dart';
import 'package:melegna_customer/services/routing_service.dart';

class OrderConfigurePage extends StatefulWidget {
  static const routeName = '/order_configure';
  
  late OrderConfigureViewmodel? orderConfigureViewmodel;
  final Cart cartInfo;

  OrderConfigurePage({super.key, this.orderConfigureViewmodel, required this.cartInfo}) {
    orderConfigureViewmodel ??= getIt<OrderConfigureViewmodel>();
  }

  @override
  State<OrderConfigurePage> createState() => _OrderConfigurePageState();

  static void navigateToOrderConfigurePage(BuildContext context, IRoutingService router, {required Cart cartInfo}) {
    router.navigateTo(context, OrderConfigurePage.routeName, extra: {'cart': cartInfo});
  }
}

class _OrderConfigurePageState extends State<OrderConfigurePage> {
  OrderConfigureViewmodel get viewmodel => widget.orderConfigureViewmodel!;

  void initializeViewmodel() {
    Future.delayed(Duration.zero, () {
      viewmodel.initViewmodel( data: {'cart': widget.cartInfo});
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
            smallScreen: SmallScreenOrderConfigure(viewmodel: viewmodel, widgetFactory: appWidgetfactory, cart: widget.cartInfo,),
          ),
        ),
      ),
    );
  }
}
