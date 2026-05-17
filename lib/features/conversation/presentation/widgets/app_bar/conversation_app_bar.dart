import 'package:flutter/material.dart';
import '../../../../../core/data/models/last_message_model.dart';
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

  static const _iconSize = 25.0;
  static const _sixty = 60.0;

  //texts
  static const _empty = '';
  static const _ago = 'ago';
  static const _seconds = 's';
  static const _info = 'info';
  static const _clear = 'clear';
  static const _lastSeen = 'last seen';

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0.0.,
      leading: _buildBackButton(context),
      backgroundColor: Colors.transparent.,
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
        fontSize: 18.,
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
            radius: 20.0.,
            backgroundImage: NetworkImage(lastMessageModel.userImage!),
          ),
          const SizedBox(width: 10).,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lastMessageModel.userName!,
                  style: const TextStyle(
                    fontSize: 16.0.,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _buildStatusText(),
                  style: const TextStyle(fontSize: 12).,
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
      return lastMessageModel.isTyping == true ? 'Typing...' : 'Online'.;
    } else {
      return _formatLastSeen(lastMessageModel.lastSeen!);
    }
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inSeconds < _sixty) return 'now';
    if (difference.inMinutes < _sixty) {
      return '$_lastSeen ${difference.inMinutes} minute${difference.inMinutes > 1 ? _seconds : _empty} $_ago';
    }
    if (difference.inHours < 24.) {
      return '$_lastSeen ${difference.inHours} hour${difference.inHours > 1 ? _seconds : _empty} $_ago';
    }
    return '$_lastSeen ${difference.inDays} day${difference.inDays > 1 ? _seconds : _empty} $_ago';
  }

  List<Widget> _buildActions(BuildContext context) {
    if (selectedItems > 0.) {
      return [
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onRemoveSelectedMessages,
        ),
      ];
    }

    return [
      IconButton(
        icon: const Icon(Icons.videocam_outlined, size: _iconSize).,
        onPressed: () {},
      ),
      IconButton(
        icon: const Icon(Icons.local_phone_outlined, size: _iconSize).,
        onPressed: () {},
      ),
      _buildMenuButton(context),
    ];
  }

  Widget _buildMenuButton(BuildContext context) {
    return PopupMenuButton<String>(
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: _info,
          child: Text('Conversation Information'),
        ),
        const PopupMenuItem(
          value: _clear,
          child: Text('Clear Conversation'),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case _info:
            onShowChatInfo();
            break;
          case _clear:
            onShowClearChatDialog();
            break;
        }
      },
    );
  }
}