import 'package:flutter/material.dart';


class MessengerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String profileImage;
  final VoidCallback onProfilePressed;
  final VoidCallback onThemeToggle;

  const MessengerAppBar({
    required this.profileImage,
    required this.onProfilePressed,
    required this.onThemeToggle,
    super.key,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      scrolledUnderElevation: 0.0,
      titleSpacing: 20.0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 20.0,
            backgroundImage: NetworkImage(profileImage),
          ),
          const SizedBox(width: 15.0),
          const Text(
            'Chats',
            style: TextStyle(
              fontSize: 20,
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
        radius: 15.0,
        backgroundColor: Colors.blue,
        child: Icon(
          icon,
          size: 16.0,
          color: Colors.white,
        ),
      ),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }
}