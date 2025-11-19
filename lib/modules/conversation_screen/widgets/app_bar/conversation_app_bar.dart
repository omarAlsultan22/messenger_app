import 'package:flutter/material.dart';
import '../../../../models/last_message_model.dart';


class ConversationAppBar extends StatelessWidget implements PreferredSizeWidget {
  final LastMessageModel lastMessageModel;
  final int selectedItems;
  final VoidCallback onClearSelection;
  final VoidCallback onRemoveSelectedMessages;
  final VoidCallback onShowChatInfo;
  final VoidCallback onShowClearChatDialog;
  final Function(BuildContext) onNavigateToProfile;

  const ConversationAppBar({
    required this.lastMessageModel,
    required this.selectedItems,
    required this.onClearSelection,
    required this.onRemoveSelectedMessages,
    required this.onShowChatInfo,
    required this.onShowClearChatDialog,
    required this.onNavigateToProfile,
    super.key,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0.0,
      leading: _buildBackButton(context),
      backgroundColor: Colors.transparent,
      title: selectedItems > 0 ? _buildSelectionTitle() : _buildUserTitle(context),
      actions: _buildActions(context),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: selectedItems > 0 ? onClearSelection : () => Navigator.pop(context),
    );
  }

  Widget _buildSelectionTitle() {
    return Text(
      '$selectedItems',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildUserTitle(BuildContext context) {
    return InkWell(
      onTap: () => onNavigateToProfile(context),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.0,
            backgroundImage: NetworkImage(lastMessageModel.userImage!),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lastMessageModel.userName!,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _buildStatusText(),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildStatusText() {
    if (lastMessageModel.isOnline == true) {
      return lastMessageModel.isTyping == true ? 'Typing...' : 'Online';
    } else {
      return _formatLastSeen(lastMessageModel.lastSeen!);
    }
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inSeconds < 60) return 'now';
    if (difference.inMinutes < 60) {
      return 'last seen ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    }
    if (difference.inHours < 24) {
      return 'last seen ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    }
    return 'last seen ${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
  }

  List<Widget> _buildActions(BuildContext context) {
    if (selectedItems > 0) {
      return [
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onRemoveSelectedMessages,
        ),
      ];
    }

    return [
      IconButton(
        icon: const Icon(Icons.videocam_outlined, size: 25.0),
        onPressed: () {},
      ),
      IconButton(
        icon: const Icon(Icons.local_phone_outlined, size: 25.0),
        onPressed: () {},
      ),
      _buildMenuButton(context),
    ];
  }

  Widget _buildMenuButton(BuildContext context) {
    return PopupMenuButton<String>(
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'info',
          child: Text('Conversation Information'),
        ),
        const PopupMenuItem(
          value: 'clear',
          child: Text('Clear Conversation'),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'info':
            onShowChatInfo();
            break;
          case 'clear':
            onShowClearChatDialog();
            break;
        }
      },
    );
  }
}