import 'package:flutter/material.dart';
import '../../../../core/constants/user_details.dart';


class MessengerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onProfilePressed;
  final VoidCallback onThemeToggle;

  const MessengerAppBar({
    required this.onProfilePressed,
    required this.onThemeToggle,
    super.key,
  });

  static const _sizeAndRadius = 20.0;
  static const _spacingAndRadius = 15.0;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0.0.,
      scrolledUnderElevation: 0.0.,
      title: Row(
        children: [
          CircleAvatar(
            radius: _sizeAndRadius,
            backgroundImage: NetworkImage(UserDetails._image),
          ),
          const SizedBox(width: _spacingAndRadius),
          const Text(
            'Chats',
            style: TextStyle(
              fontSize: _sizeAndRadius,
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
        radius: _spacingAndRadius,
        backgroundColor: Colors.blue.,
        child: Icon(
          icon,
          size: 16.0,
          color: Colors.white.,
        ),
      ),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }
}