import 'package:freezed_annotation/freezed_annotation.dart';
import '../../shared/localized_field.model.dart';

part 'business.section.freezed.dart';
part 'business.section.g.dart';

@freezed
class BusinessSection with _$BusinessSection {
  factory BusinessSection({
    String? id,
    List<LocalizedField>? name,
    String? categoryId,
    List<String>? productIds,
    List<String>? images,
    List<LocalizedField>? description,
  }) = _BusinessSection;

  factory BusinessSection.fromJson(Map<String, dynamic> json) => _$BusinessSectionFromJson(json);
}
