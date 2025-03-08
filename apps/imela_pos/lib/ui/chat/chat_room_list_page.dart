import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/ui/chat/chat_viewmodel.dart';
import 'package:imela_pos/ui/chat/chat_detail_page.dart';
import 'package:imela_pos/ui/chat/components/chat_side_panel.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/components/page_loading_utils/responsive_wrapper.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_core/chat/model/chat_room.model.dart';
import 'package:intl/intl.dart';

class ChatRoomListPage extends StatefulWidget {
  static const routeName = '/chat';

  const ChatRoomListPage({Key? key}) : super(key: key);

  @override
  _ChatRoomListPageState createState() => _ChatRoomListPageState();

  static void navigate(BuildContext context) {
    final router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, routeName);
  }
}

class _ChatRoomListPageState extends State<ChatRoomListPage> {
  late ChatViewModel _viewModel;
  late WidgetFactory _widgetFactory;

  @override
  void initState() {
    super.initState();
    _viewModel = ChatViewModel.getInstance();
    _widgetFactory = AppViewmodel.getWidgetFactory(context);
    
    // Initialize view model
    _viewModel.initViewModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _viewModel.refreshChatRooms(),
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showCreateChatRoomDialog(),
          ),
        ],
      ),
      body: ResponsiveWrapper(
        smallScreen: _buildSmallScreenLayout(),
        largeScreen: _buildLargeScreenLayout(),
      ),
    );
  }

  Widget _buildSmallScreenLayout() {
    return Obx(() {
      if (_viewModel.showSmallScreenDetail.value && _viewModel.currentRoomId.value.isNotEmpty) {
        return ChatDetailPage();
      }
      
      return _buildRoomList();
    });
  }

  Widget _buildLargeScreenLayout() {
    return Row(
      children: [
        Obx(() {
          if (!_viewModel.isSidePanelOpen.value) {
            return IconButton(
              icon: Icon(Icons.menu),
              onPressed: () => _viewModel.toggleSidePanel(),
            );
          }
          
          return ChatSidePanel(
            viewModel: _viewModel,
            widgetFactory: _widgetFactory,
          );
        }),
        Expanded(
          child: _viewModel.currentRoomId.value.isEmpty
              ? Center(child: Text('Select a chat room to view messages'))
              : ChatDetailPage(),
        ),
      ],
    );
  }

  Widget _buildRoomList() {
    return Obx(() {
      final isLoading = _viewModel.isLoading.value;
      final hasError = _viewModel.exception.value != null;
      
      return PageContentLoader(
        isLoading: isLoading,
        hasError: hasError,
        onTryAgain: () => _viewModel.refreshChatRooms(),
        exception: _viewModel.exception.value,
        content: _viewModel.filteredChatRooms.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                itemCount: _viewModel.filteredChatRooms.length,
                itemBuilder: (context, index) {
                  final chatRoom = _viewModel.filteredChatRooms[index];
                  return _buildRoomListItem(chatRoom);
                },
              ),
      );
    });
  }

  Widget _buildRoomListItem(ChatRoom chatRoom) {
    // Format date
    String lastMessageTime = '';
    if (chatRoom.lastMessageAt != null) {
      final now = DateTime.now();
      final messageDate = chatRoom.lastMessageAt!;
      
      if (now.difference(messageDate).inDays == 0) {
        // Today - show time only
        lastMessageTime = DateFormat('HH:mm').format(messageDate);
      } else if (now.difference(messageDate).inDays < 7) {
        // Within a week - show day of week
        lastMessageTime = DateFormat('EEE').format(messageDate);
      } else {
        // Older - show date
        lastMessageTime = DateFormat('dd/MM/yy').format(messageDate);
      }
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Icon(
            chatRoom.isGroupChat() ? Icons.group : Icons.person,
            color: Colors.white,
          ),
        ),
        title: Text(
          chatRoom.getLocalizedName('ENGLISH'),
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          chatRoom.lastMessage ?? 'No messages yet',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              lastMessageTime,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: chatRoom.isActive
                        ? Colors.green
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    chatRoom.isActive ? 'Active' : 'Closed',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                SizedBox(width: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: chatRoom.isGroupChat()
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    chatRoom.isGroupChat() ? 'Group' : 'Direct',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () => _viewModel.loadRoom(chatRoom.id!),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          SizedBox(height: 16),
          Text(
            'No chat rooms available',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 8),
          Text(
            'Create a new chat room to start messaging',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _showCreateChatRoomDialog,
            child: Text('Create Chat Room'),
          ),
        ],
      ),
    );
  }

  void _showCreateChatRoomDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedRoomType = 'DIRECT';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create New Chat Room'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Room Name',
                  hintText: 'Enter room name',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter room description',
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRoomType,
                decoration: InputDecoration(
                  labelText: 'Room Type',
                ),
                items: [
                  DropdownMenuItem(
                    value: 'DIRECT',
                    child: Text('Direct Chat'),
                  ),
                  DropdownMenuItem(
                    value: 'GROUP',
                    child: Text('Group Chat'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    selectedRoomType = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                Navigator.of(context).pop();
                await _viewModel.createChatRoom(
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim(),
                  roomType: selectedRoomType,
                );
              }
            },
            child: Text('Create'),
          ),
        ],
      ),
    );
  }
} 