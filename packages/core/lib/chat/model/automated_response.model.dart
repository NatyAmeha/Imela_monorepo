import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/chat/model/chat_enums.dart';
import 'package:imela_core/shared/graphql_input_utils.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_data/network/graphql/__generated__/schema.schema.gql.dart';

part 'automated_response.model.freezed.dart';
part 'automated_response.model.g.dart';

@freezed
class AutomatedResponse with _$AutomatedResponse {
  const AutomatedResponse._();
  const factory AutomatedResponse({
    String? id,
    required String trigger,
    required String triggerType,
    List<LocalizedField>? response,
    @Default(true) bool isActive,
  }) = _AutomatedResponse;

  factory AutomatedResponse.fromJson(Map<String, dynamic> json) => _$AutomatedResponseFromJson(json);
  
  TriggerType get getTriggerType => 
    TriggerType.values.firstWhere(
      (e) => e.toString().split('.').last == triggerType,
      orElse: () => TriggerType.KEYWORD
    );
    
  // Added method to convert to GraphQL input
  GAutomatedResponseInput toGraphQLInput() {
    return GAutomatedResponseInput((b) => b
      ..trigger = trigger
      ..triggerType = triggerType
      ..response.addAll(response?.toLocalizedFieldInput() ?? [])
      ..isActive = isActive);
  }
} 