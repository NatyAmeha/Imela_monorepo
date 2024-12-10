import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/shared/localized_field.model.dart';

part 'business_order_status.freezed.dart';
part 'business_order_status.g.dart';

@freezed
class BusinessOrderStatus with _$BusinessOrderStatus {
  const BusinessOrderStatus._();
  const factory BusinessOrderStatus({
    required final String? id,
    required final List<LocalizedField>? status,
    final List<LocalizedField>? description,
    @Default(true) final bool? isActive,
    @Default(false) final bool? isDefault,
    @Default(0) final int? sequence,
  }) = _BusinessOrderStatus;

  factory BusinessOrderStatus.fromJson(Map<String, dynamic> json) => _$BusinessOrderStatusFromJson(json);

  static const List<BusinessOrderStatus> defaultOrderStatuses = [
    BusinessOrderStatus(id: 'PENDING', status: [const LocalizedField(key: 'ENGLISH', value: 'Pending'), const LocalizedField(key: 'AMHARIC', value: 'በመካሄድ ላይ')]),
    BusinessOrderStatus(id: 'PAYMENT_CONFIRMED', status: [const LocalizedField(key: 'ENGLISH', value: 'Payment Confirmed'), const LocalizedField(key: 'AMHARIC', value: 'ከፈያ ተቀባይነት')]),
    BusinessOrderStatus(id: 'CONFIRMED', status: [const LocalizedField(key: 'ENGLISH', value: 'Confirmed'), const LocalizedField(key: 'AMHARIC', value: 'መረጃ መመዝ ላይ')]),
    BusinessOrderStatus(id: 'CANCELLED', status: [const LocalizedField(key: 'ENGLISH', value: 'Cancelled'), const LocalizedField(key: 'AMHARIC', value: 'ተሰርዟል')]),
    BusinessOrderStatus(id: 'COMPLETED', status: [const LocalizedField(key: 'ENGLISH', value: 'Completed'), const LocalizedField(key: 'AMHARIC', value: 'ተጠናቋል')]),
  ];
}
