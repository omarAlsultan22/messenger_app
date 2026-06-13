import 'package:flutter/material.dart';
import 'package:test_app/core/constants/app_sizes.dart';
import 'package:test_app/core/constants/app_colors.dart';
import 'package:test_app/core/constants/app_borders.dart';
import 'package:test_app/core/constants/app_paddings.dart';
import 'package:test_app/core/constants/app_text_styles.dart';
import '../../../../core/data/models/last_message_model.dart';
import 'package:test_app/features/home/utils/helpers/date_formatter.dart';


class ChatsList extends StatelessWidget {
  late var isAddingRandomFriend = false;
  final List<LastMessageModel> filteredData;
  final TextEditingController searchController;
  final Function(LastMessageModel) onChatTap;

  ChatsList({
    required this.filteredData,
    required this.searchController,
    required this.onChatTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (filteredData.isEmpty && searchController.text.isNotEmpty) {
      const Center(
        child: Text(
          'No result found',
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          const Text(
          'Chats',
          style: AppTextStyles.textStyle_18
        ),
        const SizedBox(height: 10),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) => ChatItem(
            lastMessageModel: filteredData[index],
            onTap: onChatTap,
          ),
          separatorBuilder: (context, index) => const SizedBox(height: 20.0),
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

  static const _spacing2 = 2.0;
  static const _spacing6 = 6.0;
  static const _spacing14 = 14.0;

  @override
  Widget build(BuildContext context) {
    if (lastMessageModel.docId.isEmpty) return const SizedBox();

    return InkWell(
      onTap: () => onTap(lastMessageModel),
      borderRadius: AppBorders.borderRadius_12,
      child: Container(
        padding: AppPaddings.vSmall,
        child: Row(
          children: [
            _buildUserAvatarWithBadge(),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lastMessageModel.firstName ?? '',
                    style: AppTextStyles.textStyle_16,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
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
            if(!lastMessageModel.isFriend)...[
              const Spacer()
              ,
              MaterialButton(onPressed: () {},
                  color: AppColors.blue700,
                  child: const Text('Add', style:
                  TextStyle(
                      fontWeight: FontWeight.bold
                  )
                  )
              )
            ]
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
            right: AppSizes.none,
            top: AppSizes.none,
            child: Container(
              padding: const EdgeInsets.all(4.0),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.redPrimaryValue,
              ),
              child: Text(
                lastMessageModel.unreadMessagesCount > 99
                    ? '99+'
                    : lastMessageModel.unreadMessagesCount.toString(),
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        Positioned(
          bottom: _spacing2,
          right: _spacing2,
          child: Container(
            width: _spacing14,
            height: _spacing14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: lastMessageModel.isOnline == true ? AppColors
                  .green : AppColors.greyPrimaryValue,
              border: Border.all(color: AppColors.white, width: _spacing2),
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
          width: _spacing6,
          height: _spacing6,
          decoration: const BoxDecoration(
            color: AppColors.bluePrimaryValue,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: _spacing6),
        Text(
          DateFormatter.formatTime(lastMessageModel.lastMessageDateTime),
          style: AppTextStyles.textStyle_12,
        ),
      ],
    );
  }
}