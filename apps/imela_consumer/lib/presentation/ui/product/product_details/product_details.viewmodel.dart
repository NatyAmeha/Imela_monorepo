import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/resources/values.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/cart/cart_detail_page.dart';
import 'package:imela/presentation/ui/cart/cart_list.viewmodel.dart';
import 'package:imela/presentation/ui/cart/cart_list_page.dart';
import 'package:imela/presentation/ui/membership/membership_detail/membership_detail_page.dart';
import 'package:imela/presentation/ui/product/components/product_addon_modal/product_addon_list_modal.dart';
import 'package:imela/presentation/ui/product/components/product_features_list.dart';
import 'package:imela/presentation/ui/shared/base_viewmodel.dart';
import 'package:imela/presentation/ui/shared/list/list_componenet.viewmodel.dart';
import 'package:imela/presentation/utils/order_utils.dart';
import 'package:imela/presentation/utils/widget_extesions.dart';
import 'package:imela/services/routing_service.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_core/business/model/payment_option.model.dart';
import 'package:imela_core/calendar/dto/calendar.response.dart';
import 'package:imela_core/calendar/model/calendar.model.dart';
import 'package:imela_core/calendar/model/calendar_booking.model.dart';
import 'package:imela_core/membership/membership_usecase.dart';
import 'package:imela_core/order/model/order_config.model.dart';
import 'package:imela_core/order/model/order_item.model.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/product/model/product_response.dart';
import 'package:imela_core/shared/gallery.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_ui_kit/components/image/photo_viewer/photo_viewer.dart';
import 'package:imela_ui_kit/components/modal/app_modal_sheet.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:injectable/injectable.dart';

import 'package:imela_core/product/product.usecase.dart';
import 'package:imela_core/order/order.usecase.dart';

@injectable
class ProductDetailsViewmodel extends GetxController with BaseViewmodel {
  final ProductUsecase productUsecase;
  final OrderUsecase orderUsecase;
  final MembershipUseCase membershipUseCase;
  final IExceptiionHandler exceptiionHandler;
  final IRoutingService router;

  ProductDetailsViewmodel({
    required this.productUsecase,
    required this.orderUsecase,
    required this.membershipUseCase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
    @Named(GoRouterService.injectName) required this.router,
  });

  final cartListViewmodel = CartListViewmodel.getInstance();

  // page state variables
  final isLoading = false.obs;
  final isSecondaryLoading = false.obs;
  final exception = Rxn<AppException>();

  final productDetails = Rxn<ProductResponse>();
  final productCalendarResponse = Rxn<CalendarResponse>();
  final productSchedules = <CalendarBooking>[].obs;

  // final disabledDatesForBooking = <DateTime>[].obs;

  var isAppbarExpanded = true.obs;
  var selectedProductQty = 1.0.obs;
  var selectedProductOption = Rxn<Product>();
  var discounts = <Discount>[].obs;

  var productOrderConfig = <OrderConfig>[].obs;

  // getters
  final appController = AppController.getInstance;
  String get selectedLanguage => appController.selectedLanguageUpdated.value;
  String get selectedCurrency => appController.selectedCurrency.name;

  Product? get originalProductInfo => productDetails.value?.product;
  Product get selectedProduct => selectedProductOption.value ?? originalProductInfo!;
  String get selectedProductUnit => selectedProduct.inventory?.firstOrNull?.unit ?? 'Unit';
  List<Product> get productOptions => originalProductInfo?.variants ?? [];

  String get productName => productDetails.value?.product?.name.localize('ENGLISH') ?? '';
  String get getProductDescription => productDetails.value?.product?.description?.localize('ENGLISH') ?? '';
  List<String> get getProductImage => selectedProduct.gallery?.getImages() ?? [];
  Business? get businessInfo => productDetails.value!.product?.business;
  List<PaymentOption> get productPaymentOption => productDetails.value?.product?.business?.paymentOptions ?? [];

  bool get isOptionSelected => productOptions.isNotEmpty ? selectedProductOption.value != null : true;
  double get totalAddonPrice => productOrderConfig.sumBy((addon) => addon.additionalPrice);

  bool get isCurrentUserMember => currentUserIsMember(originalProductInfo?.membershipIds ?? []);
  bool get isCurrentUserSubscriptionForProductMembershipActive => originalProductInfo?.membershipIds?.isNotEmpty == true && appController.isCurrentUserSubscriptionActive(originalProductInfo!.membershipIds!.first);

  Calendar? get productCalendar => productCalendarResponse.value?.calendar;

