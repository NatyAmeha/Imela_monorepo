import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/resources/values.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/cart/cart_detail_page.dart';
import 'package:imela/presentation/ui/cart/cart_list_page.dart';
import 'package:imela/presentation/ui/product/components/product_features_list.dart';
import 'package:imela/presentation/ui/product/components/product_order_config_modal.dart';
import 'package:imela/presentation/ui/shared/base_viewmodel.dart';
import 'package:imela/presentation/ui/shared/list/list_componenet.viewmodel.dart';
import 'package:imela/presentation/utils/order_utils.dart';
import 'package:imela/presentation/utils/string_utils.dart';
import 'package:imela/services/routing_service.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_core/business/model/payment_option.model.dart';
import 'package:imela_core/order/model/order_config.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/product/model/product_response.dart';
import 'package:imela_core/shared/gallery.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:injectable/injectable.dart';

import 'package:imela_core/product/product.usecase.dart';
import 'package:imela_core/order/order.usecase.dart';

@injectable
class ProductDetailsViewmodel extends GetxController with BaseViewmodel {
  final ProductUsecase productUsecase;
  final OrderUsecase orderUsecase;
  final IExceptiionHandler exceptiionHandler;
  final IRoutingService router;

  ProductDetailsViewmodel({
    required this.productUsecase,
    required this.orderUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
    @Named(GoRouterService.injectName) required this.router,
  });

  final appController = AppController.getInstance;

  // page state variables
  final isLoading = false.obs;
  final exception = Rxn<AppException>();

  final productDetails = Rxn<ProductResponse>();
  Product get selectedProduct => selectedProductOption.value ?? productDetails.value!.product!;
  String get productName => productDetails.value?.product?.name.localize('ENGLISH') ?? '';
  String get getProductDescription => productDetails.value?.product?.description?.localize('ENGLISH') ?? '';
  List<String> get getProductImage => productDetails.value!.product?.gallery?.getImages() ?? [];
  Business get businessInfo => productDetails.value!.product!.business!;
  List<PaymentOption> get productPaymentOption => productDetails.value?.product?.business?.paymentOptions ?? [];

  var isAppbarExpanded = true.obs;

  var selectedProductQty = 1.0.obs;

  var selectedProductOption = Rxn<Product>();
  bool get isOptionSelected => productOptions.isNotEmpty ? selectedProductOption.value != null : true;
  bool isProductOptionSelected(Product product) => selectedProductOption.value?.id == product.id;

  var productOrderConfig = <OrderConfig>[].obs;
  void addOrUpdateOrderConfig(OrderConfig config) {
    final index = productOrderConfig.indexWhere((element) => element.addonId == config.addonId);
    if (index != -1) {
      productOrderConfig[index] = config;
    } else {
      productOrderConfig.add(config);
    }
  }

  OrderConfig? getAddonOrderConfig(String addonId) {
    return productOrderConfig.firstWhereOrNull((config) => config.addonId == addonId);
  }

  bool get canEnableAddonContinueBtn {
    final requiredAddons = productInfo?.addons?.where((addon) => addon.isRequired);
    if (requiredAddons.isBlank == true) {
      return true;
    }
    return requiredAddons?.any((addon) {
          return productOrderConfig.isContainAddonId(addon.id!);
        }) ??
        true;
  }

  List<Product> get productOptions => productDetails.value?.variants ?? [];
  Product? get productInfo => productDetails.value?.product;

  void selectProductOption(Product product) {
    selectedProductOption.value = product;
  }

  // widget Controllers
  final productOptionListController = Get.put(CustomListController<Product>(), tag: 'productOptionList');
  late ScrollController productHeaderScrollController;

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    print('product detail product viewmodel called');
    super.initViewmodel(data: data);
    productHeaderScrollController = ScrollController();

