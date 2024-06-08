import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:melegna_customer/domain/shared/base.model.dart';
import 'package:melegna_customer/domain/shared/gallery.model.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';
part 'business.model.freezed.dart';
part 'business.model.g.dart';

@freezed
// @JsonSerializable(explicitToJson: true)
class Business extends BaseModel with _$Business { 
  const factory Business({
    required String id,
    List<LocalizedField>? name,
    String? type,
    List<String>? categories,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? creator,
    Gallery? gallery,
  }) = _Business;

  factory Business.fromJson(Map<String, dynamic> json) => _$BusinessFromJson(json);
}
