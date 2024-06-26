import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';
import 'package:melegna_customer/domain/shared/price.model.dart';
part 'product_addon.model.freezed.dart';
part 'product_addon.model.g.dart';

@freezed
class ProductAddon with _$ProductAddon {
  const ProductAddon._();
  factory ProductAddon({
    String? id,
    List<LocalizedField>? name,
    List<LocalizedField>? displayName,
    List<LocalizedField>? description,
    List<Price>? additionalPrice,
    @Default(1.0) double minQty,
    @Default(1.0) double maxQty,
    @Default(true) bool isActive,
    @Default(false) bool isRequired,
    List<String>? tag,
    bool? isProduct,
    String? productId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ProductAddon;

  factory ProductAddon.fromJson(Map<String, dynamic> json) => _$ProductAddonFromJson(json);
}
