
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/shared/price.model.dart';

part 'create_inventory.input.freezed.dart';
part 'create_inventory.input.g.dart';

@freezed  
class CreateInventoryInput with _$CreateInventoryInput {
  
  const CreateInventoryInput._();
  const factory CreateInventoryInput({
    List<Price>? priceInfo,
    double? qty,
    String? unit,
    int? minOrderQty,
    String? inventoryLocationId,
  }) = _CreateInventoryInput;

  factory CreateInventoryInput.fromJson(Map<String, dynamic> json) => _$CreateInventoryInputFromJson(json);

  
}
