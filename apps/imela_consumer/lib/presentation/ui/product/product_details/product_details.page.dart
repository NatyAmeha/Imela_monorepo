import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/ui/product/components/product_detail_loading.dart';
import 'package:imela/presentation/ui/product/product_details/product_details.viewmodel.dart';
import 'package:imela/presentation/ui/product/product_details/small_screen_product_detail.dart';
import 'package:imela/presentation/ui/shared/page_loading_utils/page_content_loader.dart';
import 'package:imela/presentation/ui/shared/page_loading_utils/responsive_wrapper.dart';
import 'package:imela/services/routing_service.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class ProductDetailPage extends StatefulWidget {
  static const baseRouteName = '/product';
  static const routeName = '$baseRouteName/:id';

  final ProductDetailsViewmodel? productDetailViewmodel;
  final String productId;
  final String? productName;
  const ProductDetailPage({super.key, this.productDetailViewmodel, required this.productId, this.productName});
  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();

  static void navigate(BuildContext context, IRoutingService router, Product product, {Widget? previousPage}) {
    router.navigateTo(context, '${ProductDetailPage.baseRouteName}/${product.id}', extra: {'name': '${product.name?.localize('ENGLISH')}', GoRouterService.PREVIOUS_PAGE_KEY: previousPage});
  }
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  ProductDetailsViewmodel get viewmodel => widget.productDetailViewmodel ?? Get.put(getIt<ProductDetailsViewmodel>());

  void initializeViewmodel() {
    Future.delayed(Duration.zero, () {
      viewmodel.initViewmodel(data: {'id': widget.productId});
    });
  }

  @override
  void initState() {
    print("bundle detail product product product detail page called");
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
          hasError: viewmodel.exception.value?.isMainError ?? false,
          showContent: viewmodel.productDetails.value != null,
          loadingWidget: const ProductDetailLoadingComponent(),
          content: ResponsiveWrapper(
            smallScreen: SmallScreenProductDetail(viewmodel: viewmodel, widgetFactory: appWidgetFactory),
          ),
          onTryAgain: (){
            viewmodel.getProductDetails(widget.productId);
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    viewmodel.dispose();
    super.dispose();
  }
}
