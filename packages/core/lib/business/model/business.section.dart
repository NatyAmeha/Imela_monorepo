import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/shared/utils/filter_models.dart';
import '../../shared/localized_field.model.dart';

part 'business.section.freezed.dart';
part 'business.section.g.dart';

@freezed
class BusinessSection with _$BusinessSection {
  const BusinessSection._();
  factory BusinessSection({
    String? id,
    List<LocalizedField>? name,
    String? categoryId,
    List<String>? productIds,
    List<String>? bundleIds,
    List<String>? images,
    bool? showOnStore,
    List<LocalizedField>? description,
    List<ProductAddon>? orderAddons,
    List<FilterCategory>? filterCategories,
  }) = _BusinessSection;

  factory BusinessSection.fromJson(Map<String, dynamic> json) => _$BusinessSectionFromJson(json);

  List<ProductAddon> getAddons({bool getDefault = false, bool forPOS = false}) {
    // return addons;
    var result = <ProductAddon>[];
    if (forPOS) {
      result = orderAddons?.where((e) => e.includeOnPOS == true).toList() ?? [];
    }
    if (getDefault) {
      result = orderAddons?.where((e) => e.inputType == 'NONE').toList() ?? [];
      return result;
    }

    result = result.where((e) => e.inputType != 'NONE').toList();
    return result;
  }
}
