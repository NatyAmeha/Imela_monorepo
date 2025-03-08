import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/chat/model/activity_data.model.dart';
import 'package:imela_core/chat/model/chat_enums.dart';
import 'package:imela_core/chat/model/message_attachment.model.dart';
import 'package:imela_core/chat/model/receipts.model.dart';

part 'chat_message.model.freezed.dart';
part 'chat_message.model.g.dart';

@freezed
class ChatMessage with _$ChatMessage {
  const ChatMessage._();
  const factory ChatMessage({
    String? id,
    required String roomId,
    required String senderId,
    required String senderType,
    required String content,
    required String contentType,
    ActivityData? activityData,
    List<MessageAttachment>? attachments,
    List<ReadReceipt>? readBy,
    List<DeliveryReceipt>? deliveredTo,
    String? replyToId,
    String? branchId,
    required DateTime sentAt,
    DateTime? updatedAt,
    bool? failed,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);
  
  SenderType get getSenderType => 
    SenderType.values.firstWhere(
      (e) => e.toString().split('.').last == senderType,
      orElse: () => SenderType.CUSTOMER
    );
  
  ContentType get getContentType => 
    ContentType.values.firstWhere(
      (e) => e.toString().split('.').last == contentType,
      orElse: () => ContentType.TEXT
    );
    
  bool get isRead => readBy?.isNotEmpty == true;
  
  bool get isDelivered => deliveredTo?.isNotEmpty == true;
  
  bool get isActivityMessage => contentType == ContentType.ACTIVITY.toString();
  
  bool isSentByUser(String userId) => senderId == userId;
} 