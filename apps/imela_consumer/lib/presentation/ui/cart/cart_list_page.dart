import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/ui/cart/cart_list.viewmodel.dart';
import 'package:imela/presentation/ui/cart/small_cart_list_screen.dart';
import 'package:imela/presentation/ui/shared/page_loading_utils/page_content_loader.dart';
import 'package:imela/presentation/ui/shared/page_loading_utils/responsive_wrapper.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class CartListPage extends StatefulWidget {
  static const routeName = '/carts';
  late CartListViewmodel? cartListViewmodel;

  CartListPage({super.key, this.cartListViewmodel}) {
    cartListViewmodel ??= Get.put(getIt<CartListViewmodel>());
  }

  @override
  State<CartListPage> createState() => _CartListPageState();
}

class _CartListPageState extends State<CartListPage> {
  CartListViewmodel get viewmodel => widget.cartListViewmodel!;

  void initializeViewmodel(BuildContext context) {
    Future.delayed(Duration.zero, () {
      widget.cartListViewmodel!.initViewmodel(data: {'context': context});
    });
  }

  @override
  void initState() {
    super.initState();
    initializeViewmodel(context);
  }

  @override
  Widget build(BuildContext context) {
    final appWidgetFactory = WidgetFactory(Theme.of(context).platform);
    return Scaffold(
      body: Obx(
        () => PageContentLoader(
          isDataLoading: viewmodel.isLoading.value,
          hasError: viewmodel.exception.value?.isMainError ?? false,
          showContent: viewmodel.isCartFetchSuccessfull.value,
          exception: viewmodel.exception.value,
          onTryAgain: () {
            initializeViewmodel(context);
          },
          content: ResponsiveWrapper(
            smallScreen: SmallCartListScreen(viewmodel: viewmodel, widgetFactory: appWidgetFactory),
          ),
        ),
      ),
    );
  }
}
