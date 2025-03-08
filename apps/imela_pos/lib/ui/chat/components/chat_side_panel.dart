import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_pos/ui/chat/chat_viewmodel.dart';
import 'package:imela_core/chat/model/chat_room.model.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:intl/intl.dart';

class ChatSidePanel extends StatelessWidget {
  final ChatViewModel viewModel;
  final WidgetFactory widgetFactory;
  
  const ChatSidePanel({
    Key? key,
    required this.viewModel,
    required this.widgetFactory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          _buildFilterButtons(context),
          Expanded(
            child: _buildRoomList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'Chat Rooms',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showCreateChatRoomDialog(context),
            tooltip: 'Create New Chat Room',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => viewModel.refreshChatRooms(),
            tooltip: 'Refresh Rooms',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtons(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Obx(() {
              final isSelected = viewModel.selectedFilter.value == ChatRoomFilter.ALL;
              return _filterButton(
                context, 
                'All', 
                isSelected, 
                () => viewModel.changeFilter(ChatRoomFilter.ALL)
              );
            }),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Obx(() {
              final isSelected = viewModel.selectedFilter.value == ChatRoomFilter.ACTIVE;
              return _filterButton(
                context, 
                'Active', 
                isSelected, 
                () => viewModel.changeFilter(ChatRoomFilter.ACTIVE)
              );
            }),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Obx(() {
              final isSelected = viewModel.selectedFilter.value == ChatRoomFilter.CLOSED;
              return _filterButton(
                context, 
                'Closed', 
                isSelected, 
                () => viewModel.changeFilter(ChatRoomFilter.CLOSED)
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _filterButton(BuildContext context, String text, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary 
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary 
                : Theme.of(context).colorScheme.outline,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: isSelected 
                ? Theme.of(context).colorScheme.onPrimary 
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildRoomList(BuildContext context) {
    return Obx(() {
      if (viewModel.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }
      
      if (viewModel.filteredChatRooms.isEmpty) {
        return _buildEmptyState(context);
      }
      
      return ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 8),
        itemCount: viewModel.filteredChatRooms.length,
        separatorBuilder: (context, index) => Divider(height: 1),
        itemBuilder: (context, index) {
          final chatRoom = viewModel.filteredChatRooms[index];
          return _buildRoomListItem(context, chatRoom);
        },
      );
    });
  }

  Widget _buildRoomListItem(BuildContext context, ChatRoom chatRoom) {
    final now = DateTime.now();
    String lastMessageTime = '';
    
    if (chatRoom.lastMessageAt != null) {
      final lastMessageDate = chatRoom.lastMessageAt!;
      
      if (lastMessageDate.year == now.year && 
          lastMessageDate.month == now.month && 
          lastMessageDate.day == now.day) {
        // Today - show time
        lastMessageTime = DateFormat('HH:mm').format(lastMessageDate);
      } else if (lastMessageDate.year == now.year &&
                lastMessageDate.month == now.month &&
                lastMessageDate.day == now.day - 1) {
        // Yesterday
        lastMessageTime = 'Yesterday';
      } else {
        // Other dates
        lastMessageTime = DateFormat('dd/MM/yyyy').format(lastMessageDate);
      }
    }

    return Obx(() {
      final isSelected = viewModel.currentRoomId.value == chatRoom.id;
      
      return Material(
        color: isSelected 
            ? Theme.of(context).colorScheme.primaryContainer 
            : Colors.transparent,
        child: InkWell(
          onTap: () {
            viewModel.loadRoom(chatRoom.id!);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: chatRoom.isActive 
                      ? Theme.of(context).colorScheme.primary 
                      : Theme.of(context).colorScheme.outline,
                  radius: 24,
                  child: Icon(
                    chatRoom.isGroupChat() ? Icons.group : Icons.person,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chatRoom.getLocalizedName('ENGLISH'),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isSelected 
                                    ? Theme.of(context).colorScheme.onPrimaryContainer 
                                    : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            lastMessageTime,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isSelected 
                                  ? Theme.of(context).colorScheme.onPrimaryContainer 
                                  : Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        chatRoom.lastMessage ?? chatRoom.getLocalizedDescription('ENGLISH'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSelected 
                              ? Theme.of(context).colorScheme.onPrimaryContainer 
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Row(
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
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildEmptyState(BuildContext context) {
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
            onPressed: () => _showCreateChatRoomDialog(context),
            child: Text('Create Chat Room'),
          ),
        ],
      ),
    );
  }

  void _showCreateChatRoomDialog(BuildContext context) {
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
                await viewModel.createChatRoom(
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