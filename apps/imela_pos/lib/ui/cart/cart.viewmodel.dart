import 'package:dartx/dartx.dart';
import 'package:get/get.dart';
import 'package:imela_core/order/model/cart.model.dart';
import 'package:imela_core/order/model/order_item.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/injection.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@injectable
class CartViewmodel extends GetxController with BaseViewmodel {
  static CartViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<CartViewmodel>());
  }

  // state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();

  // getters
  AppViewmodel get appViewmodel => AppViewmodel.getInstance();

  Cart get cart {
    return appViewmodel.cartInfo.value ?? Cart(name: [LocalizedField(key: 'ENGLISH', value: 'Cart')]);
  }

  bool isCartContainsProduct(String? productId) {
    if (productId == null) return false;
    return appViewmodel.cartInfo.value.items?.any((element) => element.productId == productId) ?? false;
  }

  void updateProductQty(String productId, {required double qty, bool reset = false}) {
    final item = appViewmodel.cartInfo.value.items?.firstOrNullWhere((element) => element.productId == productId);
    if (item != null) {
      final qtyToAdd = reset ? qty : item.quantity + qty;
      final updatedItem = item.copyWith(quantity: qtyToAdd);
      final updatedItems = appViewmodel.cartInfo.value.items?.map((e) => e.productId == productId ? updatedItem : e).toList() ?? [];
      appViewmodel.cartInfo.value = appViewmodel.cartInfo.value.copyWith(items: updatedItems);
    }
  }

  void addProductToCart(OrderItem item) {
    appViewmodel.cartInfo.value = appViewmodel.cartInfo.value.copyWith(items: [...appViewmodel.cartInfo.value.items ?? [], item]);
  }

  void removeProductFromCart(String productId) {
    appViewmodel.cartInfo.value = appViewmodel.cartInfo.value.copyWith(items: appViewmodel.cartInfo.value.items?.where((element) => element.productId != productId).toList());
  }

  void clearCart() {
    appViewmodel.cartInfo.value = appViewmodel.cartInfo.value.copyWith(items: []);
  }
}
