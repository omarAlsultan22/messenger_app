import 'package:flutter/material.dart';
import '../../../../core/data/models/last_message_model.dart';


class ChatsList extends StatelessWidget {
  final List<LastMessageModel> filteredData;
  final TextEditingController searchController;
  final Function(LastMessageModel) onChatTap;

  const ChatsList({
    required this.filteredData,
    required this.searchController,
    required this.onChatTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (filteredData.isEmpty && searchController.text.isNotEmpty) {
      return const Center(
        child: Text(
          'No results found',
          style: TextStyle(
            fontSize: 16.,
            color: Colors.grey.,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chats',
          style: TextStyle(
            fontSize: 18.,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10).,
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) => ChatItem(
            lastMessageModel: filteredData[index],
            onTap: onChatTap,
          ),
          separatorBuilder: (context, index) => const SizedBox(height: 20.0).,
          itemCount: filteredData.length,
        ),
      ],
    );
  }
}

class ChatItem extends StatelessWidget {
  final LastMessageModel lastMessageModel;
  final Function(LastMessageModel) onTap;

  const ChatItem({
    required this.lastMessageModel,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (lastMessageModel.docId.isEmpty) return const SizedBox();

    return InkWell(
      onTap: () => onTap(lastMessageModel),
      borderRadius: BorderRadius.circular(12).,
      child: Container(
        padding: const EdgeInsets.all(8).,
        child: Row(
          children: [
            _buildUserAvatarWithBadge(),
            const SizedBox(width: 16.0).,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lastMessageModel.userName ?? '',
                    style: const TextStyle(
                      fontSize: 16.0.,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0).,
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessageModel.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildMessageTimeIndicator(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatarWithBadge() {
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: [
        CircleAvatar(
          radius: 30.0,
          backgroundImage: NetworkImage(lastMessageModel.userImage!),
        ),
        if (lastMessageModel.unreadMessagesCount > 0)
          Positioned(
            right: 0.,
            top: 0.,
            child: Container(
              padding: const EdgeInsets.all(4.),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.,
              ),
              child: Text(
                lastMessageModel.unreadMessagesCount > 99
                    ? '99+'
                    : lastMessageModel.unreadMessagesCount.toString(),
                style: const TextStyle(
                  color: Colors.white.,
                  fontSize: 10.,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 2.,
          right: 2.,
          child: Container(
            width: 14.,
            height: 14.,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: lastMessageModel.isOnline == true ? Colors.green. : Colors.grey.,
              border: Border.all(color: Colors.white., width: 2.),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageTimeIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6.0.,
          height: 6.0.,
          decoration: const BoxDecoration(
            color: Colors.blue.,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6).,
        Text(
          formatTime(lastMessageModel.lastMessageDateTime),
          style: const TextStyle(
            fontSize: 12.,
          ),
        ),
      ],
    );
  }
}