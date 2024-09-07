import 'package:dartx/dartx.dart';
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../business/model/payment_option.model.dart';
import 'order_item.model.dart';
import '../../shared/localized_field.model.dart';

part 'cart.model.freezed.dart';
part 'cart.model.g.dart';

@freezed
class Cart with _$Cart {
  const Cart._();
  const factory Cart({
    String? id,
    List<LocalizedField>? name,
    String? businessId,
    String? userId,
    List<OrderItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,

    List<PaymentOption>? paymentOptions,
  }) = _Cart;

  factory Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);

  String getTotalItems() {
    return '${items?.length ?? 0} items';
  }

  double get getSubtotal{
    return items?.sumBy((element) => element.getSubtotal() ) ?? 0;
  }

  double get getTotalTaxAmount{
    return items?.sumBy((element) => element.getTotalTaxAmount() ) ?? 0;
  }

  double get getTotalDiscountAmount{
    return items?.sumBy((element) => element.getTotalDiscountAmount() ) ?? 0;
  }

  double get getTotalPrice{
    return items?.sumBy((element) => element.getTotalAmount ) ?? 0;
  }

  String getFormattedTotalPrice(BuildContext context){
    return 'ETB ${getTotalPrice.toStringAsFixed(2)}';
  }

  Cart addPaymentOption(List<PaymentOption> paymentOptions){
    return copyWith(paymentOptions: paymentOptions);
  }

  Cart updateOrderItem(OrderItem item) {
    final index = items?.indexWhere((element) => element.productId == item.productId) ?? -1;
    if (index != -1) {
      return copyWith(items: items?.map((e) => e.productId == item.productId ? item : e).toList());
    }
    return this;
  }

  OrderItem? updateItemQty(String productId, double qty) {
    final index = items?.indexWhere((element) => element.productId == productId) ?? -1;
    if (index != -1) {
      return items![index].updateQuantity(qty);
    }
    return null;
  }

  Cart removeItems(List<String> productIds) {
    return copyWith(items: items?.where((element) => !productIds.contains(element.productId)).toList());
  }
}
