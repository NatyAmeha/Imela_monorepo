import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melegna_customer/data/network/graphql_config.dart';
import 'package:melegna_customer/domain/business/model/payment_option.model.dart';
import 'package:melegna_customer/domain/order/model/cart.model.dart';
import 'package:melegna_customer/domain/order/model/order_item.model.dart';
import 'package:melegna_customer/domain/shared/price_currency.model.dart';
import 'package:melegna_customer/presentation/ui/authentication/auth_selection_page.dart';
import 'package:melegna_customer/presentation/utils/localization_utils.dart';
import 'package:melegna_customer/services/routing_service.dart';

class AppController extends GetxController {
  static AppController get getInstance {
    return Get.isRegistered<AppController>() ? Get.find<AppController>() : Get.put(AppController());
  }

  final router = getIt<GoRouterService>(instanceName: GoRouterService.injectNameBeta);

  AppLanguage selectedLanguage = AppLanguage.ENGLISH;

  Currency selectedCurrency = Currency.ETB;

  var carts = <Cart>[].obs;
  bool enableCartFetchFromApi = true;

  Cart? getCartById(String cartId) {
    return carts.firstWhereOrNull((element) => element.id == cartId);
  }

  void addCartToCartList(Cart cart, {List<PaymentOption> paymentOptions = const []}) {
    carts.removeWhere((element) =>  element.id == cart.id);
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
  

  void updateCartState(Cart newCartInfo) {
    final index = carts.indexWhere((element) => element.id == newCartInfo.id);
    if (index != -1) {
      carts[index] = newCartInfo;
    }
  }

  void removeItemsFromCartState(String cartId, List<String> productIds) {
    final index = carts.indexWhere((element) => element.id == cartId);
    if (index != -1) {
      carts[index] =  carts[index].removeItems(productIds);
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

  void updateItemInSelectedCartState(String cartId, OrderItem item) {
    final cart = getCartById(cartId);
    if (cart != null) {
      final index = cart.items!.indexWhere((element) => element.productId == item.productId);
      carts[index] = cart.updateOrderItem(item);
    }
  }

  void removeCart(String cartId) {
    carts.removeWhere((element) => element.id == cartId);
  }


  void logout(BuildContext context, {String? redirectUrl}) {
    carts.clear();
    changeCartApiFetchStatus(true);
    AuthSelectionPage.navigate(context, router, redirectT: redirectUrl);
  }

  changeCartApiFetchStatus(bool status) {
    enableCartFetchFromApi = status;
  }
}