  bool get canEnableOrder {
    if (originalProductInfo?.isMembershipProduct ?? false) {
      if (isCurrentUserSubscriptionForProductMembershipActive && isOptionSelected) {
        return true;
      }
      return false;
    } else {
      return isOptionSelected;
    }
  }

  bool isProductOptionSelected(Product product) => selectedProductOption.value?.id == product.id;

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
    final requiredAddons = originalProductInfo?.addons?.where((addon) => addon.isRequired);
    if (requiredAddons.isBlank == true) {
      return true;
    }
    return requiredAddons?.any((addon) {
          return productOrderConfig.isContainAddonId(addon.id!);
        }) ??
        true;
  }

  void selectProductOption(Product product) {
    selectedProductOption.value = product;
  }

  // widget Controllers
  final productOptionListController = Get.put(CustomListController<Product>(), tag: 'productOptionList');
  late ScrollController productHeaderScrollController;

  @override
  void initViewmodel({Map<String, dynamic>? data}) async {
    super.initViewmodel(data: data);
    productHeaderScrollController = ScrollController();
    final productId = data!['id'] as String;
    final discount = data['discounts'] as List<Discount>?;
    await getProductDetails(productId);
    addDiscountList(discount, clearPrevious: true);
    await getProductMembershipDetails();
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
      addDiscountList(businessInfo?.discounts ?? [], clearPrevious: false);

      selectedProductQty.value = (productDetails.value?.product?.minimumOrderQty.toDouble() ?? 1.0);
      if (productOptions.isNotEmpty) {
        productOptionListController.addItems(productOptions);
      }
    } on AppException catch (e) {
      exception.value = e;
    } catch (e) {
      exception.value = AppException.unexpectedError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getProductMembershipDetails() async {
    try {
      isSecondaryLoading(true);
      print('membership details ${originalProductInfo?.isMembershipProduct}');
      if (!(originalProductInfo?.isMembershipProduct ?? false)) {
        return;
      }
      final membershipId = originalProductInfo!.membershipIds!.first;
      final membershipInfo = await membershipUseCase.getMembershipDetails(membershipId, fetchPolicy: ApiDataFetchPolicy.networkOnly);
      appController.setBusinessMembershipInfo(membershipInfo);
    } catch (e) {
      print('error $e');
    } finally {
      isSecondaryLoading(false);
    }
  }

  void addDiscountList(List<Discount>? discountList, {bool clearPrevious = true}) {
    if (clearPrevious) {
      discounts.clear();
    }
    discounts.addAll(discountList ?? []);
  }

  // view helper methods

  List<ProductFeature> getProductFeatures() {
    final originalProduct = productDetails.value?.product;
    var list = <ProductFeature>[];
    if (originalProduct?.loyaltyPoint.isGreaterThan(0) == true) {
      list.add(ProductFeature(name: '${originalProduct?.getLoyaltyPointString("ENGLISH")}', icon: Icons.loyalty, description: 'You will earn ${originalProduct?.getLoyaltyPointString("ENGLISH")} loyalty points per item ordered. You can redeem these points for discounts and other rewards on future orders.'));
    }
    if (originalProduct?.canOrderOnline == true) {
      list.add(const ProductFeature(name: 'Order online', icon: Icons.delivery_dining));
    }
    if (originalProduct?.isMembershipProduct ?? false) {
      list.add(const ProductFeature(name: 'Members only', icon: Icons.card_membership, description: 'This product is only available for members. Become a member to order this product'));
    }
    if (originalProduct?.haveDynamicPricing == true) {
      list.add(const ProductFeature(name: 'Dyanamic pricing', icon: Icons.mode, description: 'This product has dynamic pricing. The price will be determined based on the quantity ordered. You will get a discount based on the quantity ordered.'));
    }
    return list;
  }

  void handleJourney(BuildContext context, WidgetFactory widgetFactory) async {
    var resultMap = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog.fullscreen(
        child: ProductAddonModal(
          productAddons: List.from(originalProductInfo?.getAddons() ?? []),
          initialOrderConfigs: productOrderConfig.value,
          productInfo: selectedProduct,
          parentProductInfo: originalProductInfo!.copyWith(),
          showqtyModfier: true,
          discounts: discounts,
          callToAction: 'Add to cart',
        ),
      ),
    );
    // var result = await AppModalSheet.showModal<AddonConfig?>(
    //   context,
    //   type: AppModalSheetType.BOTTOMSHEET,
    //   pages: [
    //     ModalContent(
    //       title: const Text('Order Configuration'),
    //       content: SizedBox(
    //         width: MediaQuery.of(context).size.width,
    //         height: 1000,
    //         child: ProductAddonModal(
    //           productAddons: List.from(originalProductInfo?.getAddons() ?? []),
    //           initialOrderConfigs: productOrderConfig.value,
    //           productInfo: selectedProduct,
    //           parentProductInfo: originalProductInfo!.copyWith(),
    //           showqtyModfier: true,
    //           discounts: discounts,
    //           callToAction: 'Add to cart',
    //         ),
    //       ),
    //     )
    //   ],
    // );
    if (resultMap == null) {
      return;
    }
    final result = resultMap['CONFIG_DATA'] as AddonConfig;
    final selectedQtyConfig = result.orderConfigs.firstWhere((element) => element.addonId == OrderConfig.QTY_CONFIG_ID);
    final selectedQty = double.tryParse(selectedQtyConfig.singleValue ?? '1') ?? 1;
    final updatedResult = result.removeQtyConfig();
    productOrderConfig.value = List<OrderConfig>.from(updatedResult.orderConfigs);

    addtoCart(
      context,
      qty: selectedQty,
      selectedCurrency: appController.selectedCurrency.name,
      selectedDiscounts: discounts,
      orderConfigs: List.from(productOrderConfig),
      additionalItems: result.additionalItems,
    );
  }

  bool currentUserIsMember(List<String> membershipIds) {
    final userMembershipSubscription = appController.currentUserBusinessMembershipsSubscriptions.where((subscription) => membershipIds.contains(subscription?.subscribedTo)).toList();
    return userMembershipSubscription.isNotEmpty;
  }

  Future<void> addtoCart(BuildContext context, {required double qty, String selectedCurrency = 'ETB', List<Discount> selectedDiscounts = const [], List<OrderConfig> orderConfigs = const [], List<OrderItem>? additionalItems}) async {
    try {
      isLoading(true);
      final dynamicPriceDiscounts = originalProductInfo!.getDynamicPriceDiscountByQty(qty);
      final finalDiscountsList = [...selectedDiscounts];
      if (dynamicPriceDiscounts != null) {
        finalDiscountsList.add(dynamicPriceDiscounts);
      }
      final cartInfo = selectedProduct.getCartInfo(qty: qty, businessInfo: businessInfo!, productOrderConfigs: orderConfigs, discounts: finalDiscountsList, addons: originalProductInfo!.getAddons(), productPoint: originalProductInfo!.loyaltyPoint.toDouble());
      final orderAddons = originalProductInfo!.business?.getSectionsOrderAddon(originalProductInfo!.sectionId ?? []);
      final updatedCart = cartInfo.addPaymentOption(productPaymentOption).addOrderAddons(orderAddons ?? []).addOrUpdateItems(additionalItems ?? []);
      cartListViewmodel.addCartToCartList(updatedCart, paymentOptions: productPaymentOption);

      appController.showAddToCartDialog(context, message: 'Item added to the cart successfully.', cart: updatedCart);
    } catch (e) {
      exception.value = exceptiionHandler.getException(e as Exception);
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
    productOrderConfig.clear();
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

  void handleMembership(BuildContext context) {
    MembershipDetailsPage.navigate(context, originalProductInfo!.membershipIds!.first);
  }

  void showFeatureDescriptionModal(BuildContext context, ProductFeature selectedFEature) {
    final widgetFactory = appController.getWidgetFactory(context);
    AppModalSheet.showModal(
      context,
      type: AppModalSheetType.BOTTOMSHEET,
      pages: [
        ModalContent(
            title: widgetFactory.createText(context, selectedFEature.name, style: Theme.of(context).textTheme.bodyLarge),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(selectedFEature.description ?? ''),
                const SizedBox(height: 16),
                widgetFactory.createButton(
                  context: context,
                  content: const Text('Close'),
                  onPressed: () {
                    AppModalSheet.closeModal();
                  },
                ),
              ],
            ).withPaddingAll(16))
      ],
    );
  }

  void navigateToPhotoViewerPage(BuildContext context, List<String> photoUrls, int startIndex) {
    final productImages = selectedProduct.gallery?.getImages() ?? [];
    PhotoViewerScreen.navigate(context, productImages, startIndex);
  }

  void navigateToCartDetailsPage(BuildContext context) {
    if (businessInfo?.id == null) {
      return;
    }
    final selectedCart = appController.getCartByBusinessId(businessInfo!.id!);
    if (selectedCart == null) {
      CartListPage.navigate(context);
    } else {
      CartDetailPage.navigateToCartDetailPage(context, router, selectedCart);
    }
  }

  double getProductOptionHeight() {
    if (productOptions.length > 1) {
      return 200;
    }
    return 150;
  }
}
