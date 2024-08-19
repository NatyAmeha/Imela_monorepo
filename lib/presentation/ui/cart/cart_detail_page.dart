import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melegna_customer/domain/order/model/cart.model.dart';
import 'package:melegna_customer/injection.dart';
import 'package:melegna_customer/presentation/ui/cart/cart_detail.viewmodel.dart';
import 'package:melegna_customer/presentation/ui/cart/small_screen_cart_detail_page.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/shared/page_loading_utils/page_content_loader.dart';
import 'package:melegna_customer/presentation/ui/shared/page_loading_utils/responsive_wrapper.dart';
import 'package:melegna_customer/services/routing_service.dart';

class CartDetailPage extends StatefulWidget {
  final Cart selectedCart;
  static const baseRouteName = '/cart';
  static const routeName = '$baseRouteName/:id';

  static const CART_DATA = 'cart';

  late CartDetailViewmodel? cartDetailViewmodel;

  static void navigateToCartDetailPage(BuildContext context, IRoutingService router, Cart cart) {
    router.navigateTo(context, CartDetailPage.routeName, extra: {CartDetailPage.CART_DATA: cart});
  }

  CartDetailPage({super.key, required this.selectedCart, this.cartDetailViewmodel}) {
    cartDetailViewmodel ??=  Get.put(getIt<CartDetailViewmodel>());
  }

  @override
  State<CartDetailPage> createState() => _CartDetailPageState();
}

class _CartDetailPageState extends State<CartDetailPage> {
  CartDetailViewmodel get viewmodel => widget.cartDetailViewmodel!;

  void initializeViewmodel() {
    Future.delayed(Duration.zero, () {
      widget.cartDetailViewmodel!.initViewmodel(data: {CartDetailPage.CART_DATA: widget.selectedCart});
    });
  }

  @override
  void initState() {
    super.initState();
    initializeViewmodel();
  }

  @override
  Widget build(BuildContext context) {
    final appWidgetFactory = WidgetFactory(Theme.of(context).platform);
    return Scaffold(
      body: Obx(
        () => PageContentLoader(
          isDataLoading: viewmodel.isLoading.value,
          showContent: true,
          content: ResponsiveWrapper(
            smallScreen: SmallScreenCartDetailPage(viewmodel: viewmodel, widgetFactory: appWidgetFactory),
          ),
        ),
      ),
    );
  }
}
