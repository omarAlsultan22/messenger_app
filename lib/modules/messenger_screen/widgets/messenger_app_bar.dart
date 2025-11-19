import 'package:flutter/material.dart';
import '../../../shared/constants/user_details.dart';


class MessengerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onProfilePressed;
  final VoidCallback onThemeToggle;

  const MessengerAppBar({
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
      title: const Row(
        children: [
          CircleAvatar(
            radius: 20.0,
            backgroundImage: NetworkImage(UserDetails.image),
          ),
          SizedBox(width: 15.0),
          Text(
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