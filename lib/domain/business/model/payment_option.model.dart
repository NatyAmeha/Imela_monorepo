import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';

part 'payment_option.model.freezed.dart';
part 'payment_option.model.g.dart';

enum PaymentOptionType { FULL_PAYMENT, INSTALLMENT, DEPOSIT, PAY_LATER }

@freezed
class PaymentOption with _$PaymentOption {
  const PaymentOption._();
  factory PaymentOption({
   String? id,
     List<LocalizedField>? name,
     String? type,
    double?  upfrontPayment,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,

  }) = _PaymentOption;

  factory PaymentOption.fromJson(Map<String, dynamic> json) => _$PaymentOptionFromJson(json);
}
