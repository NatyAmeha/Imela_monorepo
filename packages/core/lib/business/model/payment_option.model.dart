import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/shared/graphql_input_utils.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_utils/helpers/localization_utils.dart';
import 'package:imela_utils/helpers/number_utils.dart';

part 'payment_option.model.freezed.dart';
part 'payment_option.model.g.dart';

enum PaymentOptionType { FULL_PAYMENT, INSTALLMENT, DEPOSIT, PAY_LATER }

@freezed
class PaymentOption with _$PaymentOption {
  const PaymentOption._();
  factory PaymentOption({
    String? id,
    List<LocalizedField>? name,
    List<LocalizedField>? description,
    String? type,
    double? upfrontPayment,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PaymentOption;

  Function toGraphQLInput() {
    return (b) => b
      ..name.addAll(name!.toLocalizedFieldInput())
      ..type = type!.toPaymentOptionTypeInput
      ..upfrontPayment = upfrontPayment
      ..dueDate.update(GraphqlInputUtils.toDateTimeInput);
  }

  static PaymentOption defaultPaymentOption() {
    return PaymentOption(
      id: 'full_payment_id',
      name: [LocalizedField(key: AppLanguage.ENGLISH.name, value: 'Full payment')],
      description: [LocalizedField(key: AppLanguage.ENGLISH.name, value: 'Pay the full amount upfront')],
      type: PaymentOptionType.FULL_PAYMENT.toString(),
      upfrontPayment: 0,
      dueDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  String getName(String selectedLanguage) {
    if (type == PaymentOptionType.DEPOSIT.name) {
      return '${name?.localize(selectedLanguage)} (${upfrontPayment?.getPresision(2)}%)';
    }
    return name?.localize(selectedLanguage) ?? '';
  }

  bool isFullPaymentOption() {
    return type == PaymentOptionType.FULL_PAYMENT.name;
  }

  bool isPartialPaymentOption() {
    return type == PaymentOptionType.PAY_LATER.name || type == PaymentOptionType.DEPOSIT.name;
  }

  double currentPayment(double totalAmount) {
    if (isPartialPaymentOption()) {
      return totalAmount.getPercentage(upfrontPayment ?? 0, deductPercentageFromOriginalPrice: false).getPresision(2);
    }
    return totalAmount.getPresision(2);
  }

  double remainingPayment(double totalAmount) {
    return (totalAmount - currentPayment(totalAmount)).getPresision(2);
  }

  String currentPaymentString(double totalAmount, {String currency = 'ETB'}) {
    return '$currency ${currentPayment(totalAmount).getPresision(2)}';
  }

  String remainingPaymentString(double totalAmount, {String currency = 'ETB'}) {
    return '$currency ${remainingPayment(totalAmount).getPresision(2)}';
  }

  factory PaymentOption.fromJson(Map<String, dynamic> json) => _$PaymentOptionFromJson(json);
}
