// import 'package:imela_core/product/model/product.model.dart';
// import 'package:imela_core/product/model/product_addon.model.dart';
// import 'package:imela_data/database/entity/localized_field_entity.dart';
// import 'package:imela_data/database/entity/pos_product_entity.dart';
// import 'package:imela_data/database/entity/price_entity.dart';

// extension ProductToEntityExtension on Product {
//   POSProductEntity toPOSProductEntity(String businessId, String branchId) {
//     return POSProductEntity(
//       id: id,
//       name: name!.map((e) => LocalizedFieldEntity(key: e.key, value: e.value)).toList(),
//       description: description?.map((e) => LocalizedFieldEntity(key: e.key, value: e.value)).toList(),
//       businessId: businessId,
//       branchIds: [branchId],
//       sectionId: sectionId,
//       minimumOrderQty: minimumOrderQty,
//       loyaltyPoint: loyaltyPoint,
//       sku: sku,
//       addons: addons?.toProductAddonEntity(),
//       optionsIncluded: optionsIncluded,
//       variantsId: variantsId,
//       createdAt: createdAt,
//       updatedAt: updatedAt,
//     );
//   }
// }

// extension ProductAddonToEntityExtension on ProductAddon {
//   ProductAddonEntity toProductAddonEntity() {
//     return ProductAddonEntity(
//       id: id,
//       name: name!.map((e) => LocalizedFieldEntity(key: e.key, value: e.value)).toList(),
//       isRequired: isRequired,
//       inputType: inputType,
//       minAmount: minAmount,
//       maxAmount: maxAmount,
//       options: options.map((e) => AddonOptionEntity(name: e.name!.map((e) => LocalizedFieldEntity(key: e.key, value: e.value)).toList(), images: e.images)).toList(),
//       additionalPrice: additionalPrice?.map((e) => PriceEntity(amount: e.amount, currency: e.currency)).toList(),
//     );
//   }
// }


// extension ProductListToEntityExtension on List<Product> {
//   List<POSProductEntity> toPOSProductEntity(String businessId, String branchId) {
//     return map((e) => e.toPOSProductEntity(businessId, branchId)).toList();
//   }
// }


// extension ProductAddonListToEntityExtension on List<ProductAddon> {
//   List<ProductAddonEntity> toProductAddonEntity() {
//     return map((e) => e.toProductAddonEntity()).toList();
//   }
// }

