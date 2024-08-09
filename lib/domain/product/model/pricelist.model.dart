
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:melegna_customer/domain/shared/base.model.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';

part 'pricelist.model.freezed.dart';
part 'pricelist.model.g.dart';
 


 @freezed
class PriceList extends BaseModel with _$PriceList {
  const PriceList._();
  const factory PriceList({
    String? id,
    List<LocalizedField>? name,
    List<LocalizedField>? description,
    List<String>? branchIds,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
  }) = _PriceList;

  factory PriceList.fromJson(Map<String, dynamic> json) => _$PriceListFromJson(json);
}