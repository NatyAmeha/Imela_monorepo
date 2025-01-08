import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/product/product_details/product_details.page.dart';
import 'package:imela/presentation/ui/product/product_list/product_list_page.dart';
import 'package:imela/presentation/ui/shared/base_viewmodel.dart';
import 'package:imela/presentation/ui/shared/list/list_componenet.viewmodel.dart';
import 'package:imela/services/routing_service.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/product/product.usecase.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:injectable/injectable.dart';

@injectable
class ProductListViewmodel extends GetxController with BaseViewmodel {
  final ProductUsecase productUsecase;
  final IExceptiionHandler exceptiionHandler;
  final IRoutingService router;

  ProductListViewmodel({
    required this.productUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
    @Named(GoRouterService.injectName) required this.router,
  });

  var isLoading = false.obs;
  var exception = Rxn<AppException>();

  var products = Rxn<List<Product>>();

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    var products = data?[ProductListPage.PRODUCT_LIST_KEY] as List<Product>;

    if (products.isNotEmpty) {
      this.products.value = products;
    }
  }

  void navigateToProductDetail(BuildContext context, Product product) {
    ProductDetailPage.navigate(context, router, product);
  }

  @override
  void onInit() {
    super.onInit();
  }

  List<Widget> getActions() {
    return [];
  }

  @override
  void onClose() {
    super.onClose();
  }
}
