import 'dart:convert';

import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/business/model/business_order_status.dart';
import 'package:imela_core/business/model/payment_method.model.dart';
import 'package:imela_core/business/model/payment_option.model.dart';
import 'package:imela_core/calendar/model/calendar_booking.model.dart';
import 'package:imela_core/customer/model/customer.model.dart';
import 'package:imela_core/order/model/order_config.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_utils/helpers/localization_utils.dart';
import 'package:imela_utils/helpers/number_utils.dart';
import 'order_item.model.dart';

import 'cart.model.dart';

part 'order.model.freezed.dart';
part 'order.model.g.dart';

enum OrderStatus {
  PENDING,
  PAYMENT_APPROVED,
  PROCESSING,
  COMPLETED,
  CANCELLED,
  REFUNDED,
  FAILED,
}

@freezed
class Order with _$Order {
  const Order._();
  const factory Order({
    String? id,
    int? orderNumber,
    String? code,
    String? status,
    List<OrderItem>? items,
    String? userId,
    String? customerPhoneNumber,
    Customer? customer,
    String? paymentType,
    double? subTotal,
    List<ItemDiscount>? discount,
    double? totalAmount,
    double? paidAmount,
    @Default(0) double remainingAmount,
    List<OrderConfig>? config,
    List<SelectedPaymentMethod>? paymentMethods,
    @Default([]) List<String>? appliedRewards,
    @Default(0) double usedRewardsPoints,
    bool? isOnlineOrder,
    String? note,
    List<String>? businessId,
    List<Schedule>? schedules,
    String? branchId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  static Order createOrderInfo(
    Cart cartIfno, {
    required PaymentOption paymentOption,
    required double paidAmount,
    required double totalAmount,
    required List<SelectedPaymentMethod> paymentMethods,
    String? branchId,
    String? orderNote,
    List<String>? appliedRewards,
    double? usedRewardsPoints,
  }) {
    final remainingAmount = totalAmount - paidAmount;
    
    return Order(
        paymentType: paymentOption.type,
        items: cartIfno.items,
        isOnlineOrder: true,
        subTotal: cartIfno.getSubtotalPOSUpdated(includeAddonPrice: false, includeDynamicPricingDiscount: true),
        totalAmount: totalAmount,
        config: cartIfno.configs,
        paidAmount: paidAmount,
        note: orderNote,
        remainingAmount: remainingAmount,
        paymentMethods: paymentMethods,
        businessId: cartIfno.businessIds,
        branchId: branchId,
        appliedRewards: appliedRewards,
        usedRewardsPoints: usedRewardsPoints ?? 0.0);
  }

  double getSubtotalAmount() {
    return items?.sumBy((item) => item.getSubtotalPOSUpdated(includeAddonPrice: false)) ?? 0;
  }

  double getTotalAmount() {
    return items?.sumBy((item) => item.getTotalAmountPOS()) ?? 0;
  }

  double getTotalDiscountAmount() {
    return items?.sumBy((item) => item.getTotalDiscountAmountPOS(discountFromAmount: true)) ?? 0;
  }

  double getTotalAddonAmount() {
    return items?.sumBy((item) => item.getTotalAddonPrices()) ?? 0;
  }

  String subtotalAmountString(String selectedCurrency, String selectedLanguage) {
    return '$selectedCurrency ${getSubtotalAmount().getPresisionString(precision: 2)}';
  }

  String totalAmountString(String selectedCurrency, String selectedLanguage) {
    return '$selectedCurrency ${getTotalAmount().getPresisionString(precision: 2)}';
  }

  String totalDiscountString(String selectedCurrency, String selectedLanguage) {
    return '$selectedCurrency ${getTotalDiscountAmount().getPresisionString(precision: 2)}';
  }

  String remainingAmountString(String selectedCurrency, String selectedLanguage) {
    return '$selectedCurrency ${remainingAmount.getPresisionString()}';
  }

   String paidAmountString(String selectedCurrency, String selectedLanguage) {
    return '$selectedCurrency ${paidAmount?.getPresisionString()}';
  }

  double getTotalEarnedPoints() {
    return items?.sumBy((item) => (item.point ?? 0) * item.quantity) ?? 0.0;
  }

  String getTotalEarnedPointsString(String selectedLanguage) {
    final allPoints = getTotalEarnedPoints();
    final localizedString = LocalizationUtils.returnLocalizedString(selectedLanguage, englishString: 'Point', amharicString: 'ነጥብ');
    return '$allPoints $localizedString';
  }

  Map<String, List<String>>? getPaymentProofImages() {
    return paymentMethods?.asMap().map((key, value) => MapEntry(value.id!, value.receiptImages ?? []));
  }

  Map<String, List<dynamic>?>?getPaymentProofImagesUploaded() {
    var paymentProofMap =  paymentMethods?.asMap().map((key, value) => MapEntry(value.id!, value.receiptImagesUploaded ?? []));
    paymentProofMap?.removeWhere((key, value) => value.isEmpty == true);
    return paymentProofMap;
  }

  Order addPaymentProofImages(Map<String, List<String>?> uploadResult) {
    final updatedPaymentMethods = paymentMethods?.map((method) {
      final image = uploadResult[method.id!];
      if (image != null) {
        return method.addReceiptImages(image);
      }
      return method;
    }).toList();
    return copyWith(paymentMethods: updatedPaymentMethods);
  }

  String getOrderStatus(String selectedLanguage, List<BusinessOrderStatus> businessOrderStatus) {
    final selectedStatus = businessOrderStatus.firstOrNullWhere((bs) => bs.id == status) ?? businessOrderStatus.firstOrNullWhere((bs) => bs.isDefault ?? false) ?? businessOrderStatus.firstOrNull;
    return selectedStatus?.status?.localize(selectedLanguage) ?? 'Pending';
  }

  Order updateOrderStatus(String statusId) {
    return copyWith(status: statusId);
  }

  String getOrderQueryParam() {
    return Uri.encodeComponent(jsonEncode(toJson()));
  }

  Order? updateSchedules(Schedule result) {
    final updatedSchedules = schedules?.map((schedule) {
      if (schedule.id == result.id) {
        return result;
      }
      return schedule;
    }).toList();
    return copyWith(schedules: updatedSchedules);
  }

  void getOrderCalendars() {
    final calendars = schedules?.map((schedule) => schedule.calendar).toList();
    print(calendars);
  }
}
