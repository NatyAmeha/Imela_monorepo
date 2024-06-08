import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:melegna_customer/domain/branch/inventory_location.model.dart';
import 'package:melegna_customer/domain/business/model/business.model.dart';
import 'package:melegna_customer/domain/product/product.model.dart';
import 'package:melegna_customer/domain/product/product_bundle.model.dart';
import 'package:melegna_customer/domain/shared/address.model.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';

part 'branch.model.freezed.dart';
part 'branch.model.g.dart';

@freezed
// @JsonSerializable(explicitToJson: true)
class Branch with _$Branch {
  const factory Branch({
    String? id,
    List<LocalizedField>? name,
    String? phoneNumber,
    String? email,
    String? website,
    Address? address,
    List<String>? productIds,
    List<Product>? products,
    String? businessId,
    Business? business,
    List<String>? staffsId,
    // List<Staff>? staffs,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    List<InventoryLocation>? inventoryLocations,
    List<ProductBundle>? bundles,
  }) = _Branch;

  factory Branch.fromJson(Map<String, dynamic> json) => _$BranchFromJson(json);
}


