import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_utils/helpers/localization_utils.dart';
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

  String enteredAmount(Map<String, double> paymentMethodsIdsWithAmount) {
    return paymentMethodsIdsWithAmount[id]?.toString() ?? '0';
  }

  static List<PaymentMethod> platformPaymentMethods() {
    return [
      PaymentMethod(
        id: '1',
        name: [LocalizedField(key: AppLanguage.ENGLISH.name, value: 'Pay using chapa')],
      ),
    ];
  }

  static List<PaymentMethod> getFakePaymentMethods() {
    return [
      PaymentMethod(
        id: '2',
        name: [LocalizedField(key: AppLanguage.ENGLISH.name, value: 'Cash')],
      ),
      PaymentMethod(
        id: '3',
        name: [LocalizedField(key: AppLanguage.ENGLISH.name, value: 'Mobile Banking')],
      ),
    ];
  }
}
