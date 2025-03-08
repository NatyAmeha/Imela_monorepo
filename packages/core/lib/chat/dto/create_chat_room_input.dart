import 'package:imela_core/chat/model/automated_response.model.dart';
import 'package:imela_core/shared/graphql_input_utils.dart';
import 'package:imela_core/shared/localized_field.model.dart';

class CreateChatRoomInput {
  final List<LocalizedField> name;
  final List<LocalizedField> description;
  final String type;
  final String businessId;
  final bool isActive;
  final String? welcomeMessage;
  final List<AutomatedResponse>? automatedResponses;

  CreateChatRoomInput({
    required this.name,
    required this.description,
    this.type = 'DIRECT',
    required this.businessId,
    this.isActive = true,
    this.welcomeMessage,
    this.automatedResponses,
  });

  Function toGraphQLInput( ) {
    return (b) => b
      ..name.addAll(name.toLocalizedFieldInput())
      ..description.addAll(description.toLocalizedFieldInput())
      ..type = type.toString().split('.').last
      ..businessId = businessId
      ..isActive = isActive
      ..welcomeMessage = welcomeMessage
      ..automatedResponses.addAll(automatedResponses?.map((r) => r.toGraphQLInput()) ?? []);
  }
} 