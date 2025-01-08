import 'package:collection/collection.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/resources/colors.dart';
import 'package:imela/presentation/resources/values.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/bundle/components/bundle_product_config_modal.dart';
import 'package:imela/presentation/ui/bundle/components/selected_product_from_bundle.list_item.dart';
import 'package:imela/presentation/ui/cart/cart_detail_page.dart';
import 'package:imela/presentation/ui/cart/cart_list.viewmodel.dart';
import 'package:imela/presentation/ui/product/components/product_addon_modal/product_addon_list_modal.dart';
import 'package:imela/presentation/ui/product/product_details/product_details.page.dart';
import 'package:imela/presentation/ui/product/product_details/product_details.viewmodel.dart';
import 'package:imela/presentation/ui/shared/base_viewmodel.dart';
import 'package:imela/presentation/ui/shared/list/list_componenet.viewmodel.dart';
import 'package:imela/presentation/utils/date_utils.dart';
import 'package:imela/presentation/utils/order_utils.dart';
import 'package:imela/presentation/utils/widget_extesions.dart';
import 'package:imela/services/routing_service.dart';
import 'package:imela_core/bundle/model/bundle.response.dart';
import 'package:imela_core/bundle/model/product_bundle.model.dart';
import 'package:imela_core/calendar/dto/calendar.response.dart';
import 'package:imela_core/order/model/order_config.model.dart';
import 'package:imela_core/order/model/order_item.model.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/product/product.usecase.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/components/modal/app_modal_sheet.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/number_utils.dart';
import 'package:injectable/injectable.dart';
import 'package:imela_core/bundle/bundle.usecase.dart';
import 'package:imela_core/order/order.usecase.dart';

@injectable
class BundleDetailViewmodel extends GetxController with BaseViewmodel {
  final BundleUsecase bundleUsecase;
  final OrderUsecase orderUsecase;
  final ProductUsecase productUsecase;
  final IExceptiionHandler exceptiionHandler;
  final IRoutingService router;
  final ProductDetailsViewmodel productDetailsViewmodel;
  BundleDetailViewmodel({
    required this.bundleUsecase,
    required this.orderUsecase,
    required this.productUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
    @Named(GoRouterService.injectName) required this.router,
    required this.productDetailsViewmodel,
  });

  var appViewmodel = AppController.getInstance;
  var cartListViewmodel = CartListViewmodel.getInstance();

  var isLoading = false.obs;
  var exception = Rxn<AppException>();

  var bundleResponse = Rxn<BundleResponse>();
  var selectedBundleProducts = Map<String, Product>.of({}).obs; // this can be variant of the main product
  var additionalItemsByProduct = Map<String, List<OrderItem>>.of({}).obs;
  var productCalendar = Rxn<CalendarResponse>();

  var productOrderConfigs = Map<String, List<OrderConfig>>.of({}).obs;
  Product? parentProduct;

  // getters
  ProductBundle? get bundle => bundleResponse.value?.bundle;
  List<Product> get bundleProducts => bundle?.products ?? [];

  List<OrderItem> get additionallySelectedOrderItems => additionalItemsByProduct.values.toList().flattened.toList();

