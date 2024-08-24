import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melegna_customer/domain/product/model/product.model.dart';
import 'package:melegna_customer/injection.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/product/components/grid_product_list_item.component.dart';
import 'package:melegna_customer/presentation/ui/product/components/product_list_item.dart';
import 'package:melegna_customer/presentation/ui/product/product_list/product_list.viewmodel.dart';
import 'package:melegna_customer/presentation/ui/shared/list/gridview.component.dart';
import 'package:melegna_customer/presentation/ui/shared/list/list_display_style.constants.dart';
import 'package:melegna_customer/presentation/ui/shared/list/listview.component.dart';
import 'package:melegna_customer/presentation/ui/shared/page_loading_utils/page_content_loader.dart';

class ProductListPage extends StatefulWidget {
  static const baseRouteName = '/products';
  static const routeName = '$baseRouteName/:query';

  final ProductListViewmodel? productListViewmodel;
  final String title;
  final List<Product>? products;
  final ListDisplayStyle displayStyle;
  const ProductListPage({
    super.key,
    required this.title,
    this.productListViewmodel,
    this.products,
    required this.displayStyle,
  });

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  ProductListViewmodel get viewmodel => widget.productListViewmodel ?? Get.put(getIt<ProductListViewmodel>());
  late WidgetFactory appWidgetFactory;
  void initializeViewmodel() {
    Future.delayed(Duration.zero, () {
      viewmodel.initViewmodel(data: {'products': widget.products});
    });
  }

  @override
  void initState() {
    super.initState();
    initializeViewmodel();
  }

  @override
  Widget build(BuildContext context) {
    appWidgetFactory = WidgetFactory(Theme.of(context).platform);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: viewmodel.getActions(),
      ),
      body: Obx(
        () => PageContentLoader(
          isDataLoading: viewmodel.isLoading.value,
          showContent: viewmodel.productListController.items.isNotEmpty,
          hasError: viewmodel.exception.value?.isMainError ?? false,
          content: widget.displayStyle == ListDisplayStyle.Grid
              ? AppGridView(
                  controller: viewmodel.productListController,
                  isStaggered: true,
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (context, product, index) {
                    return GridProductListItem(
                      product: product,
                      widgetFactory: appWidgetFactory,
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
                  controller: viewmodel.productListController,
                  itemBuilder: (context, product, index) {
                    return VerticalProductListItem(
                      product: product,
                      imageHeight: 140,
                      imageWidth: 125,
                      widgetFactory: appWidgetFactory,
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
