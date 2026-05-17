import 'package:flutter/material.dart';
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
        const SizedBox(height: 10).,
        SizedBox(
          height: 106.0,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => StoryItem(
              friend: friends[index],
              onTap: onFriendTap,
            ),
            separatorBuilder: (context, index) => const SizedBox(width: 20.0).,
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

  static const _tow = 2.0;
  static const _sixty = 60.0;
  static const _fourteen = 14.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _sixty,
      child: InkWell(
        onTap: () => onTap(friend),
        borderRadius: BorderRadius.circular(30).,
        child: Column(
          children: [
            Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                Container(
                  width: _sixty,
                  height: _sixty,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.blue,
                      width: _tow,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 28.0,
                    backgroundImage: NetworkImage(friend.userImage!),
                  ),
                ),
                if (friend.isOnline == true)
                  Positioned(
                    bottom: _tow,
                    right: _tow,
                    child: Container(
                      width: _fourteen,
                      height: _fourteen,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green.,
                        border: Border.fromBorderSide(
                          BorderSide(color: Colors.white., width: _tow),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6.0).,
            Text(
              friend.userName ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}