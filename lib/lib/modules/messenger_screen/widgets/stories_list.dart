import 'package:flutter/material.dart';
import '../models/last_message_model.dart';


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
              onTap: onFriendTap,
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60.0,
      child: InkWell(
        onTap: () => onTap(friend),
        borderRadius: BorderRadius.circular(30),
        child: Column(
          children: [
            Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.blue,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 28.0,
                    backgroundImage: NetworkImage(friend.userImage!),
                  ),
                ),
                if (friend.isOnline == true)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                        border: Border.fromBorderSide(
                          BorderSide(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6.0),
            Text(
              friend.userName ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}