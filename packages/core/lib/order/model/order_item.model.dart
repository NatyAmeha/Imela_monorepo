import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'order_config.model.dart';
import '../../shared/localized_field.model.dart';

part 'order_item.model.freezed.dart';
part 'order_item.model.g.dart';

@freezed
class OrderItem with _$OrderItem {
  const OrderItem._();
  const factory OrderItem({
    String? id,
    List<LocalizedField>? name,
    @Default(0) double quantity,
    String? branchId,
    String? image,
    String? productId,
    double? subTotal,
    double? tax,
    List<ItemDiscount>? discount,
    List<OrderConfig>? config,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _OrderItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);

  OrderItem updateQuantity(double qty) {
    return copyWith(quantity: qty);
  }

  double getSubtotal() {
    return (subTotal ?? 0) * (quantity);
  }

  double getTotalDiscountAmount() {
    return discount?.sumBy((element) => element.amount ?? 0) ?? 0;
  }

  double getTotalTaxAmount() {
    return tax ?? 0;
  }

  double get getTotalAmount {
    return getSubtotal() + getTotalTaxAmount() - getTotalDiscountAmount();
  }
}

@freezed
class ItemDiscount with _$ItemDiscount {
  const ItemDiscount._();

  const factory ItemDiscount({
    String? id,
    List<LocalizedField>? name,
    double? amount,
  }) = _ItemDiscount;

  factory ItemDiscount.fromJson(Map<String, dynamic> json) => _$ItemDiscountFromJson(json);
}
