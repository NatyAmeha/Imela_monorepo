import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela/domain/branch/model/inventory_location.model.dart';
import 'package:imela/domain/shared/price_currency.model.dart';

part 'inventory.model.freezed.dart';
part 'inventory.model.g.dart';

enum ProductUnitType { 
  Unit,
  Kg,
  Litre,
}

@freezed
// @JsonSerializable(explicitToJson: true)
class Inventory with _$Inventory {
  const Inventory._();
  const factory Inventory({
    String? id,
    String? name,
    String? sku,
    List<PriceCurrency>? priceInfo,
    double? qty,
    String? unit,
    @Default(1) int minOrderQty,
    @Default(100) int maxOrderQty,
    @Default(false) bool isAvailable,
    List<String>? optionsIncluded,
    String? inventoryLocationId,
    InventoryLocation? inventoryLocation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Inventory;

  factory Inventory.fromJson(Map<String, dynamic> json) => _$InventoryFromJson(json);
}
