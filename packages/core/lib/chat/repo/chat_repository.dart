import 'package:imela_core/chat/dto/create_chat_room_input.dart';
import 'package:imela_core/chat/dto/send_message_input.dart';
import 'package:imela_core/chat/dto/update_chat_room_input.dart';
import 'package:imela_core/chat/model/chat_message_response.dart';
import 'package:imela_core/chat/model/chat_participant_response.dart';
import 'package:imela_core/chat/model/chat_room_response.dart';
import 'package:imela_core/shared/graphql_input_utils.dart';
import 'package:imela_core/shared/repository.intereface.dart';
import 'package:imela_data/network/graphql/chat/__generated__/create_chat_room.req.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/create_chat_room.data.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/get_branch_chat_rooms.data.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/get_branch_chat_rooms.req.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/get_chat_room.req.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/get_chat_room.data.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/get_business_chat_rooms.req.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/get_business_chat_rooms.data.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/get_messages_for_room.req.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/get_messages_for_room.data.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/send_message.req.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/send_message.data.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/update_chat_room.req.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/update_chat_room.data.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/get_user_chat_rooms.req.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/get_user_chat_rooms.data.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/get_branch_messages.req.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/get_branch_messages.data.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/add_participant.req.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/add_participant.data.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/update_participant.req.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/update_participant.data.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/remove_participant.req.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/remove_participant.data.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/get_participants_for_room.req.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/get_participants_for_room.data.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/get_active_participants_for_room.req.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/get_active_participants_for_room.data.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/get_active_participants_for_room.req.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/get_active_participants_for_room.data.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/search_messages.req.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/search_messages.data.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/mark_message_as_read.req.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/mark_message_as_read.data.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/mark_message_as_delivered.req.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/mark_message_as_delivered.data.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/delete_chat_room.req.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/delete_chat_room.data.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/get_branch_messages.req.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/get_branch_messages.data.gql.dart';
import 'package:imela_data/network/graphql/chat/__generated__/get_branch_messages.req.gql.dart';





import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:injectable/injectable.dart';

abstract class IChatRepository extends IRepository {
  // Chat Room operations
  Future<ChatRoomResponse?> createChatRoom(CreateChatRoomInput input);
  Future<ChatRoomResponse?> updateChatRoom(String businessId, UpdateChatRoomInput input);
  Future<ChatRoomResponse?> deleteChatRoom(String businessId, String roomId);
  Future<ChatRoomResponse?> getChatRoom(String roomId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst});
  Future<ChatRoomResponse?> getBusinessChatRooms(String businessId, {int? page, int? limit, ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst});
  Future<ChatRoomResponse?> getUserChatRooms(String userId, {int? page, int? limit, ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst});
  Future<ChatRoomResponse?> getBranchChatRooms(String businessId, String branchId, {int? page, int? limit, ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst});
  
  // Messages operations
  Future<ChatMessageResponse?> sendMessage(SendMessageInput input);
  Future<ChatMessageResponse?> markMessageAsRead(String messageId, String userId);
  Future<ChatMessageResponse?> markMessageAsDelivered(String messageId, String userId);
  Future<ChatMessageResponse?> getMessagesForRoom(String roomId, {int? limit, String? cursor, ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst});
  Future<ChatMessageResponse?> searchMessages(String roomId, String query, {int? limit, String? cursor});
  Future<ChatMessageResponse?> getBranchMessages(String businessId, String branchId, {int? limit, String? cursor, ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst});
  
  // Participant operations
  Future<ChatParticipantResponse?> addParticipant(String roomId, String userId, {String type = 'CUSTOMER', bool isActive = true});
  Future<ChatParticipantResponse?> updateParticipant(String businessId, String participantId, {bool? isActive});
  Future<ChatParticipantResponse?> removeParticipant(String businessId, String participantId);
  Future<ChatParticipantResponse?> getParticipantsForRoom(String roomId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst});
  Future<ChatParticipantResponse?> getActiveParticipantsForRoom(String roomId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst});
}

@Named(ChatRepository.injectName)
@Injectable(as: IChatRepository)
class ChatRepository implements IChatRepository {
  static const injectName = 'CHAT_REPOSITORY_INJECTION';
  final IGraphQLDataSource _graphQLDataSource;

  const ChatRepository(
    @Named('GRAPHQL_DATASOURCE_INJECTION') this._graphQLDataSource,
  );

