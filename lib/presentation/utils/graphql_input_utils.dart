import 'package:melegna_customer/data/network/graphql/__generated__/schema.schema.gql.dart';
import 'package:melegna_customer/domain/order/model/order_item.model.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';

extension LanguageKey on String? {
  GLanguageKey? get toLanguageKeyInput {
    if (this == null) return null;

    if (this == GLanguageKey.AMHARIC.name) {
      return GLanguageKey.AMHARIC;
    } else if (this == GLanguageKey.ENGLISH.name) {
      return GLanguageKey.ENGLISH;
    } else if (this == GLanguageKey.OROMIC.name) {
      return GLanguageKey.OROMIC;
    } else {
      return GLanguageKey.ENGLISH;
    }
  }

  GPaymentOptionType? get toPaymentOptionTypeInput {
    if (this == null) return null;

    if (this == GPaymentOptionType.FULL_PAYMENT.name) {
      return GPaymentOptionType.FULL_PAYMENT;
    } else if (this == GPaymentOptionType.PAY_LATER.name) {
      return GPaymentOptionType.PAY_LATER;
    } else {
      return GPaymentOptionType.FULL_PAYMENT;
    }
  }
}

extension LocalizedFieldInput on List<LocalizedField> {
  List<GLocalizedFieldInput> toLocalizedFieldInput() {
    return map((e) => GLocalizedFieldInput(
          (name) => name
            ..key = e.key.toLanguageKeyInput
            ..value = e.value,
        )).toList();
  }
}

extension GraphqlOrderInput on List<OrderItem> {
  List<GCreateOrderItemInput> toOrderItemInput() {
    return map(
      (item) => GCreateOrderItemInput((orderItem) => orderItem
        ..name.addAll(item.name!.toLocalizedFieldInput())
        ..productId = item.productId
        ..branchId = item.branchId
        ..image = item.image
        ..subTotal = item.subTotal
        ..discount.addAll(item.discount.toOrderDiscountInput())
        ..config.addAll(item.config?.map(
              (config) => GCreateOrderConfigInput((configInput) => configInput
                ..addonId = config.addonId
                ..name.addAll(config.name!.toLocalizedFieldInput())
                ..type = config.type
                ..singleValue = config.singleValue
                ..multipleValue.addAll(config.multipleValue ?? [])
                ..additionalPrice = config.additionalPrice
                ..productIds.addAll(config.productIds?.map((e) => e) ?? [])),
            ) ??
            []) 
        ..quantity = item.quantity),
    ).toList();
  }
}

extension GraphqlDiscountInput on List<ItemDiscount>? {
  List<GOrderItemDiscountInput> toOrderDiscountInput() {
    if (this == null || this!.isEmpty) return [];
    return this!
        .map(
          (discount) => GOrderItemDiscountInput((discountInput) => discountInput
            ..amount = discount.amount
            ..name.addAll(discount.name!.toLocalizedFieldInput())),
        )
        .toList();
  }
}
