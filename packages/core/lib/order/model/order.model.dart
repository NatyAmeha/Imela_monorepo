import 'package:freezed_annotation/freezed_annotation.dart';
import '../../business/model/payment_option.model.dart';
import 'order_item.model.dart';
import 'order_payment_method.model.dart';

import 'cart.model.dart';

part 'order.model.freezed.dart';
part 'order.model.g.dart';

enum OrderStatus{
  PENDING,
  PROCESSING,
  COMPLETED,
  CANCELLED,
  REFUNDED,
  FAILED,
}

@freezed
class Order with _$Order {
  const Order._();
  const factory Order({
    String? id,
    int? orderNumber,
    String? status,
    List<OrderItem>? items,
    String? userId,
    String? paymentType,
    double? remainingAmount,
    double? subTotal,
    List<ItemDiscount>? discount,
    double? totalAmount,
    List<OrderPaymentMethod>? paymentMethods,
    bool? isOnlineOrder,
    String? note,
    List<String>? businessId,
    String? branchId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  static Order createOrderInfo(Cart cartIfno, PaymentOption paymentOption) {
    return Order(paymentType: paymentOption.type, items: cartIfno.items, isOnlineOrder: true, subTotal: cartIfno.getSubtotal, businessId: [cartIfno.businessId!]);
  }
}
