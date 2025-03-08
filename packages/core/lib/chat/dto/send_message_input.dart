import 'package:imela_core/chat/model/activity_data.model.dart';
import 'package:imela_core/chat/model/chat_enums.dart';
import 'package:imela_core/chat/model/message_attachment.model.dart';
import 'package:imela_core/shared/graphql_input_utils.dart';

class SendMessageInput {
  final String roomId;
  final String senderId;
  final String senderType;
  final String content;
  final String contentType;
  final ActivityData? activityData;
  final List<MessageAttachment>? attachments;
  final String? replyToId;
  final String? branchId;

  SendMessageInput({
    required this.roomId,
    required this.senderId,
    required this.senderType,
    required this.content,
    this.contentType = 'TEXT',
    this.activityData,
    this.attachments,
    this.replyToId,
    this.branchId,
  });

  
} 