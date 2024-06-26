import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:melegna_customer/domain/branch/branch.model.dart';
import 'package:melegna_customer/domain/business/model/business.model.dart';
import 'package:melegna_customer/domain/product/model/discount.model.dart';
import 'package:melegna_customer/domain/product/model/product.model.dart';
import 'package:melegna_customer/domain/shared/gallery.model.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';

part 'product_bundle.model.freezed.dart';
part 'product_bundle.model.g.dart';

@freezed
class ProductBundle with _$ProductBundle {
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
}