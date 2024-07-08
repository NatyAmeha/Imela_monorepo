import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:melegna_customer/data/network/response.model.dart/bundle.reponse.dart';
import 'package:melegna_customer/domain/bundle/bundle.usecase.dart';
import 'package:melegna_customer/domain/bundle/model/product_bundle.model.dart';
import 'package:melegna_customer/domain/product/model/discount.model.dart';
import 'package:melegna_customer/domain/product/model/product.model.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';
import 'package:melegna_customer/presentation/ui/product/product_details/product_details.page.dart';
import 'package:melegna_customer/presentation/ui/shared/base_viewmodel.dart';
import 'package:melegna_customer/presentation/ui/shared/list/list_componenet.viewmodel.dart';
import 'package:melegna_customer/presentation/utils/exception/app_exception.dart';
import 'package:melegna_customer/presentation/utils/localization_utils.dart';
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

  // getters
  ProductBundle? get bundle => bundleResponse.value?.bundle;
  List<Product> get bundleProducts => bundle?.products ?? [];

  // widget controllers
  late final CustomListController<Product> productListController;

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    productListController = Get.put(CustomListController<Product>(), tag: 'bundle_products');
    final bundleId = data!['id'] as String;
    getBundleDetails(bundleId);
  }

  String? get getDiscountValue {
    if (bundle?.discount != null) {
      if (bundle!.discount!.type == DiscountType.PERCENTAGE.name) {
        return '${bundle!.discount!.value}%';
      }
      return '${bundle!.discount!.value} Birr';
    }
    return null;
  }

  String? get discountCondition {
    if (bundle?.discount != null) {
      if (bundle!.discount!.condition == DiscountCondition.MAXIMUM_PURCHASE.name) {
        return 'on orders above ${bundle!.discount!.conditionValue} Birr';
      } else if (bundle!.discount!.condition == DiscountCondition.MINIMUM_PURCHASE.name) {
        return 'on orders above ${bundle!.discount!.conditionValue} Birr';
      } else if (bundle!.discount!.condition == DiscountCondition.QUANTITY.name) {
        return 'on orders above ${bundle!.discount!.conditionValue} Birr';
      } else if (bundle!.discount!.condition == DiscountCondition.PURCHASE_ALL_ITEMS.name) {
        return 'on purchase of all items in the bundle';
      } else {
        return null;
      }
    }
    return null;
  }

  String get totalProductcount {
    return '${bundleProducts.length} Products';
  }

  String get bundleDescription => bundle?.description?.getLocalizedValue(AppLanguage.ENGLISH.name) ?? '';

  String getProductCount() {
    return bundleProducts.length.toString();
  }

  String get getBundlePrice {
    // discount calculation logic goes here
    return '100 Birr';
  }

  // data operation
  Future<void> getBundleDetails(String bundleId) async {
    try {
      isLoading(true);
      bundleResponse.value = await bundleUsecase.getBundleDetails(bundleId);
      productListController.addItems(bundleProducts);
    } on AppException catch (e) {
      exception.value = e;
    } catch (e) {
      exception.value = AppException.unexpectedError(e);
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToProductDetailPage(BuildContext context, Product product) {
    ProductDetailPage.navigateToProductDetailPage(context, router, product);
  }

  @override
  void dispose() {
    exception.value = null;
    bundleResponse.value = null;
    productListController.dispose();
    super.dispose();
  }
}
