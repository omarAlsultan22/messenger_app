import 'package:flutter/material.dart';
import 'package:test_app/core/constants/app_sizes.dart';
import 'package:test_app/core/constants/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';


class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String profileImage;
  final VoidCallback onProfilePressed;
  final VoidCallback onThemeToggle;

  const ChatAppBar({
    required this.profileImage,
    required this.onProfilePressed,
    required this.onThemeToggle,
    super.key,
  });

  static const _sm = 15.0;
  static const _md = 20.0;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: AppSizes.none,
      scrolledUnderElevation: AppSizes.none,
      title: Row(
        children: [
          CircleAvatar(
            radius: _md,
            backgroundImage: CachedNetworkImageProvider(profileImage),
          ),
          const SizedBox(width: _sm),
          const Text(
            'Chats',
            style: TextStyle(
              fontSize: _md,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        _buildActionButton(
          icon: Icons.edit,
          onPressed: onProfilePressed,
          tooltip: 'Edit Profile',
        ),
        _buildActionButton(
          icon: Icons.brightness_4_outlined,
          onPressed: onThemeToggle,
          tooltip: 'Toggle Theme',
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return IconButton(
      icon: CircleAvatar(
        radius: _sm,
        backgroundColor: AppColors.bluePrimaryValue,
        child: Icon(
          icon,
          size: 16.0,
          color: AppColors.white,
        ),
      ),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }
}