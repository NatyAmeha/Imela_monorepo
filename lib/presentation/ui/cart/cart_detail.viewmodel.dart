import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:melegna_customer/domain/business/model/payment_option.model.dart';
import 'package:melegna_customer/domain/order/model/cart.model.dart';
import 'package:melegna_customer/domain/order/model/order_item.model.dart';
import 'package:melegna_customer/domain/order/order.usecase.dart';
import 'package:melegna_customer/injection.dart';
import 'package:melegna_customer/presentation/ui/app_controller.dart';
import 'package:melegna_customer/presentation/ui/cart/cart_detail_page.dart';
import 'package:melegna_customer/presentation/ui/cart/order_configure/order_configure_page.dart';
import 'package:melegna_customer/presentation/ui/shared/base_viewmodel.dart';
import 'package:melegna_customer/presentation/ui/shared/list/list_componenet.viewmodel.dart';
import 'package:melegna_customer/presentation/utils/exception/app_exception.dart';
import 'package:melegna_customer/services/routing_service.dart';

@injectable
class CartDetailViewmodel extends GetxController with BaseViewmodel {
  final OrderUsecase orderUsecase;
  final IExceptiionHandler exceptiionHandler;
  final IRoutingService router;
  CartDetailViewmodel({
    required this.orderUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
    @Named(GoRouterService.injectName) required this.router,
  });

  static CartDetailViewmodel getInstance() {
    if (!Get.isRegistered<CartDetailViewmodel>()) {
      Get.lazyPut(() => getIt<CartDetailViewmodel>());
    }
    return Get.find<CartDetailViewmodel>();
  }

  AppController get appController => AppController.getInstance;

  final isLoading = false.obs;
  final smallScreenLoading = false.obs;
  final exception = Rxn<AppException>();

  var selectedCart = Rxn<Cart>();
  var cartListController = Get.put(CustomListController<OrderItem>(), tag: 'CartItemListController');
  List<PaymentOption> get businessPaymentOptions => selectedCart.value?.paymentOptions ?? [];

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    selectedCart.value = data?[CartDetailPage.CART_DATA] as Cart?;
    if (selectedCart.value?.items?.isNotEmpty == true) {
      cartListController.setItems(selectedCart.value!.items!);
    }
  }

  Future<void> removeItemsFromCart(List<String> productIds, List<int> indexs) async {
    try {
      isLoading(true);
      final cartId = selectedCart.value?.id;
      final result = await orderUsecase.removeItemsFromCart(cartId!, productIds);
      if (result.success == true && result.cart != null) {
        appController.removeItemsFromCartState(cartId, productIds);
        cartListController.removeItems(indexs);
      }
    } catch (ex) {
      exception.value = exceptiionHandler.getException(ex as Exception);
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateItemQty(String productId, int index, double qty) async {
    try {
      isLoading(true);
      final cartId = selectedCart.value?.id;
      if (cartId != null) {
        final updatedITem = appController.updateCartItem(cartId, productId, qty);
        if (updatedITem == null) {
          return;
        }
        final result = await orderUsecase.addToCart(selectedCart.value!.businessId!, selectedCart.value!.name!, [updatedITem]);
        if (result?.success == true && result?.cart != null) {
          cartListController.updateItem(index, updatedITem);
          appController.updateItemInSelectedCartState(cartId, updatedITem);
        }
      }
    } catch (ex) {
      exception.value = exceptiionHandler.getException(ex as Exception);
    } finally {
      isLoading(false);
    }
  }

  void navigateToOrderConfigurePage(BuildContext context) {
    OrderConfigurePage.navigateToOrderConfigurePage(context, router, cartInfo: selectedCart.value!);
  }
}
