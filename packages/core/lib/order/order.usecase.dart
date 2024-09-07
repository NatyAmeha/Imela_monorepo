import 'package:imela_core/business/model/payment_option.model.dart';
import 'package:imela_core/order/model/order.response.dart';
import 'package:imela_core/order/model/order_item.model.dart';
import 'package:imela_core/order/repo/cart.repository.dart';
import 'package:imela_core/order/repo/order.repository.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:injectable/injectable.dart';
import 'package:imela_core/order/model/order.model.dart' as OrderModel;


@injectable
class OrderUsecase {
  final IOrderRepository _orderRepo;
  final ICartRepository _cartRepo;

  const OrderUsecase(@Named(OrderRepository.injectName) this._orderRepo, @Named(CartRepository.injectName) this._cartRepo);

  Future<OrderResponse?> getUserCartList() async {
    final result = await _cartRepo.getCarts(fetchPolicy: ApiDataFetchPolicy.networkOnly);
    return result;
  }

  Future<OrderResponse> removeItemsFromCart(String cartId, List<String> productIds) async {
    final result = await _cartRepo.removeItemsFromCart(cartId, productIds);
    return result;
  }

  Future<OrderResponse?> addToCart(String businessId, List<LocalizedField> cartName, List<OrderItem> items, {List<PaymentOption>? paymentOptions}) async {
    final result = await _cartRepo.addtoCart(businessId, cartName, items, paymentOptions: paymentOptions);
    return result;
  }

  Future<OrderResponse> placeOrder(String? cartId, OrderModel.Order orderInfo) async {
    final result = await _orderRepo.createOrder(cartId: cartId, orderInfo: orderInfo);
    return result;
  }

  Future<OrderResponse?> getOrders() async {
    final result = await _orderRepo.getOrders();
    print('order result ${result?.orders?.map((item) => item.status).toList()}');
    return result;
  }

  Future<OrderResponse?> getOrderDetails(String orderId) async {
    final result = await _orderRepo.getOrderDetails(orderId);
    return result;
  }
}
