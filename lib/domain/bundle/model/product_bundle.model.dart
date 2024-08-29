import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela/domain/branch/model/branch.model.dart';
import 'package:imela/domain/business/model/business.model.dart';
import 'package:imela/domain/product/model/discount.model.dart';
import 'package:imela/domain/product/model/product.model.dart';
import 'package:imela/domain/shared/gallery.model.dart';
import 'package:imela/domain/shared/localized_field.model.dart';
import 'package:imela/presentation/utils/localization_utils.dart';

part 'product_bundle.model.freezed.dart';
part 'product_bundle.model.g.dart';

@freezed
class ProductBundle with _$ProductBundle {
  const ProductBundle._();
  const factory ProductBundle({
    String? id,
    List<LocalizedField>? name,
    List<LocalizedField>? description,
    String? type,
    List<String>? productIds,
    List<String>? branchIds,
    String? businessId,
    DateTime? startDate,
    DateTime? endDate,
    Gallery? gallery,
    Discount? discount,
    List<Product>? products,
    Business? business,
    List<Branch>? branches,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ProductBundle;

  factory ProductBundle.fromJson(Map<String, dynamic> json) => _$ProductBundleFromJson(json);

  String getBundleName(AppLanguage selectedLanguage){
    return name.localize();
  }

  String getBundleProducts() {
    return '${productIds?.length} items';
  }

  List<String?> getBundleProductImages() {
    return products!.map((e) => e.gallery!.getImage()).toList();
  }
}
