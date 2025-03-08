import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/inventory/model/inventory.model.dart';
import 'package:imela_core/inventory/model/inventory_location.model.dart';

part 'inventory_response.freezed.dart';
part 'inventory_response.g.dart';

@freezed
class InventoryResponse with _$InventoryResponse {
  const InventoryResponse._();
  const factory InventoryResponse({
    bool? success,
    String? message,
    Inventory? inventory,
    List<Inventory>? inventories,

    List<InventoryLocation>? locations,
  }) = _InventoryResponse;

  factory InventoryResponse.fromJson(Map<String, dynamic> json) => _$InventoryResponseFromJson(json);

  

  bool isLocationsFetchSuccessful() {
    return success == true && locations != null;
  }
} 