import 'package:imela_core/chat/dto/create_chat_room_input.dart';
import 'package:imela_core/chat/dto/send_message_input.dart';
import 'package:imela_core/chat/dto/update_chat_room_input.dart';
import 'package:imela_core/chat/model/chat_enums.dart';
import 'package:imela_core/chat/model/chat_message.model.dart';
import 'package:imela_core/chat/model/chat_message_response.dart';
import 'package:imela_core/chat/model/chat_participant_response.dart';
import 'package:imela_core/chat/model/chat_room.model.dart';
import 'package:imela_core/chat/model/chat_room_response.dart';
import 'package:imela_core/chat/repo/chat_repository.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:injectable/injectable.dart';

@injectable
class ChatUsecase {
  final IChatRepository _chatRepository;

  const ChatUsecase(
    @Named(ChatRepository.injectName) this._chatRepository,
  );

  // Chat Room operations
  Future<ChatRoomResponse?> createChatRoom({
    required String businessId,
    required List<LocalizedField> name,
    required List<LocalizedField> description,
    String? welcomeMessage,
  }) async {
    final input = CreateChatRoomInput(
      businessId: businessId,
      name: name,
      description: description,
      welcomeMessage: welcomeMessage,
    );
    return await _chatRepository.createChatRoom(input);
  }

  Future<ChatRoomResponse?> getChatRoom(String roomId) async {
    return await _chatRepository.getChatRoom(roomId);
  }

  Future<ChatRoomResponse?> updateChatRoom(String businessId, UpdateChatRoomInput input) async {
    return await _chatRepository.updateChatRoom(businessId, input);
  }

  Future<ChatRoomResponse?> getBusinessChatRooms(String businessId, {int page = 1, int limit = 20}) async {
    return await _chatRepository.getBusinessChatRooms(businessId, page: page, limit: limit);
  }

  Future<ChatRoomResponse?> getUserChatRooms(String userId, {int page = 1, int limit = 20}) async {
    return await _chatRepository.getUserChatRooms(userId, page: page, limit: limit);
  }

  Future<ChatRoomResponse?> getBranchChatRooms(String businessId, String branchId, {int page = 1, int limit = 20, ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    var response = await _chatRepository.getBranchChatRooms(businessId, branchId, page: page, limit: limit, fetchPolicy: fetchPolicy);
    if (response!.chatRooms?.isEmpty == true && fetchPolicy == ApiDataFetchPolicy.cacheFirst) {
      response = await _chatRepository.getBranchChatRooms(businessId, branchId, page: page, limit: limit, fetchPolicy: ApiDataFetchPolicy.networkOnly);
    }
    return response;
  }

  // Message operations
  Future<ChatMessageResponse?> sendTextMessage({
    required String roomId,
    required String senderId,
    required String senderType,
    required String message,
    String? replyToId,
    String? branchId,
  }) async {
    final input = SendMessageInput(
      roomId: roomId,
      senderId: senderId,
      senderType: senderType,
      content: message,
      contentType: ContentType.TEXT.name,
      replyToId: replyToId,
      branchId: branchId,
    );
    return await _chatRepository.sendMessage(input);
  }

  Future<ChatMessageResponse?> getMessagesForRoom(String roomId, {int limit = 20, String? cursor}) async {
    return await _chatRepository.getMessagesForRoom(roomId, limit: limit, cursor: cursor);
  }

  Future<ChatMessageResponse?> markMessageAsRead(String messageId, String userId) async {
    return await _chatRepository.markMessageAsRead(messageId, userId);
  }

  Future<ChatMessageResponse?> markMessageAsDelivered(String messageId, String userId) async {
    return await _chatRepository.markMessageAsDelivered(messageId, userId);
  }

  Future<ChatMessageResponse?> searchMessages(String roomId, String query, {int limit = 20}) async {
    return await _chatRepository.searchMessages(roomId, query, limit: limit);
  }

  // Participant operations
  Future<ChatParticipantResponse?> addParticipant(String roomId, String userId, {String type = 'CUSTOMER'}) async {
    return await _chatRepository.addParticipant(roomId, userId, type: type);
  }

  Future<ChatParticipantResponse?> updateParticipant(String businessId, String participantId, {bool isActive = true}) async {
    return await _chatRepository.updateParticipant(businessId, participantId, isActive: isActive);
  }

  Future<ChatParticipantResponse?> removeParticipant(String businessId, String participantId) async {
    return await _chatRepository.removeParticipant(businessId, participantId);
  }

  Future<ChatParticipantResponse?> getParticipantsForRoom(String roomId) async {
    return await _chatRepository.getParticipantsForRoom(roomId);
  }
}
