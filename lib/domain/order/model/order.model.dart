import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:melegna_customer/domain/order/model/order_item.model.dart';
import 'package:melegna_customer/domain/order/model/order_payment_method.model.dart';

part 'order.model.freezed.dart';
part 'order.model.g.dart';

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
}