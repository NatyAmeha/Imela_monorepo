import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/chat/model/chat_enums.dart';

part 'chat_participant.model.freezed.dart';
part 'chat_participant.model.g.dart';

@freezed
class ChatParticipant with _$ChatParticipant {
  const ChatParticipant._();
  const factory ChatParticipant({
    String? id,
    required String roomId,
    required String userId,
    String? username,
    String? profileImage,
    required String type,
    @Default(true) bool isActive,
    DateTime? lastReadAt,
    DateTime? lastDeliveredAt,
    DateTime? joinedAt,
    DateTime? leftAt,
  }) = _ChatParticipant;

  factory ChatParticipant.fromJson(Map<String, dynamic> json) => _$ChatParticipantFromJson(json);
  
  ParticipantType get getParticipantType => 
    ParticipantType.values.firstWhere(
      (e) => e.toString().split('.').last == type,
      orElse: () => ParticipantType.CUSTOMER
    );
} 