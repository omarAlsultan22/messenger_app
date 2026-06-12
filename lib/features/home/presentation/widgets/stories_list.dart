import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import 'package:test_app/core/constants/app_colors.dart';
import '../../../../core/data/models/last_message_model.dart';


class StoriesList extends StatelessWidget {
  final List<LastMessageModel> friends;
  final Function(LastMessageModel) onFriendTap;

  const StoriesList({
    required this.friends,
    required this.onFriendTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 106.0,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => StoryItem(
              friend: friends[index],
              onTap: (friend)=> onFriendTap(friend),
            ),
            separatorBuilder: (context, index) => const SizedBox(width: 20.0),
            itemCount: friends.length,
          ),
        ),
      ],
    );
  }
}


class StoryItem extends StatelessWidget {
  final LastMessageModel friend;
  final Function(LastMessageModel) onTap;

  const StoryItem({
    required this.friend,
    required this.onTap,
    super.key,
  });

  static const _spacing2 = 2.0;
  static const spacing60 = 60.0;
  static const _spacing14 = 14.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: spacing60,
      child: InkWell(
        onTap: () => onTap(friend),
        borderRadius: BorderRadius.circular(30),
        child: Column(
          children: [
            Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                Container(
                  width: spacing60,
                  height: spacing60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.blue,
                      width: _spacing2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 28.0,
                    backgroundImage: NetworkImage(friend.userImage!),
                  ),
                ),
                if (friend.isOnline == true)
                  Positioned(
                    bottom: _spacing2,
                    right: _spacing2,
                    child: Container(
                      width: _spacing14,
                      height: _spacing14,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.green,
                        border: Border.fromBorderSide(
                          BorderSide(color: AppColors.white, width: _spacing2),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6.0),
            Text(
              friend.firstName ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: AppSizes.xs,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}