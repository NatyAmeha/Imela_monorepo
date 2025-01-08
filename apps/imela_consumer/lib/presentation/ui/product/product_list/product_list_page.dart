import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/product/components/grid_product_list_item.component.dart';
import 'package:imela/presentation/ui/product/components/product_item_badge.dart';
import 'package:imela/presentation/ui/product/components/product_list_item.dart';
import 'package:imela/presentation/ui/product/product_list/product_list.viewmodel.dart';
import 'package:imela/presentation/ui/shared/list/list_display_style.constants.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_ui_kit/components/list/gridview.component.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class ProductListPage extends StatefulWidget {
  static const baseRouteName = '/products';
  static const routeName = '$baseRouteName/:query';

  static const PRODUCT_LIST_KEY = 'productList';
  static const TITLE_KEY = 'title';

  final ProductListViewmodel? productListViewmodel;
  final String title;
  final List<Product>? products;
  const ProductListPage({
    super.key,
    required this.title,
    this.productListViewmodel,
    this.products,
  });

  @override
  State<ProductListPage> createState() => _ProductListPageState();

  static navigate(BuildContext context, {List<Product> products = const [], ProductListViewmodel? productListViewmodel, String title = ''}) {
    final router = AppController.getInstance.router;
    router.navigateTo(context, routeName, extra: {ProductListPage.PRODUCT_LIST_KEY: products, ProductListPage.TITLE_KEY: title});
  }
}

class _ProductListPageState extends State<ProductListPage> {
  ProductListViewmodel get viewmodel => widget.productListViewmodel ?? Get.put(getIt<ProductListViewmodel>());
  late WidgetFactory widgetFactory;
  void initializeViewmodel() {
    Future.delayed(Duration.zero, () {
      viewmodel.initViewmodel(data: {ProductListPage.PRODUCT_LIST_KEY: widget.products, ProductListPage.TITLE_KEY: widget.title});
    });
  }

  @override
  void initState() {
    super.initState();
    initializeViewmodel();
  }

  @override
  Widget build(BuildContext context) {
    widgetFactory = WidgetFactory(Theme.of(context).platform);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: viewmodel.getActions(),
      ),
      body: Obx(
        () => PageContentLoader(
          isLoading: viewmodel.isLoading.value,
          showContent: viewmodel.products.value?.isNotEmpty ?? false,
          exception: viewmodel.exception.value,
          hasError: viewmodel.exception.value?.isMainError ?? false,
          content: Responsive.isLargeOrMediumScreen(context)
              ? AppGridView(
                  items: viewmodel.products.value ?? [],
                  isStaggered: true,
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (context, product, index) {
                    return GridProductListItem(
                      product: product,
                      widgetFactory: widgetFactory,
                      imageHeight: 150,
                      imageWidth: double.infinity,
                      badgeInfos: ProductBadgeInfo.getProductBadgeInfo(product),
                      discounts: product.getBusinessDiscounts(),
                      onTap: () {
                        viewmodel.navigateToProductDetail(context, product);
                      },
                    );
                  },
                )
              : AppListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  scrollDirection: Axis.vertical,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  items: viewmodel.products.value ?? [],
                  itemBuilder: (context, product, index) {
                    return VerticalProductListItem(
                      product: product,
                      imageHeight: 140,
                      imageWidth: 125,
                      widgetFactory: widgetFactory,
                      onTap: () {
                        viewmodel.navigateToProductDetail(context, product);
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}
