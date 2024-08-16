import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:melegna_customer/domain/order/model/order_item.model.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';

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
  }) = _Cart;

  factory Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);

  String getTotalItems(){
    return '${items?.length ?? 0} items';
  }
  
}