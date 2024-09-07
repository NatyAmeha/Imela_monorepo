import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/branch/model/inventory_location.model.dart';
import 'package:imela_core/bundle/model/product_bundle.model.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_core/product/model/pricelist.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/product/model/product_price.model.dart';
import 'package:imela_core/shared/address.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';

part 'branch.model.freezed.dart';
part 'branch.model.g.dart';

@freezed
class Branch with _$Branch { 
  const Branch._();
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
    List<ProductPrice>? productPrices,
    List<PriceList>? priceLists,
  }) = _Branch;

  factory Branch.fromJson(Map<String, dynamic> json) => _$BranchFromJson(json);

  String get getAddressInfo {
    if(address?.address != null) {
      return '${address?.city}, ${address?.address}';
    }
    return address?.city ?? '';
  }
}
