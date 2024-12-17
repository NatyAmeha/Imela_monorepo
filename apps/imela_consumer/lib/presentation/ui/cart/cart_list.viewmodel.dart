import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/cart/cart_detail_page.dart';
import 'package:imela/presentation/ui/cart/components/discount_list_modal.dart';
import 'package:imela/presentation/ui/cart/order_configure/order_configure_page.dart';
import 'package:imela/presentation/ui/loyalty/components/reward_list_modal.dart';
import 'package:imela/presentation/ui/loyalty/pages/loyalty_details_page.dart';
import 'package:imela/presentation/ui/product/components/product_addon_modal/product_addon_list_modal.dart';
import 'package:imela/presentation/ui/shared/list/list_componenet.viewmodel.dart';
import 'package:imela/services/routing_service.dart';
import 'package:imela_core/business/model/payment_option.model.dart';
import 'package:imela_core/loyalty/dto/loyalty.response.dart';
import 'package:imela_core/loyalty/model/reward.model.dart';
import 'package:imela_core/order/model/cart.model.dart';
import 'package:imela_core/order/model/order_config.model.dart';
import 'package:imela_core/order/model/order_item.model.dart';
import 'package:imela_core/order/order.usecase.dart';
import 'package:imela_core/product/discount.usecase.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_ui_kit/components/modal/app_modal_sheet.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@injectable
class CartListViewmodel extends GetxController with BaseViewmodel {
  static const FETCH_CART_FROM_API_KEY = 'fetch_cart_from_api';
  final DiscountUseCase discountUseCase;

  // page state variables
  final isLoading = false.obs;
  final exception = Rxn<AppException>();
  var isRewardLoading = false.obs;

  var selectedCart = Rxn<Cart>();
  var orderAddonsConfigured = false.obs;

  final OrderUsecase orderUsecase;
  final IExceptiionHandler exceptiionHandler;
  final IRoutingService router;
  CartListViewmodel({
    required this.orderUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
    @Named(GoRouterService.injectName) required this.router,
    required this.discountUseCase,
  });

