import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatview/chatview.dart';
import 'package:imela_core/chat/chat.usecase.dart';
import 'package:imela_core/chat/model/chat_message.model.dart';
import 'package:imela_core/chat/model/chat_room.model.dart';
import 'package:imela_core/chat/model/chat_participant.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/injection.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

enum ChatRoomFilter { ALL, ACTIVE, CLOSED }

@injectable
class ChatViewModel extends GetxController with BaseViewmodel {
  final ChatUsecase _chatUsecase;
  final IExceptiionHandler exceptionHandler;

  ChatViewModel(this._chatUsecase, {
    @Named(AppExceptionHandler.injectName) required this.exceptionHandler,
  });

  // Observable properties
  final isLoading = false.obs;
  final isLoadingMessages = false.obs;
  final exception = Rxn<AppException>();
  final errorMessage = ''.obs;
  final currentRoomId = ''.obs;
  final selectedFilter = ChatRoomFilter.ALL.obs;
  final currentRoom = Rxn<ChatRoom>();
  final chatMessages = <ChatMessage>[].obs;
  final participants = <ChatParticipant>[].obs;
  final chatRooms = <ChatRoom>[].obs;
  final filteredChatRooms = <ChatRoom>[].obs;

  // Pagination variables
  final currentCursor = Rxn<String>();
  final hasMoreMessages = false.obs;

  // Message cache to maintain messages across navigation
  final Map<String, List<ChatMessage>> _messageCache = {};

  // Single ChatController for the entire lifecycle
  late final ChatController _chatController;
  ChatController get chatController => _chatController;

  // UI state variables
  final isSidePanelOpen = true.obs;
  final showSmallScreenDetail = false.obs;

  AppViewmodel get appViewmodel => AppViewmodel.getInstance();

  String? get selectedBusinessId => appViewmodel.selectedBusiness.value?.id;
  String? get selectedBranchId => appViewmodel.selectedBranch.value?.id;
  String get staffId => appViewmodel.loggedInStaffInfo.value?.staff?.id ?? '';
  String get staffName => appViewmodel.loggedInStaffInfo.value?.staff?.name ?? 'Staff';
  String get staffType => 'AGENT';

