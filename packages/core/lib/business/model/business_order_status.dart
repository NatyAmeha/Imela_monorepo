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
    BusinessOrderStatus(id: 'PENDING', status: [LocalizedField(key: 'ENGLISH', value: 'Pending'), LocalizedField(key: 'AMHARIC', value: 'በመካሄድ ላይ')], isDefault: true, sequence: 0),
    BusinessOrderStatus(id: 'PAYMENT_CONFIRMED', status: [LocalizedField(key: 'ENGLISH', value: 'Payment Confirmed'), LocalizedField(key: 'AMHARIC', value: 'ከፈያ ተቀባይነት')], sequence: 1),
    // BusinessOrderStatus(id: 'CONFIRMED', status: [LocalizedField(key: 'ENGLISH', value: 'Confirmed'), LocalizedField(key: 'AMHARIC', value: 'መረጃ መመዝ ላይ')], sequence: 2),
    // BusinessOrderStatus(id: 'CANCELLED', status: [LocalizedField(key: 'ENGLISH', value: 'Cancelled'), LocalizedField(key: 'AMHARIC', value: 'ተሰርዟል')], sequence: 3),
    BusinessOrderStatus(id: 'COMPLETED', status: [LocalizedField(key: 'ENGLISH', value: 'Completed'), LocalizedField(key: 'AMHARIC', value: 'ተጠናቋል')], sequence: 4),
  ];
}
