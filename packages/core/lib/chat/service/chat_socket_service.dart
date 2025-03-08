import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:injectable/injectable.dart';
import 'package:imela_core/chat/model/chat_message.model.dart';
import 'package:imela_core/chat/model/chat_participant.model.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

@singleton
class ChatSocketService {
  IO.Socket? _socket;
  bool _isConnected = false;
  String? _userId;
  
  // Stream controllers for event broadcasting
  final _messageReceivedController = StreamController<ChatMessage>.broadcast();
  final _messageDeliveredController = StreamController<Map<String, dynamic>>.broadcast();
  final _messageReadController = StreamController<Map<String, dynamic>>.broadcast();
  final _typingIndicatorController = StreamController<TypingIndicator>.broadcast();
  final _participantJoinedController = StreamController<ChatParticipant>.broadcast();
  final _participantLeftController = StreamController<ChatParticipant>.broadcast();
  final _roomClosedController = StreamController<String>.broadcast();

  // Expose streams for listeners
  Stream<ChatMessage> get onMessageReceived => _messageReceivedController.stream;
  Stream<Map<String, dynamic>> get onMessageDelivered => _messageDeliveredController.stream;
  Stream<Map<String, dynamic>> get onMessageRead => _messageReadController.stream;
  Stream<TypingIndicator> get onTypingIndicator => _typingIndicatorController.stream;
  Stream<ChatParticipant> get onParticipantJoined => _participantJoinedController.stream;
  Stream<ChatParticipant> get onParticipantLeft => _participantLeftController.stream;
  Stream<String> get onRoomClosed => _roomClosedController.stream;

  bool get isConnected => _isConnected;
  String? get userId => _userId;

  void connect(String userId, String token) {
    const String serverUrl = 'http://192.168.1.2:3000/chat';
    if (_isConnected) {
      if (kDebugMode) {
        print('Socket already connected');
      }
      return;
    }

    _userId = userId;
    
    try {
      _socket = IO.io(serverUrl, IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .setAuth({'token': token})
        .build()
      );

      _socket!.connect();
      
      _socket!.onConnect((_) {
        _isConnected = true;
        if (kDebugMode) {
          print('Socket connected');
        }
        
        // Register user after connection
        _socket!.emit('register', userId);
      });

      _socket!.onDisconnect((_) {
        _isConnected = false;
        if (kDebugMode) {
          print('Socket disconnected');
        }
      });

      _socket!.onError((error) {
        if (kDebugMode) {
          print('Socket error: $error');
        }
      });

      _setupEventListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error connecting to socket: $e');
      }
    }
  }

  void disconnect() {
    if (!_isConnected) return;
    
    _socket?.disconnect();
    _isConnected = false;
    _userId = null;
    if (kDebugMode) {
      print('Socket disconnected manually');
    }
  }

  void _setupEventListeners() {
    // Listen for new messages
    _socket?.on('new_message', (data) {
      try {
        final message = ChatMessage.fromJson(jsonDecode(data));
        _messageReceivedController.add(message);
      } catch (e) {
        if (kDebugMode) {
          print('Error parsing message: $e');
        }
      }
    });

    // Listen for message read receipts
    _socket?.on('message_read', (data) {
      _messageReadController.add(data);
    });

    // Listen for message delivery confirmations
    _socket?.on('message_delivered', (data) {
      _messageDeliveredController.add(data);
    });

    // Listen for typing indicators
    _socket?.on('user_typing', (data) {
      try {
        final typingData = TypingIndicator.fromJson(data);
        _typingIndicatorController.add(typingData);
      } catch (e) {
        if (kDebugMode) {
          print('Error parsing typing indicator: $e');
        }
      }
    });

    // Listen for participant join events
    _socket?.on('participant_joined', (data) {
      try {
        final participantData = data['participant'];
        final participant = ChatParticipant.fromJson(participantData);
        _participantJoinedController.add(participant);
      } catch (e) {
        if (kDebugMode) {
          print('Error parsing participant joined: $e');
        }
      }
    });

    // Listen for participant leave events
    _socket?.on('participant_left', (data) {
      try {
        final participantData = data['participant'];
        final participant = ChatParticipant.fromJson(participantData);
        _participantLeftController.add(participant);
      } catch (e) {
        if (kDebugMode) {
          print('Error parsing participant left: $e');
        }
      }
    });

    // Listen for room closed events
    _socket?.on('room_closed', (data) {
      try {
        final roomId = data['roomId'];
        _roomClosedController.add(roomId);
      } catch (e) {
        if (kDebugMode) {
          print('Error parsing room closed: $e');
        }
      }
    });
  }

  // Room operations
  void joinRoom(String roomId) {
    if (!_isConnected || _userId == null) return;
    
    _socket?.emit('join_room', {
      'userId': _userId,
      'roomId': roomId
    });
  }

  void leaveRoom(String roomId) {
    if (!_isConnected || _userId == null) return;
    
    _socket?.emit('leave_room', {
      'userId': _userId,
      'roomId': roomId
    });
  }

  // Message operations
  void sendMessage(ChatMessage message) {
    if (!_isConnected) return;
    
    _socket?.emit('send_message', jsonEncode(message.toJson()));
  }

  void markAsRead(String messageId) {
    if (!_isConnected || _userId == null) return;
    
    _socket?.emit('mark_as_read', {
      'messageId': messageId, 
      'userId': _userId
    });
  }

  void markAsDelivered(String messageId) {
    if (!_isConnected || _userId == null) return;
    
    _socket?.emit('mark_as_delivered', {
      'messageId': messageId, 
      'userId': _userId
    });
  }

  void sendTypingIndicator(String roomId, bool isTyping) {
    if (!_isConnected || _userId == null) return;
    
    _socket?.emit('typing', {
      'roomId': roomId,
      'userId': _userId,
      'isTyping': isTyping
    });
  }

  void dispose() {
    disconnect();
    
    // Close all stream controllers
    _messageReceivedController.close();
    _messageDeliveredController.close();
    _messageReadController.close();
    _typingIndicatorController.close();
    _participantJoinedController.close();
    _participantLeftController.close();
    _roomClosedController.close();
  }
}

class TypingIndicator {
  final String roomId;
  final String userId;
  final bool isTyping;

  TypingIndicator({
    required this.roomId,
    required this.userId,
    required this.isTyping,
  });

  factory TypingIndicator.fromJson(Map<String, dynamic> json) {
    return TypingIndicator(
      roomId: json['roomId'],
      userId: json['userId'],
      isTyping: json['isTyping'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'userId': userId,
      'isTyping': isTyping,
    };
  }
} 