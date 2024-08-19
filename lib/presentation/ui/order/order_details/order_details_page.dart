import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melegna_customer/injection.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/order/order_details/order_details.viewmodel.dart';
import 'package:melegna_customer/presentation/ui/order/order_details/small_screen_order_detail.dart';
import 'package:melegna_customer/presentation/ui/shared/page_loading_utils/page_content_loader.dart';
import 'package:melegna_customer/presentation/ui/shared/page_loading_utils/responsive_wrapper.dart';


class OrderDetailPage extends StatefulWidget {
  static const routeName = '/orders';
  late final OrderDetailviewmodel? orderDetailViewmodel;
  final String ORderId;
  final String? orderName;

  OrderDetailPage({super.key, required this.ORderId, this.orderName, this.orderDetailViewmodel}) {
    orderDetailViewmodel ??= Get.put(getIt<OrderDetailviewmodel>());
  }

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
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
          showContent: true,
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
