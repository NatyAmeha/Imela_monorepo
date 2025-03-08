import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatview/chatview.dart';
import 'package:imela_pos/ui/chat/chat_viewmodel.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class ChatDetailPage extends StatefulWidget {
  const ChatDetailPage({Key? key}) : super(key: key);

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final _viewModel = ChatViewModel.getInstance();
  late final WidgetFactory _widgetFactory;

  @override
  void initState() {
    super.initState();
    _widgetFactory = WidgetFactory(Theme.of(context).platform);
    
    // If we have a room ID but no messages yet, load messages
    if (_viewModel.currentRoomId.value.isNotEmpty && _viewModel.chatMessages.isEmpty) {
      _viewModel.loadMessagesForRoom(_viewModel.currentRoomId.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => _viewModel.backToRoomList(),
        ),
        title: Obx(() {
          final room = _viewModel.currentRoom.value;
          return Text(room?.getLocalizedName('ENGLISH') ?? 'Chat');
        }),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _viewModel.refreshCurrentRoom(),
          ),
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: _showRoomInfoDialog,
          ),
          _buildRoomStatusToggle(),
        ],
      ),
      body: Obx(() {
        final isLoading = _viewModel.isLoadingMessages.value;
        final hasError = _viewModel.exception.value != null;
        
        if (_viewModel.currentRoom.value == null) {
          return Center(child: Text('Select a chat room to view messages'));
        }
        
        return PageContentLoader(
          isLoading: isLoading && _viewModel.chatMessages.isEmpty,
          hasError: hasError,
          onTryAgain: () => _viewModel.loadRoom(_viewModel.currentRoomId.value),
          exception: _viewModel.exception.value,
          content: _buildChatContent(),
        );
      }),
    );
  }

  Widget _buildChatContent() {
    return Column(
      children: [
        if (_viewModel.currentRoom.value?.welcomeMessage != null && _viewModel.currentRoom.value!.welcomeMessage!.isNotEmpty)
          Container(
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 4),
                Text(
                  _viewModel.currentRoom.value!.welcomeMessage!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        Expanded(
          child: ChatView(
            chatController: _viewModel.chatController,
            onSendTap: _handleSendMessage,
            appBar: null, // We're using our own AppBar
            chatViewState: _viewModel.chatMessages.isEmpty && !_viewModel.isLoadingMessages.value
                ? ChatViewState.noData
                : ChatViewState.hasMessages,
            chatBackgroundConfig: ChatBackgroundConfiguration(
              messageTimeIconColor: Theme.of(context).colorScheme.outline,
              messageTimeTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontSize: 12,
              ),
            ),
            sendMessageConfig: SendMessageConfiguration(
              replyMessageColor: Theme.of(context).colorScheme.primaryContainer,
              replyDialogColor: Theme.of(context).colorScheme.primary,
              replyTitleColor: Theme.of(context).colorScheme.onPrimary,
              closeIconColor: Theme.of(context).colorScheme.onPrimaryContainer,
              defaultSendButtonColor: Theme.of(context).colorScheme.primary,
              textFieldBackgroundColor: Theme.of(context).colorScheme.surface,
              textFieldConfig: TextFieldConfiguration(
                textStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                hintText: 'Type a message...',
                borderRadius: BorderRadius.circular(24),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
            chatBubbleConfig: ChatBubbleConfiguration(
              onDoubleTap: (message) {
                // Handle double tap if needed
              },
              outgoingChatBubbleConfig: ChatBubble(
                color: Theme.of(context).colorScheme.primary,
                textStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                borderRadius: BorderRadius.circular(16),
              ),
              inComingChatBubbleConfig: ChatBubble(
                color: Theme.of(context).colorScheme.secondaryContainer,
                textStyle: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer),
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            loadMoreData: _viewModel.hasMoreMessages.value ? _viewModel.loadMoreMessages : null,
            isLastPage: !_viewModel.hasMoreMessages.value,
          ),
        ),
      ],
    );
  }

  Widget _buildRoomStatusToggle() {
    return Obx(() {
      final room = _viewModel.currentRoom.value;
      if (room == null) return SizedBox.shrink();

      return Switch(
        value: room.isActive,
        onChanged: (value) => _viewModel.toggleRoomStatus(room.id!, value),
        activeColor: Colors.green,
        inactiveThumbColor: Colors.grey,
        activeTrackColor: Colors.green.withOpacity(0.5),
        inactiveTrackColor: Colors.grey.withOpacity(0.5),
      );
    });
  }

  void _handleSendMessage(String message, ReplyMessage replyMessage, MessageType messageType) {
    if (message.trim().isNotEmpty) {
      _viewModel.sendMessage(message);
    }
  }

  void _showRoomInfoDialog() {
    final room = _viewModel.currentRoom.value;
    final participants = _viewModel.participants;
    
    if (room == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chat Information'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Room: ${room.getLocalizedName('ENGLISH')}', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Type: ${room.type == 'GROUP' ? 'Group Chat' : 'Direct Chat'}'),
              SizedBox(height: 8),
              Text('Status: ${room.isActive ? 'Active' : 'Closed'}'),
              SizedBox(height: 8),
              Text('Created: ${_formatDate(room.createdAt)}'),
              SizedBox(height: 16),
              Text('Participants (${participants.length}):', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ...participants.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text('• ${p.userId} (${p.type})'),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
} 