import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:melegna_customer/domain/order/model/order_config.model.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';

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