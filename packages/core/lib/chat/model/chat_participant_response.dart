import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/chat/model/chat_participant.model.dart';

part 'chat_participant_response.freezed.dart';
part 'chat_participant_response.g.dart';

@freezed
class ChatParticipantResponse with _$ChatParticipantResponse {
  const ChatParticipantResponse._();
  const factory ChatParticipantResponse({
    required bool success,
    String? message,
    int? code,
    ChatParticipant? participant,
    List<ChatParticipant>? participants,
    double? totalParticipants,
  }) = _ChatParticipantResponse;

  factory ChatParticipantResponse.fromJson(Map<String, dynamic> json) => _$ChatParticipantResponseFromJson(json);
  
  bool isParticipantsFetchSuccessful() => success && participants != null;
  
  bool isParticipantOperationSuccessful() => success && participant != null;
} 