import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/cart/cart_list.viewmodel.dart';
import 'package:imela/presentation/ui/cart/small_cart_list_screen.dart';
import 'package:imela/presentation/ui/shared/page_loading_utils/page_content_loader.dart';
import 'package:imela/presentation/ui/shared/page_loading_utils/responsive_wrapper.dart';

class CartListPage extends StatefulWidget {
  static const routeName = '/carts';

  @override
  State<CartListPage> createState() => _CartListPageState();

  static void navigate(BuildContext context) {
    final router = AppController.getInstance.router;
    router.navigateTo(context, routeName);
  }
}

class _CartListPageState extends State<CartListPage> {
  CartListViewmodel get cartListViewmodel => CartListViewmodel.getInstance();

  @override
  void initState() {
    super.initState();
    cartListViewmodel.initViewmodel(data: {'context': context});
  }

  @override
  Widget build(BuildContext context) {
    final appWidgetFactory = AppController.getInstance.getWidgetFactory(context);
    return Scaffold(
      body: Obx(
        () => PageContentLoader(
          isDataLoading: cartListViewmodel.isLoading.value,
          hasError: cartListViewmodel.exception.value?.isMainError ?? false,
          showContent:true,
          exception: cartListViewmodel.exception.value,
          onTryAgain: () {
            // initializeViewmodel(context);
          },
          content: ResponsiveWrapper(
            smallScreen: SmallCartListScreen(viewmodel: cartListViewmodel, widgetFactory: appWidgetFactory),
          ),
        ),
      ),
    );
  }
}
