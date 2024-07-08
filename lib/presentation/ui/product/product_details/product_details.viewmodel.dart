import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:melegna_customer/data/network/product_response.dart';
import 'package:melegna_customer/domain/product/model/product.model.dart';
import 'package:melegna_customer/domain/product/product.usecase.dart';
import 'package:melegna_customer/domain/shared/gallery.model.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/product/components/product_addon_modal.dart';
import 'package:melegna_customer/presentation/ui/product/components/product_features_list.dart';
import 'package:melegna_customer/presentation/ui/shared/base_viewmodel.dart';
import 'package:melegna_customer/presentation/ui/shared/list/list_componenet.viewmodel.dart';
import 'package:melegna_customer/presentation/utils/exception/app_exception.dart';
import 'package:melegna_customer/presentation/utils/localization_utils.dart';
import 'package:melegna_customer/services/routing_service.dart';

@injectable
class ProductDetailsViewmodel extends GetxController with BaseViewmodel {
  final ProductUsecase productUsecase;
  final IExceptiionHandler exceptiionHandler;
  final IRoutingService router;

  ProductDetailsViewmodel({
    required this.productUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
    @Named(GoRouterService.injectName) required this.router,
  });

  // page state variables
  final productDetails = Rxn<ProductResponse>();
  final isLoading = false.obs;
  final exception = Rxn<AppException>();

  var isAppbarExpanded = true.obs;

  var selectedProductOption = Rxn<Product>();

  // getter
  List<Product> get productOptions => productDetails.value?.variants ?? [];
  Product? get productInfo => productDetails.value?.product;

  bool isProductOptionSelected(Product product) {
    return selectedProductOption.value?.id == product.id;
  }

  String get getProductName {
    return selectedProductOption.value?.name.getLocalizedValue(AppLanguage.ENGLISH.name) ?? '${productDetails.value?.product?.getLocalizedProductName(AppLanguage.ENGLISH.name)}';
  }

  String get getProductDescription {
    return '${productDetails.value?.product?.description?.getLocalizedValue(AppLanguage.ENGLISH.name)}';
  }

  List<String> get getProductImage {
    return productDetails.value!.product?.gallery?.getImages() ?? [];
  }

  // widget Controllers
  final productOptionListController = Get.put(CustomListController<Product>(), tag: 'productOptionList');
  late ScrollController productHeaderScrollController;

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    productHeaderScrollController = ScrollController();
    final productId = data!['id'] as String;
    getProductDetails(productId);
  }

  void listenAppbarHeaderScroll() {
    productHeaderScrollController.addListener(() {
      if (productHeaderScrollController.offset > 250) {
        isAppbarExpanded(false);
      } else if (productHeaderScrollController.offset <= 250) {
        isAppbarExpanded(true);
      }
    });
  }

  // data fetching
  Future<void> getProductDetails(String productId) async {
    try {
      isLoading(true);
      productDetails.value = await productUsecase.getProductDetails(productId);
      if (productOptions.isNotEmpty) {
        productOptionListController.addItems(productOptions);
        selectedProductOption(productOptions.firstOrNull);
      }
    } on AppException catch (e) {
      exception.value = e;
    } catch (e) {
      exception.value = AppException.unexpectedError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // view helper methods

  List<ProductFeature> getProductFeatures() {
    var list = <ProductFeature>[
      ProductFeature(name: "Order online"),
      ProductFeature(name: "Free delivery", icon: Icons.delivery_dining),
      ProductFeature(name: "Cash on delivery", icon: Icons.money_rounded),
      ProductFeature(name: "Pay online"),
    ];
    return list;
  }

  handleJourney(BuildContext context, WidgetFactory widgetFactory) async {
    if (productInfo?.addons?.isNotEmpty == true) {
      await widgetFactory.createModalBottomSheet(context, content: ProductAddonModal(widgetFactory: widgetFactory, addons: productInfo!.addons!));
    }
  }

  @override
  void dispose() {
    print("disposing product details viewmodel");
    exception.value = null;
    productDetails.value = null;
    selectedProductOption.value = null;
    isLoading(false);
    productOptionListController.dispose();
    super.dispose();
  }
}