  @override
  Future<ChatRoomResponse?> createChatRoom(CreateChatRoomInput input) async {
    final request = GCreateChatRoomReq((b) => b
      ..vars.data.update((b) => b
        ..name.addAll(input.name.toLocalizedFieldInput())
        ..description.addAll(input.description.toLocalizedFieldInput())
        ..type = input.type
        ..businessId =  input.businessId
        ..isActive = input.isActive
        ..welcomeMessage = input.welcomeMessage
        ..automatedResponses.addAll(input.automatedResponses?.map((r) => r.toGraphQLInput()) ?? []))
      ..fetchPolicy = _graphQLDataSource.getFetchPolicy(ApiDataFetchPolicy.networkOnly));
    
    final result = await _graphQLDataSource.request<GCreateChatRoomData?>(
      request, 
      type: 'CREATE_CHAT_ROOM', 
      isMainError: true
    );
    
    if (result?.createChatRoom == null) {
      return null;
    }
    
    return ChatRoomResponse.fromJson(result!.createChatRoom.toJson());
  }
  
  @override
  Future<ChatRoomResponse?> getChatRoom(String roomId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    final request = GGetChatRoomReq((b) => b
      ..vars.id = roomId
      ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy));
    
    final result = await _graphQLDataSource.request<GGetChatRoomData?>(
      request, 
      type: 'GET_CHAT_ROOM', 
      isMainError: true
    );
    
    if (result?.getChatRoom == null) {
      return null;
    }
    
