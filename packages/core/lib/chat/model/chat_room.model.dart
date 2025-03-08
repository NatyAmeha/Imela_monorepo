import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/chat/model/automated_response.model.dart';
import 'package:imela_core/chat/model/chat_enums.dart';
import 'package:imela_core/chat/model/chat_message.model.dart';
import 'package:imela_core/chat/model/chat_participant.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_utils/helpers/localization_utils.dart';

part 'chat_room.model.freezed.dart';
part 'chat_room.model.g.dart';

@freezed
class ChatRoom with _$ChatRoom {
  const ChatRoom._();
  const factory ChatRoom({
    String? id,
    required List<LocalizedField> name,
    List<LocalizedField>? description,
    required String type,
    required String businessId,
    @Default(true) bool isActive,
    List<ChatParticipant>? participants,
    List<ChatMessage>? messages,
    String? status,
    DateTime? lastMessageAt,
    String? image,
    String? lastMessage,
    String? welcomeMessage,
    List<AutomatedResponse>? automatedResponses,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ChatRoom;

  factory ChatRoom.fromJson(Map<String, dynamic> json) => _$ChatRoomFromJson(json);
  
  ChatRoomType get getRoomType => 
    ChatRoomType.values.firstWhere(
      (e) => e.toString().split('.').last == type,
      orElse: () => ChatRoomType.DIRECT
    );
    
  String getLocalizedName(String locale) {
    return name.localize(locale) ?? 'Chat';
  }
  
  String getLocalizedDescription(String locale) {
    return description?.localize(locale) ?? '';
  }
  
  List<ChatParticipant> getActiveParticipants() {
    return participants?.where((p) => p.isActive).toList() ?? [];
  }
  
  bool hasParticipant(String userId) {
    return participants?.any((p) => p.userId == userId && p.isActive) ?? false;
  }
  
  bool isDirectChat() => type == ChatRoomType.DIRECT.toString();
  
  bool isGroupChat() => type == ChatRoomType.GROUP.toString();
} 