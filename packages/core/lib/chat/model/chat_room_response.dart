import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/chat/model/chat_room.model.dart';

part 'chat_room_response.freezed.dart';
part 'chat_room_response.g.dart';

@freezed
class ChatRoomResponse with _$ChatRoomResponse {
  const ChatRoomResponse._();
  const factory ChatRoomResponse({
    required bool success,
    String? message,
    int? code,
    ChatRoom? chatRoom,
    List<ChatRoom>? chatRooms,
    double? totalRooms,
  }) = _ChatRoomResponse;

  factory ChatRoomResponse.fromJson(Map<String, dynamic> json) => _$ChatRoomResponseFromJson(json);
  
  bool isRoomsFetchSuccessful() => success && chatRooms != null;
  
  bool isSingleRoomFetchSuccessful() => success ;
} 