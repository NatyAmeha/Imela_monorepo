import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:melegna_customer/domain/order/model/cart.model.dart';
import 'package:melegna_customer/domain/order/model/order.model.dart';

part 'order.response.freezed.dart';
part 'order.response.g.dart';

@freezed
class OrderResponse with _$OrderResponse {
  const OrderResponse._();
  const factory OrderResponse({
    bool? success,
    String? message,
    Cart? cart,
    List<Cart>? carts,
    Order? order,
    List<Order>? orders,
  }) = _OrderResponse;

  factory OrderResponse.fromJson(Map<String, dynamic> json) => _$OrderResponseFromJson(json);
}
