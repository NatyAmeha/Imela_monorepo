import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/chat/model/chat_message.model.dart';

part 'chat_message_response.freezed.dart';
part 'chat_message_response.g.dart';

@freezed
class ChatMessageResponse with _$ChatMessageResponse {
  const ChatMessageResponse._();
  const factory ChatMessageResponse({
    required bool success,
    String? message,
    int? code,
    ChatMessage? chatMessage,
    List<ChatMessage>? chatMessages,
    double? totalMessages,
    String? cursor,
  }) = _ChatMessageResponse;

  factory ChatMessageResponse.fromJson(Map<String, dynamic> json) => _$ChatMessageResponseFromJson(json);
  
  bool isMessagesFetchSuccessful() => success;
  
  bool isMessageSendSuccessful() => success && chatMessage != null;
} 