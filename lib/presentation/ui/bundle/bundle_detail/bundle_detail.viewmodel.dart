import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:imela/data/network/response.model.dart/bundle.reponse.dart';
import 'package:imela/domain/bundle/bundle.usecase.dart';
import 'package:imela/domain/bundle/model/product_bundle.model.dart';
import 'package:imela/domain/product/model/discount.model.dart';
import 'package:imela/domain/product/model/product.model.dart';
import 'package:imela/domain/shared/localized_field.model.dart';
import 'package:imela/presentation/resources/colors.dart';
import 'package:imela/presentation/resources/values.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/bundle/components/bundle_product_config_modal.dart';
import 'package:imela/presentation/ui/factory/widget.factory.dart';
import 'package:imela/presentation/ui/product/product_details/product_details.page.dart';
import 'package:imela/presentation/ui/shared/base_viewmodel.dart';
import 'package:imela/presentation/ui/shared/list/list_componenet.viewmodel.dart';
import 'package:imela/presentation/utils/currency_utils.dart';
import 'package:imela/presentation/utils/date_utils.dart';
import 'package:imela/presentation/utils/exception/app_exception.dart';
import 'package:imela/presentation/utils/number_utils.dart';
import 'package:imela/services/routing_service.dart';

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
  var selectedBundleProducts = Map<String, Product>.of({}).obs; // this can be variant of the main product

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

  var remainingStatusMsg = ''.obs;
  bool get enableBundlePurchase {
    final bool canEnable;
    final condition = bundle?.discount?.condition;
    if (condition == null) {
      remainingStatusMsg.value = '';
      return bundlePrice.isGreaterThan(0);
    }
    final conditionValue = (bundle!.discount!.conditionValue ?? 0.0);
    if (condition == DiscountCondition.MAXIMUM_PURCHASE.name) {
      canEnable = bundlePrice <= conditionValue;
      remainingStatusMsg.value = '${conditionValue - bundlePrice} remaining';
      return canEnable;
    } else if (condition == DiscountCondition.MINIMUM_PURCHASE.name) {
      canEnable = bundlePrice >= (bundle!.discount!.conditionValue ?? 0.0);
      remainingStatusMsg.value = bundlePrice >= conditionValue ? '' : 'ETB ${conditionValue - bundlePrice} remaining';
      return canEnable;
    } else if (condition == DiscountCondition.PURCHASE_ALL_ITEMS.name) {
      final bundleProductsLength = bundle?.products?.length;
      var items = bundleProductsLength == selectedBundleProducts.length;
      remainingStatusMsg.value = 'Purchase all products';
      return items;
    } else {
      return bundlePrice.isGreaterThan(0);
    }
  }

  String get totalProductcount => '${bundleProducts.length} Products';

  String get bundleDescription => bundle?.description?.localize() ?? '';

  String getProductCount() {
    return bundleProducts.length.toString();
  }

  Duration get remainingTime {
        print('diff: ${bundle?.startDate} ${bundle?.endDate}');

    return DateHelper.getDateDifference(startDate: bundle?.startDate, endDate: bundle?.endDate);
  }

  bool get isBundleExpired {
    return remainingTime == Duration.zero;
  }

  double get originalProductPrice {
    final selectedProductPrices = selectedBundleProducts.values.map((product) => product.getPrice().toSelectedPrice()).toList();
    return selectedProductPrices.sumBy((price) => price?.amount ?? 0.0);
  }

  double get bundlePrice {
    var totalAmount = originalProductPrice;
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
      cleanupStateVariable();
      isLoading(true);

      final result = await bundleUsecase.getBundleDetails(bundleId);
      if (!(result?.isSuccessful ?? false)) {
        exception.value = AppException(message: 'Bundle not found', isMainError: true);
        return;
      }
      bundleResponse.value = result;
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
    if(isBundleExpired){
      widgetFactory.showFlashMessage(context, message: 'Bundle expired ', backgroundColor: ColorManager.error);
      return;
    }
    await widgetFactory.createModalBottomSheet(
      context,
      content: (scrollController) {
        return BundleProductConfigModal(
          product: product,
          controller: scrollController,
          widgetFactory: widgetFactory,
          isOptionSelected: (productOption) => isProductConfiguredInBundle(productOption),
          onConfirm: (selectedProduct) {
            router.goBack(context);
            handleBundleProductSelection(product.id!, selectedProduct, replace: true);
          },
        );
      },
    );
  }

  // selected product configuration operation
  bool isProductConfiguredInBundle(Product product) {
    return selectedBundleProducts.values.contains(product);
  }

  void handleBundleProductSelection(String parentProductId, Product product, {bool replace = false}) {
    selectedBundleProducts[parentProductId] = product;
    productListController.items.refresh();
  }

  void removeConfiguredProduct(Product product) {
    selectedBundleProducts.removeWhere((key, value) => value.id == product.id || key == product.id);
    productListController.items.refresh();
  }

  bool isProductSelected(Product product) {
    // update the product list controller
    var isExistInConfiguredList = selectedBundleProducts.values.toList().contains(product) || selectedBundleProducts.keys.contains(product.id);
    return isExistInConfiguredList;
  }

  void cleanupStateVariable() {
    exception.value = null;
    isLoading.value = false;
    bundleResponse.value = null;
    selectedBundleProducts.value = {};
    
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
