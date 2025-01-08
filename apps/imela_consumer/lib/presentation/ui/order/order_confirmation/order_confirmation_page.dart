import 'package:flutter/material.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/order/order_confirmation/order_confirmation.viewmodel.dart';
import 'package:imela/presentation/ui/order/order_confirmation/small_screen_order_confirmation.dart';
import 'package:imela_core/order/model/order.model.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/components/page_loading_utils/responsive_wrapper.dart';

class OrderConfirmationPage extends StatefulWidget {
  static const routeName = '/order-confirmation';
  static const ORDER_INFO_KEY = 'order_info';

  final Order order;

  OrderConfirmationPage({super.key, required this.order});

  @override
  State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();

  static void navigate(BuildContext context, Order order) {
    final router = AppController.getInstance.router;
    router.navigateTo(context, routeName, extra: {ORDER_INFO_KEY: order});
  }
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  final viewmodel = OrderConfirmationViewmodel.getInstance();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    viewmodel.initViewmodel(data: {OrderConfirmationPage.ORDER_INFO_KEY: widget.order});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageContentLoader(
        isDataLoading: false,
        hasError: false,
        showContent: true,
        onTryAgain: () {},
        content: const ResponsiveWrapper(smallScreen: SmallScreenOrderConfirmation()),
      ),
    );
  }
}
