import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/ui/authentication/auth_selection_page.dart';
import 'package:imela/presentation/utils/localization_utils.dart';
import 'package:imela/services/routing_service.dart';
import 'package:imela_core/business/model/payment_option.model.dart';
import 'package:imela_core/order/model/cart.model.dart';
import 'package:imela_core/order/model/order_item.model.dart';
import 'package:imela_core/shared/price_currency.model.dart';
import 'package:imela_core/user/model/auth_response.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class AppController extends GetxController {
  static AppController get getInstance {
    return Get.isRegistered<AppController>() ? Get.find<AppController>() : Get.put(AppController());
  }

  final router = getIt<GoRouterService>(instanceName: GoRouterService.injectNameBeta);

  AppLanguage selectedLanguage = AppLanguage.ENGLISH;

  Currency selectedCurrency = Currency.ETB;


  FirebaseAuthResponse? firebaseAuthInfo;

  static  WidgetFactory? _widgetFactory;
  WidgetFactory getWidgetFactory(BuildContext context) {
    _widgetFactory ??= WidgetFactory(Theme.of(context).platform); 
    return _widgetFactory!;
  }

  var carts = <Cart>[].obs;
  bool enableCartFetchFromApi = true;

  Cart? getCartById(String cartId) {
    return carts.firstWhereOrNull((element) => element.id == cartId);
  }

  void addCartToCartList(Cart cart, {List<PaymentOption> paymentOptions = const []}) {
    carts.removeWhere((element) => element.id == cart.id);
    carts.add(cart);
    changeCartApiFetchStatus(false);
  }

  void addCartsToCartList(List<Cart> cartList, {bool clearPrevious = false}) {
    if (clearPrevious) {
      carts.clear();
    }
    carts.addAll(cartList);
    changeCartApiFetchStatus(false);
  }

  Cart? updateCartState(Cart newCartInfo) {
    final index = carts.indexWhere((element) => element.id == newCartInfo.id);
    if (index != -1) {
      carts[index] = newCartInfo;
      return carts[index];
    }
  }

  Cart? removeItemsFromCartState(String cartId, List<String> productIds) {
    final index = carts.indexWhere((element) => element.id == cartId);
    if (index != -1) {
      carts[index] = carts[index].removeItems(productIds);
      return carts[index];
    }
  }

  OrderItem? updateCartItem(String cartId, String productId, double qty) {
    final cart = getCartById(cartId);
    if (cart != null) {
      var item = cart.updateItemQty(productId, qty);
      return item;
    }
    return null;
  }

  Cart? updateItemInSelectedCartState(String cartId, OrderItem item) {
    final cart = getCartById(cartId);
    if (cart != null) {
      final index = cart.items!.indexWhere((element) => element.productId == item.productId);
      carts[index] = cart.updateOrderItem(item);
      return carts[index];
    }
  }

  void removeCart(String cartId) {
    carts.removeWhere((element) => element.id == cartId);
  }

  void logout(BuildContext context, {String? redirectUrl}) {
    carts.clear();
    changeCartApiFetchStatus(true);
    AuthSelectionPage.navigate(context, redirectT: redirectUrl);
  }

  changeCartApiFetchStatus(bool status) {
    enableCartFetchFromApi = status;
  }
}