    return ChatRoomResponse.fromJson(result!.getChatRoom.toJson());
  }
  
  @override
  Future<ChatRoomResponse?> getBusinessChatRooms(String businessId, {int? page, int? limit, ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    final request = GGetBusinessChatRoomsReq((b) => b
      ..vars.businessId = businessId
      ..vars.page = page
      ..vars.limit = limit
      ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy));
    
    final result = await _graphQLDataSource.request<GGetBusinessChatRoomsData?>(
      request, 
      type: 'GET_BUSINESS_CHAT_ROOMS', 
      isMainError: true
    );
    
    if (result?.getBusinessChatRooms == null) {
      return null;
    }
    
    return ChatRoomResponse.fromJson(result!.getBusinessChatRooms.toJson());
  }
  
  @override
  Future<ChatMessageResponse?> getMessagesForRoom(String roomId, {int? limit, String? cursor, ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    final request = GGetMessagesForRoomReq((b) => b
      ..vars.roomId = roomId
      ..vars.limit = limit
      ..vars.cursor = cursor
      ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy));
    
    final result = await _graphQLDataSource.request<GGetMessagesForRoomData?>(
      request, 
      type: 'GET_MESSAGES_FOR_ROOM', 
      isMainError: true
    );
    
    if (result?.getMessagesForRoom == null) {
      return null;
    }
    
    return ChatMessageResponse.fromJson(result!.getMessagesForRoom.toJson());
  }
  
  @override
  Future<ChatMessageResponse?> sendMessage(SendMessageInput input) async {
    print('sendMessage: ${input.activityData?.toJson()}');
    final request = GSendMessageReq((b) => b
      ..vars.data.update(
        (b) => b
      ..roomId = input.roomId
      ..senderId = input.senderId
      ..senderType = input.senderType
      ..content = input.content
      ..contentType = input.contentType
      // ..activityData.update(input.activityData != null ? (b) => input.activityData?.toGraphQLInput() : null)
      ..attachments.addAll(input.attachments?.map((a) => a.toGraphQLInput()) ?? [])
      ..replyToId = input.replyToId
      ..branchId = input.branchId
      )
      ..fetchPolicy = _graphQLDataSource.getFetchPolicy(ApiDataFetchPolicy.networkOnly));
    
    final result = await _graphQLDataSource.request<GSendMessageData?>(
      request, 
      type: 'SEND_MESSAGE', 
      isMainError: true
    );
    
    if (result?.sendMessage == null) {
      return null;
    }
    
    return ChatMessageResponse.fromJson(result!.sendMessage.toJson());
  }
  
  @override
  Future<ChatRoomResponse?> updateChatRoom(String businessId, UpdateChatRoomInput input) async {
    final request = GUpdateChatRoomReq((b) => b
      ..vars.businessId = businessId
      ..vars.data.update(
        (b) => b
        ..id = input.id
        ..name.addAll(input.name?.toLocalizedFieldInput() ?? [])
        ..description.addAll(input.description?.toLocalizedFieldInput() ?? [])
        ..isActive = input.isActive
        ..welcomeMessage = input.welcomeMessage
        ..automatedResponses.addAll(input.automatedResponses?.map((r) => r.toGraphQLInput()) ?? [])
      )
      ..fetchPolicy = _graphQLDataSource.getFetchPolicy(ApiDataFetchPolicy.networkOnly));
    
    final result = await _graphQLDataSource.request<GUpdateChatRoomData?>(
      request, 
      type: 'UPDATE_CHAT_ROOM', 
      isMainError: true
    );
    
    if (result?.updateChatRoom == null) {
      return null;
    }
    
    return ChatRoomResponse.fromJson(result!.updateChatRoom.toJson());
  }
  
  @override
  Future<ChatRoomResponse?> deleteChatRoom(String businessId, String roomId) async {
    final request = GDeleteChatRoomReq((b) => b
      ..vars.businessId = businessId
      ..vars.id = roomId
      ..fetchPolicy = _graphQLDataSource.getFetchPolicy(ApiDataFetchPolicy.networkOnly));
    
    final result = await _graphQLDataSource.request<GDeleteChatRoomData?>(
      request, 
      type: 'DELETE_CHAT_ROOM', 
      isMainError: true
    );
    
    if (result?.deleteChatRoom == null) {
      return null;
    }
    
    return ChatRoomResponse.fromJson(result!.deleteChatRoom.toJson());
  }
  
  @override
  Future<ChatRoomResponse?> getUserChatRooms(String userId, {int? page, int? limit, ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    final request = GGetUserChatRoomsReq((b) => b
      ..vars.userId = userId
      ..vars.page = page
      ..vars.limit = limit
      ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy));
    
    final result = await _graphQLDataSource.request<GGetUserChatRoomsData?>(
      request, 
      type: 'GET_USER_CHAT_ROOMS', 
      isMainError: true
    );
    
    if (result?.getUserChatRooms == null) {
      return null;
    }
    
    return ChatRoomResponse.fromJson(result!.getUserChatRooms.toJson());
  }
  
  @override
  Future<ChatRoomResponse?> getBranchChatRooms(String businessId, String branchId, {int? page, int? limit, ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    final request = GGetBranchChatRoomsReq((b) => b
      ..vars.businessId = businessId
      ..vars.branchId = branchId
      ..vars.page = page
      ..vars.limit = limit
      ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy));
    
    final result = await _graphQLDataSource.request<GGetBranchChatRoomsData?>(
      request, 
      type: 'GET_BRANCH_CHAT_ROOMS', 
      isMainError: true
    );
    
    if (result?.getBranchChatRooms == null) {
      return null;
    }
    
    return ChatRoomResponse.fromJson(result!.getBranchChatRooms.toJson());
  }
  
  @override
  Future<ChatMessageResponse?> markMessageAsRead(String messageId, String userId) async {
    final request = GMarkMessageAsReadReq((b) => b
      ..vars.data.update((b) => b
        ..messageId = messageId
        ..userId = userId)
      ..fetchPolicy = _graphQLDataSource.getFetchPolicy(ApiDataFetchPolicy.networkOnly));
    
    final result = await _graphQLDataSource.request<GMarkMessageAsReadData?>(
      request,
      type: 'MARK_MESSAGE_AS_READ',
      isMainError: true
    );
    
    if (result?.markMessageAsRead == null) {
      return null;
    }
    
    return ChatMessageResponse.fromJson(result!.markMessageAsRead.toJson());
  }
  
  @override
  Future<ChatMessageResponse?> markMessageAsDelivered(String messageId, String userId) async {
    final request = GMarkMessageAsDeliveredReq((b) => b
      ..vars.data.update((b) => b
        ..messageId = messageId
        ..userId = userId)
      ..fetchPolicy = _graphQLDataSource.getFetchPolicy(ApiDataFetchPolicy.networkOnly));
    
    final result = await _graphQLDataSource.request<GMarkMessageAsDeliveredData?>(
      request,
      type: 'MARK_MESSAGE_AS_DELIVERED',
      isMainError: true
    );
    
    if (result?.markMessageAsDelivered == null) {
      return null;
    }
    
    return ChatMessageResponse.fromJson(result!.markMessageAsDelivered.toJson());
  }
  
  @override
  Future<ChatMessageResponse?> searchMessages(String roomId, String query, {int? limit, String? cursor}) async {
    final request = GSearchMessagesReq((b) => b
      ..vars.roomId = roomId
      ..vars.query = query
      ..vars.limit = limit
      ..vars.cursor = cursor
      ..fetchPolicy = _graphQLDataSource.getFetchPolicy(ApiDataFetchPolicy.networkOnly));
    
    final result = await _graphQLDataSource.request<GSearchMessagesData?>(
      request, 
      type: 'SEARCH_MESSAGES', 
      isMainError: true
    );
    
    if (result?.searchMessages == null) {
      return null;
    }
    
    return ChatMessageResponse.fromJson(result!.searchMessages.toJson());
  }
  
  @override
  Future<ChatMessageResponse?> getBranchMessages(String businessId, String branchId, {int? limit, String? cursor, ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    final request = GGetBranchMessagesReq((b) => b
      ..vars.businessId = businessId
      ..vars.branchId = branchId
      ..vars.limit = limit
      ..vars.cursor = cursor
      ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy));
    
    final result = await _graphQLDataSource.request<GGetBranchMessagesData?>(
      request, 
      type: 'GET_BRANCH_MESSAGES', 
      isMainError: true
    );
    
    if (result?.getBranchMessages == null) {
      return null;
    }
    
    return ChatMessageResponse.fromJson(result!.getBranchMessages.toJson());
  }
  
  @override
  Future<ChatParticipantResponse?> addParticipant(String roomId, String userId, {String type = 'CUSTOMER', bool isActive = true}) async {
    final request = GAddParticipantReq((b) => b
      ..vars.data.update((b) => b
        ..roomId = roomId
        ..userId = userId
        ..type = type
        ..isActive = isActive)
      ..fetchPolicy = _graphQLDataSource.getFetchPolicy(ApiDataFetchPolicy.networkOnly));
    
    final result = await _graphQLDataSource.request<GAddParticipantData?>(
      request, 
      type: 'ADD_PARTICIPANT', 
      isMainError: true
    );
    
    if (result?.addParticipant == null) {
      return null;
    }
    
    return ChatParticipantResponse.fromJson(result!.addParticipant.toJson());
  }
  
  @override
  Future<ChatParticipantResponse?> updateParticipant(String businessId, String participantId, {bool? isActive}) async {
    final request = GUpdateParticipantReq((b) => b
      ..vars.businessId = businessId
      ..vars.data.update((b) => b
        ..id = participantId
        ..isActive = isActive)
      ..fetchPolicy = _graphQLDataSource.getFetchPolicy(ApiDataFetchPolicy.networkOnly));
    
    final result = await _graphQLDataSource.request<GUpdateParticipantData?>(
      request, 
      type: 'UPDATE_PARTICIPANT', 
      isMainError: true
    );
    
    if (result?.updateParticipant == null) {
      return null;
    }
    
    return ChatParticipantResponse.fromJson(result!.updateParticipant.toJson());
  }
  
  @override
  Future<ChatParticipantResponse?> removeParticipant(String businessId, String participantId) async {
    final request = GRemoveParticipantReq((b) => b
      ..vars.businessId = businessId
      ..vars.id = participantId
      ..fetchPolicy = _graphQLDataSource.getFetchPolicy(ApiDataFetchPolicy.networkOnly));
    
    final result = await _graphQLDataSource.request<GRemoveParticipantData?>(
      request, 
      type: 'REMOVE_PARTICIPANT', 
      isMainError: true
    );
    
    if (result?.removeParticipant == null) {
      return null;
    }
    
    return ChatParticipantResponse.fromJson(result!.removeParticipant.toJson());
  }
  
  @override
  Future<ChatParticipantResponse?> getParticipantsForRoom(String roomId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    final request = GGetParticipantsForRoomReq((b) => b
      ..vars.roomId = roomId
      ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy));
    
    final result = await _graphQLDataSource.request<GGetParticipantsForRoomData?>(
      request, 
      type: 'GET_PARTICIPANTS_FOR_ROOM', 
      isMainError: true
    );
    
    if (result?.getParticipantsForRoom == null) {
      return null;
    }
    
    return ChatParticipantResponse.fromJson(result!.getParticipantsForRoom.toJson());
  }
  
  @override
  Future<ChatParticipantResponse?> getActiveParticipantsForRoom(String roomId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    final request = GGetActiveParticipantsForRoomReq((b) => b
      ..vars.roomId = roomId
      ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy));
    
    final result = await _graphQLDataSource.request<GGetActiveParticipantsForRoomData?>(
      request, 
      type: 'GET_ACTIVE_PARTICIPANTS_FOR_ROOM', 
      isMainError: true
    );
    
    if (result?.getActiveParticipantsForRoom == null) {
      return null;
    }
    
    return ChatParticipantResponse.fromJson(result!.getActiveParticipantsForRoom.toJson());
  }
} 