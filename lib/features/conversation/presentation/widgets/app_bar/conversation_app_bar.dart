import 'package:flutter/material.dart';
import 'package:test_app/core/constants/app_sizes.dart';
import 'package:test_app/core/constants/app_colors.dart';
import 'package:test_app/core/constants/app_text_styles.dart';
import '../../../../../core/data/models/last_message_model.dart';
import 'package:test_app/features/conversation/constants/conversation_texts.dart';


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

  static const _duration = Duration(seconds: 60);

  //texts
  static const _ago = 'ago';
  static const _seconds = 's';
  static const _info = 'info';
  static const _clear = 'clear';
  static const _lastSeen = 'last seen';
  static const _empty = ConversationTexts.empty;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: AppSizes.none,
      leading: _buildBackButton(context),
      backgroundColor: AppColors.transparent,
      title: selectedItems > 0 ? _buildSelectionTitle() : _buildUserTitle(
          context),
      actions: _buildActions(context),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: selectedItems > 0 ? onClearSelection : () =>
          Navigator.pop(context),
    );
  }

  Widget _buildSelectionTitle() {
    return Text(
      '$selectedItems',
      style: AppTextStyles.textStyle_18
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
                  lastMessageModel.firstName!,
                  style: AppTextStyles.textStyle_16,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _buildStatusText(),
                  style: AppTextStyles.textStyle_12,
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

    if (difference.inSeconds < _duration.inSeconds) return 'now';
    if (difference.inMinutes < _duration.inMinutes) {
      return '$_lastSeen ${difference.inMinutes} minute${difference.inMinutes >
          1 ? _seconds : _empty} $_ago';
    }
    if (difference.inHours < 24) {
      return '$_lastSeen ${difference.inHours} hour${difference.inHours > 1
          ? _seconds
          : _empty} $_ago';
    }
    return '$_lastSeen ${difference.inDays} day${difference.inDays > 1
        ? _seconds
        : _empty} $_ago';
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
      _buildMenuButton(context),
    ];
  }

  Widget _buildMenuButton(BuildContext context) {
    return PopupMenuButton<String>(
      itemBuilder: (context) =>
      [
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