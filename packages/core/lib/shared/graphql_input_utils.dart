import 'package:imela_core/business/model/payment_option.model.dart';
import 'package:imela_core/order/model/order_config.model.dart';
import 'package:imela_core/order/model/order_item.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/price.model.dart';
import 'package:imela_data/network/graphql/__generated__/schema.schema.gql.dart';

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

  GCurrencyKey? get toCurrencyKeyInput {
    if (this == null) return null;

    if (this == GCurrencyKey.USD.name) {
      return GCurrencyKey.USD;
    } else if (this == GCurrencyKey.ETB.name) {
      return GCurrencyKey.ETB;
    } else {
      return GCurrencyKey.ETB;
    }
  }

  GAddonInputType? get toAddonInputType {
    if (this == null) return null;

    if (this == GAddonInputType.NUMBER_INPUT.name) {
      return GAddonInputType.NUMBER_INPUT;
    } else if (this == GAddonInputType.SINGLE_SELECTION_INPUT.name) {
      return GAddonInputType.SINGLE_SELECTION_INPUT;
    } else if (this == GAddonInputType.MULTIPLE_SELECTION_INPUT) {
      return GAddonInputType.MULTIPLE_SELECTION_INPUT;
    } else if (this == GAddonInputType.DATE_TIME_INPUT.name) {
      return GAddonInputType.DATE_TIME_INPUT;
    } else if (this == GAddonInputType.TEXT_INPUT.name) {
      return GAddonInputType.TEXT_INPUT;
    } else if (this == GAddonInputType.DATE_INPUT.name) {
      return GAddonInputType.DATE_INPUT;
    } else {
      return GAddonInputType.TEXT_INPUT;
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

extension PriceInput on List<Price>? {
  List<GPriceInput> toPriceInput() {
    if (this == null || this!.isEmpty) return [];
    return this!
        .map((e) => GPriceInput((price) => price
          ..amount = e.amount
          ..currency = e.currency.toCurrencyKeyInput))
        .toList();
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
        ..subTotal = item.getSubtotal()
        ..discount.addAll(item.discount.toOrderDiscountInput())
        ..config.addAll(item.config.toOrderConfigInput())
        ..quantity = item.quantity),
    ).toList();
  }
}

extension GraphqlOrderConfigInput on List<OrderConfig>? {
  List<GCreateOrderConfigInput> toOrderConfigInput() {
    if (this == null || this!.isEmpty) return [];
    return this!
        .map(
          (config) => GCreateOrderConfigInput(
            (configInput) => configInput
              ..addonId = config.addonId
              ..name.addAll(config.name!.toLocalizedFieldInput())
              ..type = config.type
              ..singleValue = config.singleValue
              ..multipleValue.addAll(config.multipleValue ?? [])
              ..additionalPrice = config.additionalPrice
              ..productIds.addAll(config.productIds?.map((e) => e) ?? []),
          ),
        )
        .toList();
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

extension GraphqlPaymentOptionInput on List<PaymentOption>? {
  List<GCreatePaymentOptionInput> toPaymentOptionInput() {
    if (this == null || this!.isEmpty) return [];
    return this!
        .map(
          (paymentOption) => GCreatePaymentOptionInput(
            (paymentOptionInput) => paymentOptionInput
              ..name.addAll(paymentOption.name!.toLocalizedFieldInput())
              ..type = paymentOption.type.toPaymentOptionTypeInput
              ..upfrontPayment = paymentOption.upfrontPayment
              ..dueDate
              ..dueDate.update((dueDate) => dueDate.value = (paymentOption.dueDate ?? DateTime.now()).toIso8601String()),
          ),
        )
        .toList();
  }
}

class GraphqlInputUtils {
  static GDateTimeBuilder toDateTimeInput(GDateTimeBuilder b) {
    b.value = DateTime.now().toIso8601String();
    return b;
  }
}
