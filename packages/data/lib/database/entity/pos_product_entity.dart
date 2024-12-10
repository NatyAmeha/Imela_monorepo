import 'package:imela_data/database/entity/localized_field_entity.dart';
import 'package:imela_data/database/entity/price_entity.dart';
import 'package:isar/isar.dart';

part 'pos_product_entity.g.dart';

@collection
class POSProductEntity {
  Id dbId = Isar.autoIncrement;
  @Index(unique: true)
  String? id;
  List<LocalizedFieldEntity> name = [];
  List<LocalizedFieldEntity>? description = [];
  List<String>? imageUrl;
  List<String>? category;

  int minimumOrderQty;
  int loyaltyPoint;
  String businessId;
  List<String>? branchIds;
  List<String>? sectionId;
  // String? type;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? sku;
  List<String>? optionsIncluded;
  List<String>? variantsId;
  bool? mainProduct;
  String? callToAction;
  List<ProductAddonEntity>? addons;

  POSProductEntity({
    this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.category,
    this.minimumOrderQty = 1,
    this.loyaltyPoint = 0,
    required this.businessId,
    this.branchIds,
    this.sectionId,
    this.addons,
    this.sku,
    this.optionsIncluded,
    this.variantsId,
    this.mainProduct,
    this.callToAction,
    this.createdAt,
    this.updatedAt,
  });
}

@embedded
class ProductAddonEntity {
  String? id;
  List<LocalizedFieldEntity>? name;
  String? inputType;
  List<AddonOptionEntity>? options;
  List<PriceEntity>? additionalPrice;
  double? minAmount;
  double? maxAmount;
  bool? isRequired;
  List<String>? tag;
  bool? isProduct;
  String? productId;
  DateTime? createdAt;
  DateTime? updatedAt;

  ProductAddonEntity({
    this.id,
    this.name = const [],
    this.inputType,
    this.options = const [],
    this.additionalPrice,
    this.minAmount = 1.0,
    this.maxAmount = 1.0,
    this.isRequired = false,
    this.tag,
    this.isProduct,
    this.productId,
    this.createdAt,
    this.updatedAt,
  });
}

@embedded
class AddonOptionEntity {
  String? id;
  List<LocalizedFieldEntity>? name;
  List<String>? images;

  AddonOptionEntity({
    this.id,
    this.name,
    this.images,
  });
}
