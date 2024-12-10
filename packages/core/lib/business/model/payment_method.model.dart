import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/price.model.dart';
import 'package:imela_utils/helpers/localization_utils.dart';
part 'payment_method.model.freezed.dart';
part 'payment_method.model.g.dart';

enum PaymentMethodType {
  CASH_ON_DELIVERY,
  PAY_AT_STORE,
  BANK_TRANSFER,
  ONLINE_PAYMENT,
}

@freezed
class PaymentMethodOption with _$PaymentMethodOption {
  factory PaymentMethodOption({
    List<LocalizedField>? name,
    String? account,
  }) = _PaymentMethodOption;

  factory PaymentMethodOption.fromJson(Map<String, dynamic> json) => _$PaymentMethodOptionFromJson(json);
}

@freezed
class SelectedPaymentMethod with _$SelectedPaymentMethod {
  const SelectedPaymentMethod._();
  factory SelectedPaymentMethod({
    String? id,
    required List<LocalizedField> name,
    required Price amount,
    @Default(false) bool requireReceiptImage,
    List<String>? receiptImages,
    PaymentMethodOption? paymentMethodOption,
  }) = _SelectedPaymentMethod;

  factory SelectedPaymentMethod.fromJson(Map<String, dynamic> json) => _$SelectedPaymentMethodFromJson(json);

  static SelectedPaymentMethod cashPaymentAtStore({required double amoun}) {
    return SelectedPaymentMethod(
      id: 'cash',
      name: [LocalizedField(key: AppLanguage.ENGLISH.name, value: 'Cash')],
      amount: Price(amount: amoun, currency: Currency.ETB.name),

    );
  }

  SelectedPaymentMethod addReceiptImages(List<String> receiptImages) {
    return copyWith(receiptImages: receiptImages);
  }

  SelectedPaymentMethod removeReceiptImages(List<String> receiptImages) {
    return copyWith(receiptImages: this.receiptImages?.where((image) => !receiptImages.contains(image)).toList());
  }


}

@freezed
class PaymentMethod with _$PaymentMethod {
  const PaymentMethod._();
  factory PaymentMethod({
    String? id,
    List<LocalizedField>? name,
    List<LocalizedField>? description,
    String? type,
    List<PaymentMethodOption>? options,
    @Default(false) bool requireReceiptImage,
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
        type: PaymentMethodType.CASH_ON_DELIVERY.name,
      ),
      PaymentMethod(
        id: '3',
        name: [LocalizedField(key: AppLanguage.ENGLISH.name, value: 'Mobile Banking')],
        description: [LocalizedField(key: AppLanguage.ENGLISH.name, value: 'Pay using your mobile banking account')],
      ),
      PaymentMethod(
        id: '4',
        name: [LocalizedField(key: AppLanguage.ENGLISH.name, value: 'Bank transfer')],
        description: [LocalizedField(key: AppLanguage.ENGLISH.name, value: 'Choose one of the following options to pay and upload a screenshot of the payment')],
        type: PaymentMethodType.BANK_TRANSFER.name,
        requireReceiptImage: true,
        options: [
          PaymentMethodOption(
            name: [LocalizedField(key: AppLanguage.ENGLISH.name, value: 'CBE')],
            account: '1234567890',
          ),
          PaymentMethodOption(
            name: [LocalizedField(key: AppLanguage.ENGLISH.name, value: 'Telebirr')],
            account: '915844494',
          ),
        ],
      )
    ];
  }
}
