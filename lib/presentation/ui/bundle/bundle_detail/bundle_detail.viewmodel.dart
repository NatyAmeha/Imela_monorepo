import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:melegna_customer/data/network/response.model.dart/bundle.reponse.dart';
import 'package:melegna_customer/domain/bundle/bundle.usecase.dart';
import 'package:melegna_customer/domain/bundle/model/product_bundle.model.dart';
import 'package:melegna_customer/domain/product/model/discount.model.dart';
import 'package:melegna_customer/domain/product/model/product.model.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';
import 'package:melegna_customer/presentation/resources/values.dart';
import 'package:melegna_customer/presentation/ui/app_controller.dart';
import 'package:melegna_customer/presentation/ui/bundle/components/bundle_product_config_modal.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/product/product_details/product_details.page.dart';
import 'package:melegna_customer/presentation/ui/shared/base_viewmodel.dart';
import 'package:melegna_customer/presentation/ui/shared/list/list_componenet.viewmodel.dart';
import 'package:melegna_customer/presentation/utils/currency_utils.dart';
import 'package:melegna_customer/presentation/utils/date_utils.dart';
import 'package:melegna_customer/presentation/utils/exception/app_exception.dart';
import 'package:melegna_customer/presentation/utils/number_utils.dart';
import 'package:melegna_customer/services/routing_service.dart';

@injectable
class BundleDetailViewmodel extends GetxController with BaseViewmodel {
  final BundleUsecase bundleUsecase;
  final IExceptiionHandler exceptiionHandler;
  final IRoutingService router;
  BundleDetailViewmodel({
    required this.bundleUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
    @Named(GoRouterService.injectName) required this.router,
  });

  var isLoading = false.obs;
  var exception = Rxn<AppException>();

  var bundleResponse = Rxn<BundleResponse>();
  var selectedBundleProducts = <Product>[].obs;

  // getters
  ProductBundle? get bundle => bundleResponse.value?.bundle;
  List<Product> get bundleProducts => bundle?.products ?? [];

  // widget controllers
  late CustomListController<Product> productListController;

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    print("bundle detail viewmodel called");
    super.initViewmodel(data: data);
    productListController = Get.put(CustomListController<Product>(), tag: 'bundle_products');
    final bundleId = data!['id'] as String;
    getBundleDetails(bundleId);
  }

  String get getDiscountValue => bundle?.discount != null ? bundle!.discount!.getDiscountValueString(AppController.getInstance.selectedCurrency.name) : '';
  String? get discountCondition => bundle?.discount != null ? bundle!.discount!.getDiscountConditionDescription(AppController.getInstance.selectedCurrency.name) : '';
  bool get enableBundlePurchase {
    final condition = bundle?.discount?.condition;
    final totalPrice = calculateBundlePrice();
    if (condition == null) {
      return totalPrice.isGreaterThan(0);
    }
    if (condition == DiscountCondition.MAXIMUM_PURCHASE.name) {
      return totalPrice <= (bundle!.discount!.conditionValue ?? 0.0);
    } else if (condition == DiscountCondition.MINIMUM_PURCHASE.name) {
      return totalPrice >= (bundle!.discount!.conditionValue ?? 0.0);
    } else if (condition == DiscountCondition.PURCHASE_ALL_ITEMS.name) {
      final bundleProductsLength = bundle?.products?.length;
      var items = bundleProductsLength == selectedBundleProducts.length;
      return items;
    } else {
      return totalPrice.isGreaterThan(0);
    }
  }

  String get getBundlePrice {
    final totalAmount = calculateBundlePrice();
    final currency = AppController.getInstance.selectedCurrency.name;
    return ' $currency ${totalAmount.toPrecision(2)}';
  }

  String get totalProductcount => '${bundleProducts.length} Products';

  String get bundleDescription => bundle?.description?.localize() ?? '';

  String getProductCount() { 
    return bundleProducts.length.toString(); 
  }

  Duration getRemainingTime() {
    return DateHelper.getDateDifference(startDate: bundle?.startDate, endDate: bundle?.endDate);
  }

  double calculateBundlePrice() {
    final selectedProductPrices = selectedBundleProducts.map((product) => product.getPrice().toSelectedPrice()).toList();
    var totalAmount = selectedProductPrices.sumBy((price) => price?.amount ?? 0.0);

    final discountValue = bundle?.discount?.value;
    if (discountValue != null) {
      if (bundle!.discount!.type == DiscountType.PERCENTAGE.name) {
        totalAmount = totalAmount.getPercentage(discountValue);
      } else {
        totalAmount = totalAmount.minus(discountValue)!;
      }
    }
    return totalAmount.isGreaterThan(0) ? totalAmount : CurrencyResources.AMOUNT_ZERO;
  }

  // data operation
  Future<void> getBundleDetails(String bundleId) async {
    try {
      isLoading(true);
      bundleResponse.value = await bundleUsecase.getBundleDetails(bundleId);
      productListController.setItems(bundleProducts);
    } on AppException catch (e) {
      exception.value = e;
    } catch (e) {
      exception.value = AppException.unexpectedError(e);
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToProductDetailPage(BuildContext context, Product product, {Widget? previousPage}) {
    ProductDetailPage.navigate(context, router, product, previousPage: previousPage);
  }

  void displayBundleProductConfigModal(BuildContext context, Product product, WidgetFactory widgetFactory) async {
    await widgetFactory.createModalBottomSheet(
      context,
      content: (scrollController) {
        return BundleProductConfigModal(
          product: product,
          controller: scrollController,
          widgetFactory: widgetFactory,
          onConfirm: (selectedProduct) {
            router.goBack(context);
            handleBundleProductSelection(selectedProduct, replace: true);
          },
        );
      },
    );
  }

  void handleBundleProductSelection(Product product, {bool replace = false}) {
    final index = selectedBundleProducts.indexWhere((element) => element.id == product.id);
    if (index == -1) {
      selectedBundleProducts.add(product);
    } else {
      if (replace) {
        selectedBundleProducts[index] = product;
      } else {
        selectedBundleProducts.removeAt(index);
      }
    }
  }

  @override
  void dispose() {
    exception.value = null;
    bundleResponse.value = null;
    productListController.dispose();
    selectedBundleProducts.clear();
    super.dispose();
  }
}
