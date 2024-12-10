import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/customer/model/customer.model.dart';
import 'package:imela_core/loyalty/model/customer_loyalty.model.dart';
import 'package:imela_core/loyalty/model/reward.model.dart';

part 'loyalty.response.freezed.dart';
part 'loyalty.response.g.dart';

@freezed
class LoyaltyResponse with _$LoyaltyResponse {
  const LoyaltyResponse._();
  const factory LoyaltyResponse({
    @Default(false) bool success,
    bool? message,
    List<Reward>? rewards,
    CustomerLoyalty? customerLoyalty,
    List<CustomerLoyalty>? customerLoyalties,
    Customer? customer,
  }) = _LoyaltyResponse;

  factory LoyaltyResponse.fromJson(Map<String, dynamic> json) => _$LoyaltyResponseFromJson(json);
}
