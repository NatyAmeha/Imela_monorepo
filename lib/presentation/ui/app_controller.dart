import 'package:get/get.dart';
import 'package:melegna_customer/domain/order/model/cart.model.dart';
import 'package:melegna_customer/domain/shared/price_currency.model.dart';
import 'package:melegna_customer/presentation/utils/localization_utils.dart';

class AppController extends GetxController{

  static AppController get getInstance {
    return  Get.isRegistered<AppController>() ? Get.find<AppController>() : Get.put(AppController());
  }
  
  AppLanguage selectedLanguage = AppLanguage.ENGLISH;

  Currency selectedCurrency = Currency.ETB;

  var carts = <Cart>[].obs;
  bool enableCartFetchFromApi = true;

  void addToCart(List<Cart> cart){
    carts.addAll(cart);
    changeCartApiFetchStatus(false);
  }

  void removeCart(String cartId){
    carts.removeWhere((element) => element.id == cartId);
  }

  changeCartApiFetchStatus(bool status){
    enableCartFetchFromApi = status;
  }
}