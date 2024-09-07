import 'package:freezed_annotation/freezed_annotation.dart';
import '../../shared/localized_field.model.dart';
part 'payment_method.model.freezed.dart';
part 'payment_method.model.g.dart';

enum PaymentMethodType {
  CASH_ON_DELIVERY,
  PAY_AT_STORE,
  BANK_TRANSFER,
  ONLINE_PAYMENT,
}

@freezed
class PaymentMethod with _$PaymentMethod {
  const PaymentMethod._(); 
  factory PaymentMethod({
    String? id,
    List<LocalizedField>? name,
    String? type,
   
  }) = _PaymentMethod;

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => _$PaymentMethodFromJson(json);
}
