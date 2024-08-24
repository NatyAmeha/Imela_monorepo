import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:melegna_customer/domain/product/model/product.model.dart';
import 'package:melegna_customer/domain/product/product.usecase.dart';
import 'package:melegna_customer/presentation/ui/product/product_details/product_details.page.dart';
import 'package:melegna_customer/presentation/ui/shared/base_viewmodel.dart';
import 'package:melegna_customer/presentation/ui/shared/list/list_componenet.viewmodel.dart';
import 'package:melegna_customer/presentation/utils/exception/app_exception.dart';
import 'package:melegna_customer/services/routing_service.dart';

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
  final productListController = Get.put(CustomListController<Product>(), tag: 'productListPageList');

  var isLoading = false.obs;
  var exception = Rxn<AppException>();

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    productListController.items.clear();
    var products = data?['products'] as List<Product>;
    if (products.isNotEmpty) {
      productListController.addItems(products);
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
