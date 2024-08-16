import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:melegna_customer/domain/branch/model/branch.model.dart';
import 'package:melegna_customer/domain/business/model/business.model.dart';

part 'inventory_location.model.freezed.dart';
part 'inventory_location.model.g.dart';

@freezed
// @JsonSerializable(explicitToJson: true)
class InventoryLocation with _$InventoryLocation {
  const InventoryLocation._();
  const factory InventoryLocation({
    String? id,
    String? name,
    String? city,
    String? location,
    String? address,
    String? phoneNumber,
    String? branchId,
    Branch? branch,
    String? businessId,
    Business? business,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _InventoryLocation;

  factory InventoryLocation.fromJson(Map<String, dynamic> json) => _$InventoryLocationFromJson(json);
}