  static ChatViewModel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<ChatViewModel>());
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize a single global controller
    _chatController = ChatController(
      initialMessageList: [],
      scrollController: ScrollController(),
      currentUser: ChatUser(id: staffId, name: staffName, profilePhoto: null),
      otherUsers: [],
    );

    // Listen for socket events
    _setupSocketListeners();
  }

  void initViewModel({Map<String, dynamic>? data}) {
    if (data != null) {
      if (data.containsKey('roomId')) {
        currentRoomId.value = data['roomId'] as String;
      }
    }

    // Load chat rooms for the current branch
    if (selectedBranchId != null && selectedBusinessId != null) {
      loadChatRooms();
    }

    // If room ID is provided, load that room
    if (currentRoomId.value.isNotEmpty) {
      loadRoom(currentRoomId.value);
      loadMessagesForRoom(currentRoomId.value);
    }
  }

  // Setup socket listeners for real-time updates
  void _setupSocketListeners() {
    final socket = appViewmodel.chatSocketService;

    // Listen for new messages
    socket.onMessageReceived.listen((message) {
      if (message.roomId == currentRoomId.value) {
        // Add to current room messages
        final updatedMessages = List<ChatMessage>.from(chatMessages);
        updatedMessages.add(message);
        chatMessages.value = updatedMessages;

        // Update cache
        _messageCache[message.roomId] = updatedMessages;

        // Update chat controller
        _chatController.addMessage(_convertToChatViewMessage(message));
      }

      // Update last message for room in rooms list
      final index = chatRooms.indexWhere((room) => room.id == message.roomId);
      if (index >= 0) {
        final updatedRoom = chatRooms[index].copyWith(
          lastMessage: message.content,
          lastMessageAt: message.sentAt,
        );
        final updatedRooms = List<ChatRoom>.from(chatRooms);
        updatedRooms[index] = updatedRoom;
        chatRooms.value = updatedRooms;
        _applyRoomFilter();
      }
    });

    // Listen for delivery receipts
    socket.onMessageDelivered.listen((data) {
      // Update message delivery status if needed
    });

    // Listen for read receipts
    socket.onMessageRead.listen((data) {
      // Update message read status if needed
    });

    // Listen for participant changes
    socket.onParticipantJoined.listen((participant) {
      if (participant.roomId == currentRoomId.value) {
        final updatedParticipants = List<ChatParticipant>.from(participants);
        updatedParticipants.add(participant);
        participants.value = updatedParticipants;
      }
    });

    socket.onParticipantLeft.listen((participant) {
      if (participant.roomId == currentRoomId.value) {
        final index = participants.indexWhere((p) => p.id == participant.id);
        if (index >= 0) {
          final updatedParticipants = List<ChatParticipant>.from(participants);
          updatedParticipants[index] = participant;
          participants.value = updatedParticipants;
        }
      }
    });
  }

  // Load chat rooms for the current branch
  Future<void> loadChatRooms() async {
    if (selectedBusinessId == null || selectedBranchId == null) {
      errorMessage.value = 'No business or branch selected';
      return;
    }

    isLoading.value = true;
    exception.value = null;
    errorMessage.value = ''; 

    try {
      final response = await _chatUsecase.getBranchChatRooms(selectedBusinessId!, selectedBranchId!, fetchPolicy: ApiDataFetchPolicy.cacheFirst);

      if (response?.isRoomsFetchSuccessful() == true && response!.chatRooms != null) {
        chatRooms.value = response.chatRooms!;
        _applyRoomFilter();
      } else {
        errorMessage.value = response?.message ?? 'Failed to load chat rooms';
      }
    } catch (e) {
      print('Error loading chat rooms: $e');
      errorMessage.value = 'Error loading chat rooms: ${e.toString()}';
      exception.value = exceptionHandler.getException(e as Exception);
    } finally {
      isLoading.value = false;
    }
  }

  // Apply filter to chat rooms
  void _applyRoomFilter() {
    switch (selectedFilter.value) {
      case ChatRoomFilter.ACTIVE:
        filteredChatRooms.value = chatRooms.where((room) => room.isActive).toList();
        break;
      case ChatRoomFilter.CLOSED:
        filteredChatRooms.value = chatRooms.where((room) => !room.isActive).toList();
        break;
      case ChatRoomFilter.ALL:
      default:
        filteredChatRooms.value = List.from(chatRooms);
        break;
    }
  }

  // Change the filter
  void changeFilter(ChatRoomFilter filter) {
    selectedFilter.value = filter;
    _applyRoomFilter();
  }

  // Load a specific chat room
  Future<void> loadRoom(String roomId) async {
    if (roomId.isEmpty) return;

    isLoading.value = true;
    exception.value = null;
    errorMessage.value = '';

    try {
      final response = await _chatUsecase.getChatRoom(roomId);

      if (response?.isSingleRoomFetchSuccessful() == true && response!.chatRoom != null) {
        currentRoom.value = response.chatRoom;
        currentRoomId.value = roomId;

        // If room has participants, store them
        if (response.chatRoom!.participants != null) {
          participants.value = response.chatRoom!.participants!;
        } else {
          // Else load participants separately
          await loadParticipants(roomId);
        }

        // Join room in socket
        appViewmodel.chatSocketService.joinRoom(roomId);

        // When viewing on small screen, show detail view
        showSmallScreenDetail.value = true;
      } else {
        errorMessage.value = response?.message ?? 'Failed to load chat room';
      }
    } catch (e) {
      print('Error loading chat room: $e');
      errorMessage.value = 'Error loading chat room: ${e.toString()}';
      exception.value = exceptionHandler.getException(e as Exception);
    } finally {
      isLoading.value = false;
    }
  }

  // Load participants for a room
  Future<void> loadParticipants(String roomId) async {
    try {
      final response = await _chatUsecase.getParticipantsForRoom(roomId);

      if (response?.isParticipantsFetchSuccessful() == true && response!.participants != null) {
        participants.value = response.participants!;
      }
    } catch (e) {
      print('Error loading participants: $e');
    }
  }

  // Load messages for a specific room
  Future<void> loadMessagesForRoom(String roomId, {bool loadMore = false, bool forceRefresh = false}) async {
    if (roomId.isEmpty) return;

    isLoadingMessages.value = true;

    try {
      // First check if we have cached messages for this room and if we're not forcing a refresh
      if (!forceRefresh && _messageCache.containsKey(roomId) && !loadMore) {
        // Use the cached messages
        chatMessages.value = _messageCache[roomId]!;

        // Update the controller with cached messages
        _updateControllerMessages();

        // Exit early - we already have the messages
        isLoadingMessages.value = false;
        return;
      }

      String? cursor = loadMore ? currentCursor.value : null;

      final response = await _chatUsecase.getMessagesForRoom(roomId, limit: 50, cursor: cursor);

      if (response?.isMessagesFetchSuccessful() == true) {
        List<ChatMessage> newMessages = response!.chatMessages ?? [];

        if (loadMore && chatMessages.isNotEmpty) {
          // For pagination, append the new messages
          final allMessages = List<ChatMessage>.from(chatMessages);
          allMessages.addAll(newMessages);

          // Sort by date (newest last)
          if (allMessages.isNotEmpty) {
            allMessages.sort((a, b) {
              final aTime = a.sentAt;
              final bTime = b.sentAt;
              return aTime.compareTo(bTime);
            });
          }

          chatMessages.value = allMessages;
        } else {
          // For first load or refresh, replace existing messages
          chatMessages.value = newMessages;

          // Sort by date (newest last)
          if (chatMessages.isNotEmpty) {
            final sortedMessages = List<ChatMessage>.from(chatMessages)
              ..sort((a, b) {
                final aTime = a.sentAt;
                final bTime = b.sentAt;
                return aTime.compareTo(bTime);
              });
            chatMessages.value = sortedMessages;
          }
        }

        // Update message cache
        _messageCache[roomId] = chatMessages;

        // Update cursor for pagination
        currentCursor.value = response.cursor;
        hasMoreMessages.value = response.cursor != null;

        // Update chat controller with the messages
        _updateControllerMessages();
      } else {
        errorMessage.value = response?.message ?? 'Failed to load messages';
      }
    } catch (e) {
      print('Error loading messages: $e');
      errorMessage.value = 'Error loading messages: ${e.toString()}';
    } finally {
      isLoadingMessages.value = false;
    }
  }

  // Update the chat controller with current messages
  void _updateControllerMessages() {
    try {
      // Map of user ID to user
      final usersMap = <String, ChatUser>{};

      // Add all participants as users
      for (var participant in participants) {
        usersMap[participant.userId] = ChatUser(
          id: participant.userId,
          name: participant.username ?? 'User',
          profilePhoto: participant.profileImage ?? '',
        );
      }

      // Clear existing messages and other users
      _chatController.initialMessageList = [];
      _chatController.otherUsers.clear();

      // Add other users to controller
      _chatController.otherUsers.addAll(
        usersMap.values.where((user) => user.id != staffId).toList(),
      );

      // Convert to ChatView messages
      final chatViewMessages = chatMessages.map(_convertToChatViewMessage).toList();

      // Set all messages at once to avoid multiple UI updates
      _chatController.initialMessageList = chatViewMessages;
    } catch (e) {
      print('Error updating controller messages: $e');
      errorMessage.value = 'Error updating messages: ${e.toString()}';
    }
  }

  // Send a text message
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    try {
      if (currentRoomId.value.isEmpty) {
        errorMessage.value = 'Cannot send message: Chat not initialized';
        return;
      }

      if (staffId.isEmpty) {
        errorMessage.value = 'Cannot send message: Staff not authenticated';
        return;
      }

      // Create a temporary message with pending status
      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      final tempMessage = ChatMessage(
        id: tempId,
        roomId: currentRoomId.value,
        content: message,
        senderId: staffId,
        senderType: staffType,
        sentAt: DateTime.now(),
        contentType: 'TEXT',
      );

      // Add temporary message to the UI (optimistic update)
      final updatedMessages = <ChatMessage>[...chatMessages, tempMessage];
      chatMessages.value = updatedMessages;

      // Update the local message cache
      _messageCache[currentRoomId.value] = updatedMessages;

      // Add to chat controller
      _chatController.addMessage(_convertToChatViewMessage(tempMessage, isPending: true));

      // Update the room's last message (optimistic)
      _updateLastMessageInRoom(message);

      // Send the actual message to server
      final response = await _chatUsecase.sendTextMessage(
        roomId: currentRoomId.value,
        senderId: staffId,
        senderType: staffType,
        message: message,
      );

      if (response?.isMessageSendSuccessful() == true && response!.chatMessage != null) {
        // Replace the temporary message with the real one from the server
        final serverMessage = response.chatMessage!;

        // Find the index of the temp message
        final index = chatMessages.indexWhere((msg) => msg.id == tempId);

        if (index >= 0) {
          // Create a new list to replace the message
          final newMessages = List<ChatMessage>.from(chatMessages);
          newMessages[index] = serverMessage;
          chatMessages.value = newMessages;

          // Update the cache
          _messageCache[currentRoomId.value] = newMessages;

          // Update the controller
          _updateControllerMessages();
        }
      } else {
        // Handle send failure - mark the temp message as failed
        final index = chatMessages.indexWhere((msg) => msg.id == tempId);

        if (index >= 0) {
          final newMessages = List<ChatMessage>.from(chatMessages);
          // Keep the temp message but add metadata to indicate error
          final failedMessage = tempMessage.copyWith(failed: true);
          newMessages[index] = failedMessage;
          chatMessages.value = newMessages;

          // Update the cache
          _messageCache[currentRoomId.value] = newMessages;

          // Update the controller
          _updateControllerMessages();
        }

        errorMessage.value = response?.message ?? 'Failed to send message';
      }
    } catch (e) {
      print('Error sending message: $e');
      errorMessage.value = 'Error sending message: ${e.toString()}';
    }
  }

  // Update last message in room list (for UI updates)
  void _updateLastMessageInRoom(String message) {
    final index = chatRooms.indexWhere((room) => room.id == currentRoomId.value);
    if (index >= 0) {
      final updatedRoom = chatRooms[index].copyWith(
        lastMessage: message,
        lastMessageAt: DateTime.now(),
      );

      final updatedRooms = List<ChatRoom>.from(chatRooms);
      updatedRooms[index] = updatedRoom;
      chatRooms.value = updatedRooms;

      // Apply filter to update the filtered list
      _applyRoomFilter();
    }
  }

  // Convert app chat message to ChatView message
  Message _convertToChatViewMessage(ChatMessage message, {bool isPending = false}) {
    // Determine message status
    MessageStatus status = MessageStatus.delivered;

    // Check for pending status (optimistic updates)
    if (isPending || (message.id != null && message.id!.startsWith('temp_'))) {
      status = MessageStatus.pending;
    }
    // Check for error status
    else if (message.failed == true) {
      status = MessageStatus.undelivered;
    }
    // Check for read status
    else if (message.readBy != null && message.readBy!.isNotEmpty) {
      status = MessageStatus.read;
    }

    // Determine message type
    MessageType messageType = MessageType.text;
    switch (message.contentType) {
      case 'IMAGE':
        messageType = MessageType.image;
        break;
      case 'AUDIO':
      case 'FILE':
      case 'ACTIVITY':
        messageType = MessageType.custom;
        break;
      default:
        messageType = MessageType.text;
    }

    // For activity messages, include activity title and type
    String messageContent = message.content;
    if (message.contentType == 'ACTIVITY' && message.activityData != null) {
      final title = message.activityData!.title?.localize('ENGLISH') ?? '';
      if (title.isNotEmpty) {
        messageContent = title + (messageContent.isNotEmpty ? ': $messageContent' : '');
      }
    }

    // Create ChatView message
    return Message(
      id: message.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      message: messageContent,
      createdAt: message.sentAt ?? DateTime.now(),
      sentBy: message.senderId ?? '',
      status: status,
      messageType: messageType,
    );
  }

  // Create a new chat room
  Future<ChatRoom?> createChatRoom({
    required String name,
    required String description,
    String roomType = 'DIRECT',
    String locale = 'ENGLISH',
  }) async {
    if (selectedBusinessId == null) {
      errorMessage.value = 'Cannot create chat room: No business selected';
      return null;
    }

    try {
      final localizedName = [LocalizedField(key: locale, value: name)];
      final localizedDescription = [LocalizedField(key: locale, value: description)];

      final response = await _chatUsecase.createChatRoom(
        businessId: selectedBusinessId!,
        name: localizedName,
        description: localizedDescription,
        // type: roomType,
      );

      if (response?.success == true && response!.chatRoom != null) {
        // Refresh chat rooms list
        await loadChatRooms();
        return response.chatRoom;
      } else {
        errorMessage.value = response?.message ?? 'Failed to create chat room';
      }
    } catch (e) {
      print('Error creating chat room: $e');
      errorMessage.value = 'Error creating chat room: ${e.toString()}';
    }
    return null;
  }

  // Toggle the active status of a room
  Future<void> toggleRoomStatus(String roomId, bool isActive) async {
    if (selectedBusinessId == null) {
      errorMessage.value = 'Cannot update room: No business selected';
      return;
    }

    try {
      // final response = await _chatUsecase.updateChatRoom(
      //   businessId: selectedBusinessId!,
      //   roomId: roomId,
      //   isActive: isActive,
      // );

      // if (response?.success == true && response!.chatRoom != null) {
      //   // Update the room in the list
      //   final index = chatRooms.indexWhere((room) => room.id == roomId);
      //   if (index >= 0) {
      //     final updatedRooms = List<ChatRoom>.from(chatRooms);
      //     updatedRooms[index] = response.chatRoom!;
      //     chatRooms.value = updatedRooms;

      //     // If this is the current room, update it
      //     if (currentRoomId.value == roomId) {
      //       currentRoom.value = response.chatRoom;
      //     }

      //     // Apply filter
      //     _applyRoomFilter();
      //   }
      // } else {
      //   errorMessage.value = response?.message ?? 'Failed to update room status';
      // }
    } catch (e) {
      print('Error updating room status: $e');
      errorMessage.value = 'Error updating room status: ${e.toString()}';
    }
  }

  // Back to room list from detail view (for small screens)
  void backToRoomList() {
    showSmallScreenDetail.value = false;
  }

  // Toggle side panel visibility (for large screens)
  void toggleSidePanel() {
    isSidePanelOpen.value = !isSidePanelOpen.value;
  }

  // Load more messages (pagination)
  Future<void> loadMoreMessages() async {
    if (hasMoreMessages.value && !isLoadingMessages.value) {
      await loadMessagesForRoom(currentRoomId.value, loadMore: true);
    }
  }

  // Force refresh the current chat room
  Future<void> refreshCurrentRoom() async {
    if (currentRoomId.value.isNotEmpty) {
      await loadMessagesForRoom(currentRoomId.value, forceRefresh: true);
    }
  }

  // Force refresh all chat rooms
  Future<void> refreshChatRooms() async {
    await loadChatRooms();
  }

  @override
  void onClose() {
    // Leave the current room
    if (currentRoomId.value.isNotEmpty) {
      appViewmodel.chatSocketService.leaveRoom(currentRoomId.value);
    }
    super.onClose();
  }
}
