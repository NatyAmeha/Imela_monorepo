import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';
import 'package:melegna_customer/presentation/utils/localization_utils.dart';

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
    double? upfrontPayment,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PaymentOption;

  static PaymentOption defaultPaymentOption() {
    return PaymentOption(
      id: 'full_payment_id',
      name: [LocalizedField(key: AppLanguage.ENGLISH.name, value: 'Full payment')],
      type: PaymentOptionType.FULL_PAYMENT.toString(),
      upfrontPayment: 0,
      dueDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  factory PaymentOption.fromJson(Map<String, dynamic> json) => _$PaymentOptionFromJson(json);
}
