import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/cart/cart_list.viewmodel.dart';
import 'package:imela/presentation/ui/cart/small_screen_cart_detail_page.dart';
import 'package:imela/presentation/ui/shared/page_loading_utils/page_content_loader.dart';
import 'package:imela/presentation/ui/shared/page_loading_utils/responsive_wrapper.dart';
import 'package:imela/services/routing_service.dart';
import 'package:imela_core/order/model/cart.model.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class CartDetailPage extends StatefulWidget {
  final Cart selectedCart;
  static const baseRouteName = '/cart';
  static const routeName = '$baseRouteName/:id';

  static const CART_DATA = 'cart';

  static void navigateToCartDetailPage(BuildContext context, IRoutingService router, Cart cart) {
    router.navigateTo(context, CartDetailPage.routeName, extra: {CartDetailPage.CART_DATA: cart});
  }

  CartDetailPage({super.key, required this.selectedCart});

  @override
  State<CartDetailPage> createState() => _CartDetailPageState();
}

class _CartDetailPageState extends State<CartDetailPage> {
  var viewmodel = CartListViewmodel.getInstance();

  @override
  void initState() {
    super.initState();
    viewmodel.seselectedCart(widget.selectedCart);
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