  // widget controllers
  late CustomListController<Product> productListController;

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    productListController = Get.put(CustomListController<Product>(), tag: 'bundle_products');
    final bundleId = data!['id'] as String;
    getBundleDetails(bundleId);
  }

  List<Discount> get bundleDiscounts => bundle?.discount != null ? [bundle!.discount!] : [];
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
    final conditionValue = double.tryParse(bundle!.discount!.conditionValue ?? '0') ?? 0.0;
    if (condition == DiscountCondition.MAXIMUM_PURCHASE.name) {
      canEnable = selectedBundleProducts.length <= conditionValue;
      remainingStatusMsg.value = '${conditionValue - selectedBundleProducts.length} remaining';
      return canEnable;
    } else if (condition == DiscountCondition.MINIMUM_PURCHASE.name) {
      canEnable = selectedBundleProducts.length >= conditionValue;
      remainingStatusMsg.value = selectedBundleProducts.length >= conditionValue ? '' : '${conditionValue - selectedBundleProducts.length} remaining';
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

  String get bundleDescription => bundle?.description?.localize('ENGLISH') ?? '';

  String getProductCount() {
    return bundleProducts.length.toString();
  }

  Duration get remainingTime {
    return DateHelper.getDateDifference(startDate: bundle?.startDate, endDate: bundle?.endDate);
  }

  bool get isBundleExpired {
    return remainingTime == Duration.zero;
  }

  double get originalProductPrice {
    final selectedProductPrices = selectedBundleProducts.values.map((product) => product.getTotalPriceUpdated(appViewmodel.selectedCurrency.name)).sum;
    return selectedProductPrices;
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
    return totalAmount.isGreaterThan(0) ? totalAmount.getPresision(2) : CurrencyResources.AMOUNT_ZERO;
  }

  String get bundlePriceString => '${appViewmodel.selectedCurrency.name} ${bundlePrice.getPresisionString()}';

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
    ProductDetailPage.navigate(context, router, product);
  }

  void displayBundleProductConfigModal(BuildContext context, Product product, WidgetFactory widgetFactory) async {
    try {
      isLoading(true);
      parentProduct = product;
      if (isBundleExpired) {
        widgetFactory.showFlashMessage(context, message: 'Bundle expired ', backgroundColor: ColorManager.error);
        return;
      }
      if (product.hasVariants()) {
        AppModalSheet.showModal(context, type: AppModalSheetType.BOTTOMSHEET, pages: [
          ModalContent(
            title: widgetFactory.createText(context, 'Configure product', style: Theme.of(context).textTheme.titleMedium),
            content: BundleProductConfigModal(
              product: product,
              widgetFactory: widgetFactory,
              discounts: bundleDiscounts,
              onConfirm: (selectedProduct, qty) {
                AppModalSheet.closeModal();
                showProductConfigModal(context, selectedProduct, widgetFactory);
              },
            ),
          )
        ]);
      } else {
        showProductConfigModal(context, product, widgetFactory);
      }
    } catch (e) {
      print('error in display bundle product config modal $e');
    } finally {
      isLoading(false);
    }
    // await widgetFactory.createModalBottomSheet(
    //   context,
    //   content: (scrollController) {
    //     return BundleProductConfigModal(
    //       product: product,
    //       controller: scrollController,
    //       widgetFactory: widgetFactory,
    //       discounts: bundleDiscounts,
    //       isOptionSelected: (productOption) => isProductConfiguredInBundle(productOption),
    //       onConfirm: (selectedProduct, qty) {
    //         router.goBack(context);
    //         handleBundleProductSelection(product.id!, selectedProduct, qty, replace: true);
    //       },
    //     );
    //   },
    // );
  }

  Future<void> showProductConfigModal(BuildContext context, Product product, WidgetFactory widgetFactory) async {
    var productInfo = bundle?.productsInfo?.firstWhereOrNull((info) => info.productId == parentProduct!.id!);
    var resultMap = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog.fullscreen(
        child: ProductAddonModal(
          productAddons: List.from(parentProduct!.getAddons(forBundle: true)),
          initialOrderConfigs: productOrderConfigs.getOrElse(parentProduct!.id!, () => []),
          productInfo: product.copyWith(),
          callToAction: 'Complete',
          showqtyModfier: true,
          minQty: productInfo?.minQty ?? 1,
          maxQty: productInfo?.maxQty ?? 10,
          discounts: bundleDiscounts,
          productCalendars: productCalendar.value?.calendar != null ? [productCalendar.value!.calendar!] : null,
        ),
      ),
    );
    // var result = await AppModalSheet.showModal<AddonConfig>(
    //   context,
    //   type: AppModalSheetType.BOTTOMSHEET,
    //   pages: [
    //     ModalContent(
    //       title: const Text('Order Configuration'),
    //       content: ProductAddonModal(
    //         productAddons: List.from(product.getAddons()),
    //         initialOrderConfigs: productOrderConfigs.getOrElse(product.id!, () => []),
    //         productInfo: product.copyWith(),
    //         callToAction: 'Complete',
    //         showqtyModfier: true,
    //         minQty: productInfo?.minQty ?? 1,
    //         maxQty: productInfo?.maxQty ?? 10,
    //         discounts: bundleDiscounts,
    //         productCalendars: productCalendar.value?.calendar != null ? [productCalendar.value!.calendar!] : null,
    //       ),
    //     )
    //   ],
    // );
    if (resultMap == null) {
      return;
    }
    final result = resultMap['CONFIG_DATA'] as AddonConfig;
    final selectedQty = result.orderConfigs.getQtyConfigValue();
    final updatedResult = result.removeQtyConfig();
    productOrderConfigs[product.id!] = List<OrderConfig>.from(updatedResult.orderConfigs);
    selectedBundleProducts[parentProduct!.id!] = product.copyWith(qty: selectedQty, addons: parentProduct?.addons);
    // additional items selected from bundle product
    final additionalItems = result.additionalItems;
    if (additionalItems != null) {
      additionalItemsByProduct[product.id!] = additionalItems;
    }

    productListController.items.refresh();
  }

  Future<void> addSelectedProductsToCart(BuildContext context) async {
    try {
      isLoading(true);
      var cartInfo = bundle!.getCartInfo(selectedBundleProducts.values.toList(), productOrderConfigs).addOrderAddons(bundle!.addons ?? []).addOrUpdateItems(additionallySelectedOrderItems);
      cartListViewmodel.addCartToCartList(cartInfo, paymentOptions: bundle!.bundlePaymentOptions());
      appViewmodel.showAddToCartDialog(context, message: 'Bundle added to cart successfully', cart: cartInfo);
    } catch (e) {
      exception.value = exceptiionHandler.getException(e as Exception);
      if (exception.value?.code == ErrorResourceValues.UnAUTHORIZED_EXCEPTION_CODE) {
        AppController.getInstance.refreshTokenOrLogout(context);
      }
    } finally {
      isLoading.value = false;
    }
  }

  // selected product configuration operation
  bool isProductConfiguredInBundle(Product product) {
    return selectedBundleProducts.values.firstWhereOrNull((element) => element.id == product.id) != null;
  }

  void removeConfiguredProduct(Product product) {
    selectedBundleProducts.removeWhere((key, value) => value.id == product.id || key == product.id);
    productOrderConfigs.removeWhere((key, value) => key == product.id);
    additionalItemsByProduct.removeWhere((key, value) => key == product.id);
    productListController.items.refresh();
  }

  List<OrderItem> getAdditionalItems(Product product) {
    return additionalItemsByProduct.getOrElse(product.id!, () => []);
  }

  bool isProductSelected(Product product) {
    // update the product list controller
    var isExistInConfiguredList = (selectedBundleProducts.values.toList().firstWhereOrNull((element) => element.id == product.id!) != null) || selectedBundleProducts.keys.firstWhereOrNull((element) => element == product.id!) != null;
    return isExistInConfiguredList;
  }

  void cleanupStateVariable() {
    exception.value = null;
    isLoading.value = false;
    bundleResponse.value = null;
    selectedBundleProducts.value = {};
    productOrderConfigs.value = {};
    additionalItemsByProduct.value = {};
  }

  @override
  void dispose() {
    exception.value = null;
    bundleResponse.value = null;
    productListController.dispose();
    selectedBundleProducts.clear();
    super.dispose();
  }

  void showSelectedProductsModal(BuildContext context) {
    var widgetFactory = AppController.getInstance.getWidgetFactory(context);
    AppModalSheet.showModal(context, type: AppModalSheetType.BOTTOMSHEET, pages: [
      ModalContent(
        title: const Text('Selected Products'),
        content: Obx(
          () => AppListView(
            shrinkWrap: true,
            header: widgetFactory.createText(context, 'Selected Products', style: Theme.of(context).textTheme.titleMedium).withPaddingSymetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            items: selectedBundleProducts.values.toList(),
            itemBuilder: (context, product, index) {
              final additionalItems = getAdditionalItems(product);
              return SelectedProductFromBundlListItem(
                name: product.name.localize('ENGLISH'),
                image: product.getImageUrl(),
                qty: product.qty,
                additionalItems: additionalItems,
                imageWidth: 100,
                imageHeight: 110,
                price: product.getTotalPriceUpdatedString('ETB', discounts: bundleDiscounts, round: true),
                width: 120,
                widgetFactory: widgetFactory,
                onRemove: () {
                  removeConfiguredProduct(product);
                },
              );
            },
          ),
        ),
      )
    ]);
  }

  void navigateToCartDetailsPage(BuildContext context) {
    if (bundle?.id == null) {
      return;
    }
    final selectedCart = appViewmodel.carts.firstWhereOrNull((element) => element.id == bundle!.id);
    if (selectedCart == null) {
      appViewmodel.getWidgetFactory(context).showFlashMessage(context, message: 'No cart created for this business. Add products from this business first');
      return;
    }
    CartDetailPage.navigateToCartDetailPage(context, router, selectedCart);
  }
}
