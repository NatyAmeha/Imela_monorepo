import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/shared/graphql_input_utils.dart';
import 'package:imela_core/shared/localized_field.model.dart';

part 'activity_data.model.freezed.dart';
part 'activity_data.model.g.dart';

@freezed
class ActivityData with _$ActivityData {
  const ActivityData._();
  const factory ActivityData({
    required String type,
    List<LocalizedField>? title,
    List<LocalizedField>? description,
    String? imageUrl,
    String? actionUrl,
    String? metadata,
  }) = _ActivityData;

  factory ActivityData.fromJson(Map<String, dynamic> json) => _$ActivityDataFromJson(json);
  
  // Added method to convert to GraphQL input
  Function toGraphQLInput() {
    return (b) => b
      ..type = type
      ..title.addAll(title?.toLocalizedFieldInput() ?? [])
      ..description.addAll(description?.toLocalizedFieldInput() ?? [])
      ..imageUrl = imageUrl
      ..actionUrl = actionUrl
      ..metadata = metadata;
  }
} 