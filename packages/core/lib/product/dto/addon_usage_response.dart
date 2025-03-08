import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/order/model/order_config.model.dart';

part 'addon_usage_response.freezed.dart';
part 'addon_usage_response.g.dart';

@freezed
class AddonUsageResponse with _$AddonUsageResponse {
  const AddonUsageResponse._();
  factory AddonUsageResponse({
    String? addonId,
    int? count,
    List<OrderInfo>? orderIdInfo,
  }) = _AddonUsageResponse;

  factory AddonUsageResponse.fromJson(Map<String, dynamic> json) => _$AddonUsageResponseFromJson(json);
}

@freezed
class OrderInfo with _$OrderInfo {
  const OrderInfo._();
  factory OrderInfo({
    String? orderId,
    DateTime? dateCreated,
    OrderConfig? config,
  }) = _OrderInfo;

  factory OrderInfo.fromJson(Map<String, dynamic> json) => _$OrderInfoFromJson(json);
} 
