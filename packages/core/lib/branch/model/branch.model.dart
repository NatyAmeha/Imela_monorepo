import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/branch/model/inventory_location.model.dart';
import 'package:imela_core/bundle/model/product_bundle.model.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_core/product/model/pricelist.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/product/model/product_price.model.dart';
import 'package:imela_core/shared/address.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_utils/helpers/localization_utils.dart';

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
    if (address?.address != null) {
      return '${address?.city}, ${address?.address}';
    }
    return address?.city ?? '';
  }

  static List<Branch> fakeBranches = [
    Branch(
      id: '1',
      name: [LocalizedField(key: AppLanguage.ENGLISH.name, value: 'Branch 1')],
      phoneNumber: '0912345678',
      email: 'fakebranch@gmail.com',
      website: 'www.fakebranch.com',
      address: Address(
        city: 'Addis Ababa',
        address: 'Bole, Addis Ababa, Ethiopia',
      ),
      productIds: ['1', '2', '3'],
      businessId: '1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
      inventoryLocations: [
        InventoryLocation(name: 'Branch 1', city: 'Addis Ababa', address: 'Bole, Addis Ababa, Ethiopia'),
      ]
    ),
    Branch(
      id: '2',
      name: [LocalizedField(key: AppLanguage.ENGLISH.name, value: 'Branch 2')],
      phoneNumber: '0912345678',
      email: 'fakebranch2@gmail.com',
      website: 'www.fakebranch2.com',
      address: Address(
        city: 'Addis Ababa',
        address: 'Bole, Addis Ababa, Ethiopia',
      ),
      productIds: ['1', '2', '3'],
      businessId: '1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      inventoryLocations: [
          InventoryLocation(name: 'Branch 2 Location', city: 'Addis Ababa', address: 'Bole, Addis Ababa, Ethiopia'),
        ]
    )
  ];
}
