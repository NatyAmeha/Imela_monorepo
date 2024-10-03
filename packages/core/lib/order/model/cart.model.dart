import 'package:dartx/dartx.dart';
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/business/model/payment_option.model.dart';
import 'package:imela_core/order/model/order_config.model.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_utils/helpers/number_utils.dart';
import 'order_item.model.dart';
part 'cart.model.freezed.dart';
part 'cart.model.g.dart';

@freezed
class Cart with _$Cart {
  const Cart._();
  const factory Cart({
    String? id,
    List<LocalizedField>? name,
    String? businessId,
    String? userId,
    @Default(false) bool isBundleCart,
    List<OrderItem>? items,
    List<OrderConfig>? configs,
    List<ProductAddon>? orderAddons,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<PaymentOption>? paymentOptions,
  }) = _Cart;

  factory Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);

  String getTotalItems() {
    return '${items?.length ?? 0} items';
  }

  double get getSubtotal {
    return (items?.sumBy((element) => element.subTotal ?? 0) ?? 0).getPresision(2);
  }

  String getSubtotalFormatted(String selectedCurrency) {
    return '$selectedCurrency $getSubtotal';
  }

  double get getTotalTaxAmount {
    return (items?.sumBy((element) => element.getTotalTaxAmount()) ?? 0).getPresision(2);
  }

  double get getTotalDiscountAmount {
    final dicountInfo = (items ?? []).map((element) => element.discount ?? []).flatten().toList();
    return (dicountInfo.sumBy((element) => element.amount ?? 0)).getPresision(2);
  }

  double get getTotalPrice {
    return (items?.sumBy((element) => element.getTotalAmount) ?? 0).getPresision(2);
  }

  String getFormattedTotalPrice(BuildContext context) {
    return 'ETB ${getTotalPrice.toStringAsFixed(2)}';
  }

  Cart addPaymentOption(List<PaymentOption> paymentOptions) {
    return copyWith(paymentOptions: paymentOptions);
  }

  Cart addOrderAddons(List<ProductAddon> orderAddons) {
    if (orderAddons.isEmpty) return this;
    return copyWith(orderAddons: orderAddons);
  }

  Cart updateOrderItem(OrderItem item) {
    final index = items?.indexWhere((element) => element.productId == item.productId) ?? -1;
    if (index != -1) {
      return copyWith(items: items?.map((e) => e.productId == item.productId ? item : e).toList());
    }
    return this;
  }

  Cart removeItems(List<String> productIds) {
    return copyWith(items: items?.where((element) => !productIds.contains(element.productId)).toList());
  }

  bool hasOrderAddons() {
    return orderAddons?.isNotEmpty ?? false;
  }

  Cart addSelectedOrderConfigs(List<OrderConfig> configs) {
    if (configs.isEmpty) return this;
    return copyWith(configs: configs);
  }
}
