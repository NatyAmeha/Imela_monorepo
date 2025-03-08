import 'package:imela_core/chat/model/automated_response.model.dart';
import 'package:imela_core/shared/graphql_input_utils.dart';
import 'package:imela_core/shared/localized_field.model.dart';

class UpdateChatRoomInput {
  final String id;
  final List<LocalizedField>? name;
  final List<LocalizedField>? description;
  final bool? isActive;
  final String? welcomeMessage;
  final List<AutomatedResponse>? automatedResponses;

  UpdateChatRoomInput({
    required this.id,
    this.name,
    this.description,
    this.isActive,
    this.welcomeMessage,
    this.automatedResponses,
  });

  
} 