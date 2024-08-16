import 'package:injectable/injectable.dart';
import 'package:melegna_customer/domain/order/model/order.response.dart';
import 'package:melegna_customer/domain/order/model/order_item.model.dart';
import 'package:melegna_customer/domain/order/repo/cart.repository.dart';
import 'package:melegna_customer/domain/order/repo/order.repository.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';

@injectable
class OrderUsecase {
  final IOrderRepository _orderRepo;
  final ICartRepository _cartRepo;

  const OrderUsecase(@Named(OrderRepository.injectName) this._orderRepo, @Named(CartRepository.injectName) this._cartRepo);

  Future<OrderResponse?> getUserCartList() async {
    final result = await _cartRepo.getCarts();
    return result;
  }

  Future<OrderResponse> removeItemsFromCart(String cartId, List<String> productIds) async {
    final result = await _cartRepo.removeItemsFromCart(cartId, productIds);
    return result;
  }

  Future<OrderResponse?> addToCart(String businessId, List<LocalizedField> cartName, List<OrderItem> items) async {
    final result = await _cartRepo.addtoCart(businessId, cartName, items);
    return result;
  }
}
