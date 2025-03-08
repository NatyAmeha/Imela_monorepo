import 'package:freezed_annotation/freezed_annotation.dart';

part 'receipts.model.freezed.dart';
part 'receipts.model.g.dart';

@freezed
class ReadReceipt with _$ReadReceipt {
  const ReadReceipt._();
  const factory ReadReceipt({
    required String userId,
    required DateTime readAt,
  }) = _ReadReceipt;

  factory ReadReceipt.fromJson(Map<String, dynamic> json) => _$ReadReceiptFromJson(json);
}

@freezed
class DeliveryReceipt with _$DeliveryReceipt {
  const DeliveryReceipt._();
  const factory DeliveryReceipt({
    required String userId,
    required DateTime deliveredAt,
  }) = _DeliveryReceipt;

  factory DeliveryReceipt.fromJson(Map<String, dynamic> json) => _$DeliveryReceiptFromJson(json);
} 