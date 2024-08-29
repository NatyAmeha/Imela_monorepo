import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/ui/factory/widget.factory.dart';
import 'package:imela/presentation/ui/order/order_details/order_details.viewmodel.dart';
import 'package:imela/presentation/ui/order/order_details/small_screen_order_detail.dart';
import 'package:imela/presentation/ui/shared/page_loading_utils/page_content_loader.dart';
import 'package:imela/presentation/ui/shared/page_loading_utils/responsive_wrapper.dart';
import 'package:imela/services/routing_service.dart';

class OrderDetailPage extends StatefulWidget {
  static const baseRouteName = '/order_detail';
  static const routeName = '$baseRouteName/:id';
  late OrderDetailviewmodel? orderDetailViewmodel;
  final String ORderId;
  final String? orderName;

  OrderDetailPage({super.key, required this.ORderId, this.orderName, this.orderDetailViewmodel}) {
    orderDetailViewmodel ??= Get.put(getIt<OrderDetailviewmodel>());
  }

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();

  static void navigate(BuildContext context, IRoutingService router, String orderId) {
    router.navigateTo(context, '$baseRouteName/$orderId', extra: {'id': orderId});
  }
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  OrderDetailviewmodel get viewmodel => widget.orderDetailViewmodel!;

  void initializeViewmodel() {
    Future.delayed(Duration.zero, () {
      viewmodel.initViewmodel(data: {'orderId': widget.ORderId});
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
          showContent: viewmodel.orderInfo.value != null,
          exception: viewmodel.exception.value,
          onTryAgain: () {
            initializeViewmodel();
          },
          content: ResponsiveWrapper(
            smallScreen: SmallScreenOrderDetail(viewmodel: viewmodel, widgetFactory: appWidgetfactory),
          ),
        ),
      ),
    );
  }
}
