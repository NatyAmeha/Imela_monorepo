import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela/domain/shared/localized_field.model.dart';
import 'package:imela/presentation/utils/localization_utils.dart';

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

  bool isFullPaymentOption() {
    return type == PaymentOptionType.FULL_PAYMENT.name;
  }

  bool isPartialPaymentOption() {
    return type == PaymentOptionType.PAY_LATER.name;
  }

  double currentPayment(double totalAmount) {
    if (isPartialPaymentOption()) {
      return upfrontPayment ?? totalAmount;
    }
    return totalAmount;
  }

  double remainingPayment(double totalAmount) {
    return totalAmount - (upfrontPayment ?? 0);
  }

  factory PaymentOption.fromJson(Map<String, dynamic> json) => _$PaymentOptionFromJson(json);
}
