import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_data/network/graphql/__generated__/schema.schema.gql.dart';

part 'message_attachment.model.freezed.dart';
part 'message_attachment.model.g.dart';

@freezed
class MessageAttachment with _$MessageAttachment {
  const MessageAttachment._();
  const factory MessageAttachment({
    String? id,
    required String url,
    required String fileName,
    required String fileType,
    required double fileSize,
    String? thumbnailUrl,
  }) = _MessageAttachment;

  factory MessageAttachment.fromJson(Map<String, dynamic> json) => _$MessageAttachmentFromJson(json);
  
  // Fix: Return GMessageAttachmentInput directly instead of a Function
  GMessageAttachmentInput toGraphQLInput() {
    return GMessageAttachmentInput((b) => b
      ..url = url
      ..fileName = fileName
      ..fileType = fileType
      ..fileSize = fileSize
      ..thumbnailUrl = thumbnailUrl);
  }
} 