    final productId = data!['id'] as String;
    getProductDetails(productId);
  }

  void listenAppbarHeaderScroll() {
    productHeaderScrollController.addListener(() {
      if (productHeaderScrollController.offset > 220) {
        isAppbarExpanded(true);
      } else if (productHeaderScrollController.offset <= 220) {
        isAppbarExpanded(false);
      }
    });
  }

  // data fetching
  Future<void> getProductDetails(String productId) async {
    try {
      cleanupStateVariables();
      isLoading(true);
      final response = await productUsecase.getProductDetails(productId);
      productDetails.value = response;

      selectedProductQty.value = (productDetails.value?.product?.minimumOrderQty.toDouble() ?? 1.0);
      if (productOptions.isNotEmpty) {
        productOptionListController.addItems(productOptions);
      }
      final defaulttAddons = productInfo?.getDefaultAddonValue();
      productOrderConfig.addAll(defaulttAddons ?? []);
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
      ProductFeature(name: 'Order online'),
      ProductFeature(name: 'Free delivery', icon: Icons.delivery_dining),
      ProductFeature(name: 'Cash on delivery', icon: Icons.money_rounded),
      ProductFeature(name: 'Pay online'),
    ];
    return list;
  }

  void handleJourney(BuildContext context, WidgetFactory widgetFactory) async {
    double screenHeight = MediaQuery.sizeOf(context).height;
    const double addonWidgetHeight = 100.0;

    // Calculate the total height required for all addons
    double totalHeight = productInfo!.addons!.length * addonWidgetHeight + 200;

    // Normalize the height to a value between 0 and 1
    double normalizedHeight = totalHeight / screenHeight;
    normalizedHeight = normalizedHeight.clamp(0.0, 1.0);
    print('normalized height $normalizedHeight');
    normalizedHeight = normalizedHeight <= 0.5 ? 0.52 : normalizedHeight;
    var initialHeight = normalizedHeight <= 0.85 ? normalizedHeight : 0.5;

    await widgetFactory.createModalBottomSheet(
      context,
      content: (scrollController) => Obx(
        () => ProductOrderConfigModal(
          product: productInfo!,
          qty: selectedProductQty.value,
          widgetFactory: widgetFactory,
          scrollController: scrollController,
          productDetailsViewmodel: this,
          onQtyChange: (newQtyValue) {
            if (productInfo?.canOrderWithQty(newQtyValue) == true) {
              selectedProductQty(newQtyValue);
            }
          },
          onContinue: () async {
            await router.goBack(context);
            addtoCart(context);
          },
        ),
      ),
      initialHeight: initialHeight,
      maxHeight: normalizedHeight,
    );
  }

  Future<void> addtoCart(BuildContext context) async {
    try {
      isLoading(true);
      final item = selectedProduct.getOrderItem(selectedProductQty.value, config: productOrderConfig.value);
      final result = await orderUsecase.addToCart(businessInfo.id!, businessInfo.name!, [item], paymentOptions: productPaymentOption);
      if (result?.success == true && result?.cart != null) {
        final updatedCart = result!.cart!.addPaymentOption(productPaymentOption);
        AppController.getInstance.addCartToCartList(updatedCart, paymentOptions: productPaymentOption);
        appController.getWidgetFactory(context).showFlashMessage(context, message: 'Item added to cart', actionText: 'View cart', onActinClicked: () {
          CartDetailPage.navigateToCartDetailPage(context, router, updatedCart);
        });
      }
    } catch (e) {
      exception.value = exceptiionHandler.getException(e as Exception);
      print(' add to cart exception  ${exception.value?.code} ----- ${e.toString()}');
      if (exception.value?.code == ErrorResourceValues.UnAUTHORIZED_EXCEPTION_CODE) {
        navigateToLoginPage(context);
      }
    } finally {
      isLoading.value = false;
    }
  }

void navigateToLoginPage(BuildContext context) {
    router.navigateTo(context, CartListPage.routeName);
  }

  void handleAddonDateSelection(BuildContext context, ProductAddon addon, WidgetFactory widgetFactory) async {
    final selectedDateRange = getAddonOrderConfig(addon.id!)?.multipleValue.toDateRange();
    final pickedDate = await widgetFactory.showDateRangePickerUI(context, initialDateRange: selectedDateRange);
    if (pickedDate != null) {
      final config = OrderConfig.createDateRangeOrderConfig(addon.name!, pickedDate, addon);
      addOrUpdateOrderConfig(config);
    }
  }

  void handleProductAddonsingleSelection(BuildContext context, ProductAddon addon, {required String value, required WidgetFactory widgetFactory}) async {
    final config = OrderConfig.createSingleSelectOrderConfig(addon.name!, value, addon);
    productOrderConfig.add(config);
  }

  void handleProductAddonQtyChange(BuildContext context, ProductAddon addon, {required double value, required WidgetFactory widgetFactory}) async {
    final config = OrderConfig.createNumberInputOrderConfig(addon.name!, value, addon);
    addOrUpdateOrderConfig(config);
  }

  void cleanupStateVariables() {
    productOrderConfig.clear();
    selectedProductOption(null);
    exception.value = null;
    productDetails.value = null;
    productOptionListController.items.clear();
  }

  @override
  void dispose() {
    print('disposing product details viewmodel');
    exception.value = null;
    productDetails.value = null;
    selectedProductOption.value = null;
    isLoading(false);
    productOptionListController.dispose();
    super.dispose();
  }
}
