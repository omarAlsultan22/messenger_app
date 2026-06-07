import 'dart:ui';


class UserStatus {
  DateTime? lastSeen;
  String? bgImage;
  bool? isOnline;
  bool? isTyping;
  Color? bgColor;

  UserStatus({
    this.lastSeen,
    this.bgImage,
    this.isOnline,
    this.isTyping,
    this.bgColor
  });

  UserStatus copyWith({
    DateTime? lastSeen,
    String? bgImage,
    bool? isOnline,
    bool? isTyping,
    Color? bgColor,
  }) {
    return UserStatus(
      lastSeen: lastSeen ?? this.lastSeen,
      bgImage: bgImage ?? this.bgImage,
      isOnline: isOnline ?? this.isOnline,
      isTyping: isTyping ?? this.isTyping,
      bgColor: bgColor ?? this.bgColor,
    );
  }
}