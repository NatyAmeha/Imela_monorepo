import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela/domain/shared/localized_field.model.dart';

part 'order_payment_method.model.freezed.dart';
part 'order_payment_method.model.g.dart';

@freezed
class OrderPaymentMethod with _$OrderPaymentMethod {
  const OrderPaymentMethod._();
  const factory OrderPaymentMethod({
    String? id,
    List<LocalizedField>? name,
    double? amount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _OrderPaymentMethod;
  
  factory OrderPaymentMethod.fromJson(Map<String, dynamic> json) => _$OrderPaymentMethodFromJson(json);
}