  static CartListViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<CartListViewmodel>());
  }

  AppController get appController => AppController.getInstance;

  RxList<DiscountInfo> eligableDiscounts = <DiscountInfo>[].obs;

  late BuildContext context;

  //controller
  var cartListController = Get.put(CustomListController<Cart>(), tag: 'CART_LIST_CONTROLLER');
  var cartItemListController = Get.put(CustomListController<OrderItem>(), tag: 'CartItemListController');

  // getters

  List<Cart> get carts => appController.carts;
  List<PaymentOption> get businessPaymentOptions => selectedCart.value?.paymentOptions ?? [];
  String get callToActionText {
    return orderAddonsConfigured.value == false && selectedCart.value?.hasOrderAddons() == true ? 'Continue' : 'Proceed to Payment';
  }

  LoyaltyResponse? get selectedBusinessLoyaltyProgram => appController.selectedBusinessLoyaltyInfo.value;
  double get userRewardPoints => appController.customerLoyalty.value?.currentPoints ?? 0.0;

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    final fetchCartFromApi = data?[FETCH_CART_FROM_API_KEY] as bool? ?? true;
    context = data?['context'] as BuildContext;
    super.initViewmodel(data: data);
  }

  void fecthAvailableDiscounts() {
    var customerLoyalty = appController.customerLoyalty.value;
    final existingDiscounts = List<DiscountInfo>.from(eligableDiscounts.where((e) => e.isApplied));
    eligableDiscounts.value = discountUseCase.resetAddedDiscount().createBusinessOfferDiscounts(appController.businessDiscounts).createLoyaltyDiscount(customerLoyalty, appController.allRewards).createDynamicPriceDiscount(null).build(existingDiscounts);
  }

  void addCartToCartList(Cart cart, {List<PaymentOption> paymentOptions = const []}) {
    final existingCartIndex = appController.carts.indexWhere((element) => element.id == cart.id);
    if (existingCartIndex != -1) {
      var existingItems = List<OrderItem>.from(appController.carts[existingCartIndex].items ?? []);
      existingItems.addAll(cart.items ?? []);
      var updatedCart = appController.carts[existingCartIndex].addOrUpdateItems(existingItems);

      appController.carts[existingCartIndex] = updatedCart;
    } else {
      appController.carts.add(cart);
    }
  }

  void addCartsToCartList(List<Cart> cartList, {bool clearPrevious = false}) {
    if (clearPrevious) {
      appController.carts.clear();
    }
    appController.carts.addAll(cartList);
    // changeCartApiFetchStatus(false);
  }

  Cart? updateCartState(Cart newCartInfo) {
    final index = appController.carts.indexWhere((element) => element.id == newCartInfo.id);
    if (index != -1) {
      appController.carts[index] = newCartInfo;
      return appController.carts[index];
    }
    return null;
  }

  Cart? removeItemsFromCartState(String cartId, List<String> productIds) {
    final index = appController.carts.indexWhere((element) => element.id == cartId);
    if (index != -1) {
      appController.carts[index] = appController.carts[index].removeItems(productIds);
      return appController.carts[index];
    }
    return null;
  }

  OrderItem? updateCartItem(String cartId, String productId, double qty) {
    final cart = appController.getCartById(cartId);
    final index = cart?.items?.indexWhere((element) => element.productId == productId);
    if (index != -1) {
      final updatedItem = cart!.items![index!].copyWith(quantity: qty);
      cart.items![index] = updatedItem;
      return updatedItem;
    }
    return null;
  }

  Cart? updateItemInSelectedCartState(String cartId, OrderItem item) {
    final cart = appController.getCartById(cartId);
    if (cart != null) {
      final index = cart.items!.indexWhere((element) => element.productId == item.productId);
      appController.carts[index] = cart.updateOrderItem(item);
      return appController.carts[index];
    }
    return null;
  }

  void removeCart(String cartId) {
    appController.carts.removeWhere((element) => element.id == cartId);
  }

  void handleCartSelection(BuildContext context, Cart cart) {
    CartDetailPage.navigateToCartDetailPage(context, router, cart);
  }

  void showBusinessRewardsPage(BuildContext context) {
    if (selectedBusinessLoyaltyProgram != null) {
      LoyaltyDetailsPage.navigate(context, programName: 'Loyalty Info', loyaltyInfo: selectedBusinessLoyaltyProgram);
    }
  }

  // cart details logic

  void seselectedCart(Cart selectedCart) {
    Future.delayed(Duration.zero, () async {
      this.selectedCart.value = selectedCart;
      cartItemListController.setItems(selectedCart.items ?? []);
      final businessId = selectedCart.businessIds?.first;
      if (businessId != null) {
        isRewardLoading(true);
        final result = await appController.getCustomerBusinessLoyalty(businessId);
        if (result != null) {
          isRewardLoading(false);
        }
      }
    });
  }

  Widget getClearCartIcon(BuildContext context, WidgetFactory widgetFactory) {
    if (selectedCart.value?.items?.isNotEmpty == true) {
      return widgetFactory.createIcon(
        materialIcon: Icons.delete,
        onPressed: () {
          clearSelectedCart(context);
        },
      );
    }
    return const SizedBox.shrink();
  }

  void clearSelectedCart(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Clear Cart'),
            content: const Text('Are you sure you want to clear the cart?'),
            actions: [
              TextButton(onPressed: () {
                Navigator.pop(context);
              }, child: const Text('Cancel')),
              TextButton(
                  onPressed: () {
                    selectedCart.value = selectedCart.value?.copyWith(items: []);
                    cartItemListController.setItems([]);
                    appController.carts.removeWhere((element) => element.id == selectedCart.value?.id);
                    Navigator.pop(context);
                  },
                  child: const Text('Confirm')),
            ],
          );
        });
  }

  void showEligableRewardsModal(BuildContext context) async {
    await AppModalSheet.showModal<bool>(context, type: AppModalSheetType.BOTTOMSHEET, pages: [
      ModalContent(
        title: const Text('Available Rewards'),
        content: Obx(
          () => RewardListModal(
            isLoading: isRewardLoading.value,
            allRewards: appController.allRewards,
            eligibleRewards: appController.userEligableRewards,
            customerLoyalty: selectedBusinessLoyaltyProgram?.customerLoyalty,
            onRewardSelected: (reward) async {
              applyLoyaltyDiscount(reward);
              await AppModalSheet.closeModal();
            },
          ),
        ),
      ),
    ]);
  }

  void applyLoyaltyDiscount(Reward reward) {
    selectedCart.value = selectedCart.value!.applyLoyaltyDiscountOnCartItems([reward]);
    cartItemListController.setItems(selectedCart.value!.items ?? []);
    appController.updateUsedRewardPoints(reward.minPointsToRedeem.toDouble());
  }

  void clearUsedPoints() {
    var allRewardIds = appController.allRewards.map((e) => e.id).toList();
    selectedCart.value = selectedCart.value!.removeAppliedLoyaltyDiscounts(allRewardIds);
    cartItemListController.setItems(selectedCart.value!.items ?? []);
    appController.updateUsedRewardPoints(0);
  }

  Future<void> updateItemQty(String productId, int index, double qty) async {
    try {
      isLoading(true);
      var updatedItem = selectedCart.value!.items![index].copyWith(quantity: qty);
      final selectedDynamicPrice = updatedItem.product?.getDynamicPriceDiscountByQty(qty);
      if (selectedDynamicPrice != null) {
        updatedItem = updatedItem.addDiscount([selectedDynamicPrice.toItemDiscount()], replaceIfExists: true);
      } else {
        updatedItem = updatedItem.removeDiscountById(DiscountSource.DYNAMIC_PRICING.name);
      }
      selectedCart.value = selectedCart.value?.updateOrderItem(updatedItem);
      updateCartState(selectedCart.value!);
      cartItemListController.updateItem(index, updatedItem);
    } catch (ex) {
      print('exception $ex');
      exception.value = exceptiionHandler.getException(ex as Exception);
    } finally {
      isLoading(false);
    }
  }

  Future<void> removeItemsFromCart(List<String> productIds, List<int> indexs) async {
    try {
      isLoading(true);
      selectedCart.value = selectedCart.value!.removeItems(productIds);
      cartItemListController.removeItems(indexs);
      updateCartState(selectedCart.value!);
      // final result = await orderUsecase.removeItemsFromCart(cartId!, productIds);
      // if (result.success == true && result.cart != null) {

      // }
    } catch (ex) {
      exception.value = exceptiionHandler.getException(ex as Exception);
    } finally {
      isLoading(false);
    }
  }

  void showDiscountsModal(BuildContext context, OrderItem item, {double? subTotal}) {
    AppModalSheet.showModal<bool>(context, type: AppModalSheetType.BOTTOMSHEET, pages: [
      ModalContent(
        title: const Text('Discount Details'),
        content: DiscountListModal(
          item: item,
          widgetFactory: appController.getWidgetFactory(context),
          selectedLanguage: appController.selectedLanguageUpdated.value,
          selectedCurrency: appController.selectedCurrency.name,
        ),
      )
    ]);
  }

  Future<void> changeOrderConfigs(BuildContext context) async {
    orderAddonsConfigured.value = false;
    // print('object')
    final configResult = await AppModalSheet.showModal<AddonConfig?>(context, type: AppModalSheetType.BOTTOMSHEET, pages: [
      ModalContent(
        title: const Text('Order Configuration'),
        content: ProductAddonModal(
          productAddons: List.from(selectedCart.value!.getAddons()),
          initialOrderConfigs: selectedCart.value?.configs ?? [],
          showqtyModfier: false,
          totalPrice: selectedCart.value!.getTotatAmountPOS(),
        ),
      )

      // ModalContent(
      //   title: const Text('Order Configurations'),
      //   content: ProductAddonModal(productAddons: selectedCart.value!.orderAddons!, initialOrderConfigs: selectedCart.value?.configs ?? []),
      // ),
    ]);
    if (configResult == null) {
      return;
    }
    if (configResult.orderConfigs.isNotEmpty == true) {
      selectedCart.value = selectedCart.value!.addSelectedOrderConfigs(configResult.orderConfigs);
    }
    if (configResult.additionalItems?.isNotEmpty == true) {
      var updatedCart = selectedCart.value!.addOrUpdateItems(configResult.additionalItems!);
      cartItemListController.setItems(updatedCart.items ?? []);
      updateCartState(updatedCart);
    }
    orderAddonsConfigured.value = true;
  }

  void handleNextScreenNavigation(BuildContext context) async {
    if (selectedCart.value!.hasOrderAddons() == true) {
      if (orderAddonsConfigured.value == true) {
        OrderConfigurePage.navigateToOrderConfigurePage(context, router, cartInfo: selectedCart.value!);
      } else if (selectedCart.value!.configs?.isEmpty ?? true) {
        await changeOrderConfigs(context);
      } else {
        OrderConfigurePage.navigateToOrderConfigurePage(context, router, cartInfo: selectedCart.value!);
      }
    } else {
      OrderConfigurePage.navigateToOrderConfigurePage(context, router, cartInfo: selectedCart.value!);
    }
  }

  @override
  void dispose() {
    cartListController.dispose();
    super.dispose();
  }

  void showProductDetailPage(BuildContext context, Product product) {
    //  AppModalSheet.showModal(context, type: AppModalSheetType.BOTTOMSHEET, pages: [
    //   ModalContent(
    //     title: const Text('Product Details'),
    //     content: ProductDetailPage(product: product),
    //   )
    // ]);
  }
}
