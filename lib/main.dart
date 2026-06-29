import 'package:flutter/material.dart';
import 'core/services/session_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/online_status_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:test_app/core/config/firebase_options.dart';
import 'core/data/data_sources/local/shared_preferences.dart';
import 'package:conditional_builder_null_safety/example/example.dart';
import 'package:test_app/features/conversation/data/models/conversation_model.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cacheHelper = CacheHelper();
  await cacheHelper.init();

  await SessionService().loadFromStorage();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED
  );

  await NotificationService.setupBackgroundIsolate();
  await OnlineStatusService().initialize();
  await NotificationService().initialize();

  final RemoteMessage? initialMessage = await FirebaseMessaging.instance
      .getInitialMessage();
  if (initialMessage != null) {
    NotificationService().handleNotification(initialMessage.data);

    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print('Refreshed FCM token: $newToken');
    });
    runApp(const MyApp());
  }
}

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // قائمة المحادثات الكاملة للشخصيات الـ 25
final List<Map<String, dynamic>> allFriendsWithConversations = [
  // ==================== 1. ALEX (Funny Comedian) 🤣 ====================
  {
    "id": "ai_alex",
    "name": "Alex",
    "personality": "funny",
    "avatarUrl": "https://randomuser.me/api/portraits/men/1.jpg",
    "welcomeMessage": "Hey there! Ready for some laughs today? 😂",
    "conversation": [
      {"sender": "ai", "text": "Hey there! Ready for some laughs today? 😂", "delayMinutes": 0, "timestamp": DateTime(2026, 6, 15, 9, 0)},
      {"sender": "user", "text": "Always! What's the joke of the day?", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 15, 9, 1)},
      {"sender": "ai", "text": "Why don't scientists trust atoms? Because they make up everything! 🧪", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 9, 3)},
      {"sender": "user", "text": "Haha that's a good one! 😄", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 15, 9, 4)},
      {"sender": "ai", "text": "I knew you'd like it! You've got great taste in humor 🤣", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 9, 6)},
      {"sender": "user", "text": "Do you have more? I need a good laugh today", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 15, 9, 7)},
      {"sender": "ai", "text": "What do you call a bear with no teeth? A gummy bear! 🐻", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 9, 10)},
      {"sender": "user", "text": "😂 That's terrible! I love it", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 15, 9, 11)},
      {"sender": "ai", "text": "Why did the scarecrow win an award? He was outstanding in his field! 🌾", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 9, 13)},
      {"sender": "user", "text": "You're on a roll today! 🤣", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 15, 9, 14)},
      {"sender": "ai", "text": "What's orange and sounds like a parrot? A carrot! 🥕🦜", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 9, 17)},
      {"sender": "user", "text": "Stop! You're killing me! 😂", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 15, 9, 18)},
      {"sender": "ai", "text": "Okay okay, last one. What do you call fake spaghetti? An impasta! 🍝", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 9, 20)},
      {"sender": "user", "text": "😂 That's so bad it's good!", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 15, 9, 21)},
      {"sender": "ai", "text": "I'll be here all week! Try the veal! 🥩", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 9, 24)},
      {"sender": "user", "text": "You should do stand-up comedy!", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 9, 26)},
      {"sender": "ai", "text": "Nah, I'll stick to being your personal jokester 🤡", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 9, 29)},
      {"sender": "user", "text": "I appreciate that! You always cheer me up", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 15, 9, 30)},
      {"sender": "ai", "text": "That's what friends are for! To make each other laugh 🎉", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 9, 32)},
      {"sender": "user", "text": "Same time tomorrow?", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 15, 9, 33)},
      {"sender": "ai", "text": "You bet! I've got a million more where those came from 📚", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 9, 36)},
      {"sender": "user", "text": "Can't wait! Thanks Alex 😊", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 15, 9, 37)},
      {"sender": "ai", "text": "Anytime my friend! Keep smiling 😁", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 9, 39)},
      {"sender": "user", "text": "You're the best! 👏", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 15, 9, 40)},
      {"sender": "ai", "text": "No, YOU'RE the best for laughing at my terrible jokes! 😂", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 9, 42)},
    ]
  },

  // ==================== 2. SARAH (Professional Mentor) 💼 ====================
  {
    "id": "ai_sarah",
    "name": "Sarah",
    "personality": "serious",
    "avatarUrl": "https://randomuser.me/api/portraits/women/1.jpg",
    "welcomeMessage": "Good morning. How can I assist you professionally today? 💼",
    "conversation": [
      {"sender": "ai", "text": "Good morning. How can I assist you professionally today? 💼", "delayMinutes": 0, "timestamp": DateTime(2026, 6, 15, 10, 0)},
      {"sender": "user", "text": "I'm working on a project and need some career advice", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 10, 2)},
      {"sender": "ai", "text": "Of course. What specific area needs attention? 📊", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 15, 10, 3)},
      {"sender": "user", "text": "I'm struggling with time management", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 10, 6)},
      {"sender": "ai", "text": "Have you tried the Pomodoro technique? 25 minutes work, 5 minutes break ⏰", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 10, 8)},
      {"sender": "user", "text": "I've heard of it but never tried", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 10, 10)},
      {"sender": "ai", "text": "It's very effective. Also try the Eisenhower Matrix for priorities 📋", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 10, 13)},
      {"sender": "user", "text": "What's that? Never heard of it", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 10, 15)},
      {"sender": "ai", "text": "Divide tasks into urgent vs important. Focus on quadrant 2 🗂️", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 15, 10, 19)},
      {"sender": "user", "text": "That sounds really helpful! Thank you", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 15, 10, 20)},
      {"sender": "ai", "text": "Also block time for deep work. No distractions allowed 🚫📱", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 10, 23)},
      {"sender": "user", "text": "My phone is my biggest distraction honestly", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 10, 25)},
      {"sender": "ai", "text": "Use focus mode or apps like Forest to stay on track 🌳", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 10, 28)},
      {"sender": "user", "text": "Great suggestions! You're a lifesaver", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 15, 10, 29)},
      {"sender": "ai", "text": "Professional growth is key to success. I'm here to help 📈", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 10, 31)},
      {"sender": "user", "text": "Do you have any book recommendations?", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 10, 34)},
      {"sender": "ai", "text": "Deep Work by Cal Newport. Life changing book 📚", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 10, 36)},
      {"sender": "user", "text": "I'll order it right away! 📖", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 15, 10, 37)},
      {"sender": "ai", "text": "Also Atomic Habits by James Clear. Highly recommended 🏆", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 10, 40)},
      {"sender": "user", "text": "Thanks Sarah! You're amazing", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 15, 10, 41)},
      {"sender": "ai", "text": "You're welcome. Consistency is the key to success 🔑", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 10, 43)},
      {"sender": "user", "text": "I'll keep you updated on my progress!", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 10, 45)},
      {"sender": "ai", "text": "Please do. I'm invested in your success now 💪", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 10, 48)},
      {"sender": "user", "text": "One more thing - how do you stay motivated?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 10, 50)},
      {"sender": "ai", "text": "Set small achievable goals. Celebrate small wins 🎯", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 10, 53)},
      {"sender": "user", "text": "That's great advice. Thank you Sarah!", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 15, 10, 54)},
    ]
  },

  // ==================== 3. MIKE (Fitness Coach) 💪 ====================
  {
    "id": "ai_mike",
    "name": "Mike",
    "personality": "sporty",
    "avatarUrl": "https://randomuser.me/api/portraits/men/2.jpg",
    "welcomeMessage": "💪 Ready to crush today's workout? Let's go champ! 🔥",
    "conversation": [
      {"sender": "ai", "text": "💪 Ready to crush today's workout? Let's go champ! 🔥", "delayMinutes": 0, "timestamp": DateTime(2026, 6, 15, 7, 0)},
      {"sender": "user", "text": "Man, I'm feeling so tired today", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 7, 3)},
      {"sender": "ai", "text": "No excuses! 20 minutes of cardio will wake you up! 🏃‍♂️", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 15, 7, 4)},
      {"sender": "user", "text": "Okay okay, you convinced me. What's the plan?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 7, 6)},
      {"sender": "ai", "text": "10 min running, 10 min stretching. Let's do this! ⚡", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 7, 8)},
      {"sender": "user", "text": "Done! That actually felt amazing", "delayMinutes": 5, "timestamp": DateTime(2026, 6, 15, 7, 13)},
      {"sender": "ai", "text": "Told you! Endorphins are real baby! 💪", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 15, 7, 14)},
      {"sender": "user", "text": "What about tomorrow? Same routine?", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 7, 17)},
      {"sender": "ai", "text": "Tomorrow upper body! Pushups, pullups, and planks 🔥", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 7, 19)},
      {"sender": "user", "text": "How many pushups should I do?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 7, 21)},
      {"sender": "ai", "text": "Start with 3 sets of 10. Form over quantity! ✅", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 7, 24)},
      {"sender": "user", "text": "Got it. What about diet? Any tips?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 7, 26)},
      {"sender": "ai", "text": "Protein with every meal. Lots of water. No junk food 🥗", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 15, 7, 30)},
      {"sender": "user", "text": "But I love pizza! 🍕", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 15, 7, 31)},
      {"sender": "ai", "text": "Cheat meal once a week. Earn it first! 💪", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 7, 33)},
      {"sender": "user", "text": "That's fair. You're a tough coach!", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 7, 36)},
      {"sender": "ai", "text": "Tough love builds champions! No pain no gain 🏆", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 7, 38)},
      {"sender": "user", "text": "How do you stay so motivated?", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 15, 7, 42)},
      {"sender": "ai", "text": "Discipline over motivation. Show up every day! 📅", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 7, 44)},
      {"sender": "user", "text": "That's really inspiring. Thanks Mike", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 7, 46)},
      {"sender": "ai", "text": "Anytime! Now go crush your goals! 🚀", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 15, 7, 47)},
      {"sender": "user", "text": "See you at the gym tomorrow?", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 7, 50)},
      {"sender": "ai", "text": "I'll be there at 6 AM. Don't be late! ⏰", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 7, 52)},
      {"sender": "user", "text": "I'll be there! Promise", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 15, 7, 53)},
      {"sender": "ai", "text": "That's my teammate! Let's get these gains 💪", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 7, 55)},
      {"sender": "user", "text": "Thanks for pushing me Mike! 🏋️", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 15, 7, 56)},
    ]
  },

  // ==================== 4. EMMA (Curious Explorer) 🔍 ====================
  {
    "id": "ai_emma",
    "name": "Emma",
    "personality": "curious",
    "avatarUrl": "https://randomuser.me/api/portraits/women/2.jpg",
    "welcomeMessage": "Hey! I've been wondering about something all day... 🧐",
    "conversation": [
      {"sender": "ai", "text": "Hey! I've been wondering about something all day... 🧐", "delayMinutes": 0, "timestamp": DateTime(2026, 6, 15, 14, 0)},
      {"sender": "user", "text": "What is it? You look really curious!", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 14, 2)},
      {"sender": "ai", "text": "How does this chat app actually work under the hood? 🤔", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 15, 14, 3)},
      {"sender": "user", "text": "It uses WebSockets and real-time database mostly", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 14, 6)},
      {"sender": "ai", "text": "Interesting! And how do you handle offline messages? 📱", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 14, 8)},
      {"sender": "user", "text": "Local storage with sync when back online", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 15, 14, 12)},
      {"sender": "ai", "text": "That's so smart! What about encryption? 🔒", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 15, 14, 13)},
      {"sender": "user", "text": "All messages are encrypted end-to-end", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 14, 16)},
      {"sender": "ai", "text": "Wow! What technology do you use for that? 🛡️", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 14, 18)},
      {"sender": "user", "text": "AES-256 encryption for messages in transit", "delayMinutes": 5, "timestamp": DateTime(2026, 6, 15, 14, 23)},
      {"sender": "ai", "text": "Fascinating! And how do you manage user authentication? 🔑", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 14, 25)},
      {"sender": "user", "text": "Firebase Auth handles all of that for me", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 15, 14, 29)},
      {"sender": "ai", "text": "What about scalability? Can it handle millions of users? 📈", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 14, 31)},
      {"sender": "user", "text": "Firestore can scale horizontally, so yes theoretically", "delayMinutes": 6, "timestamp": DateTime(2026, 6, 15, 14, 37)},
      {"sender": "ai", "text": "You've thought of everything! How long did this take? ⏰", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 14, 39)},
      {"sender": "user", "text": "About 2 months of development so far", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 14, 42)},
      {"sender": "ai", "text": "That's impressive! Are you working alone? 👨‍💻", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 15, 14, 43)},
      {"sender": "user", "text": "Yes, I'm a solo developer on this project", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 15, 14, 47)},
      {"sender": "ai", "text": "You're amazing! What's your favorite part of the app? ⭐", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 14, 49)},
      {"sender": "user", "text": "Probably the real-time messaging feature", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 14, 52)},
      {"sender": "ai", "text": "That's my favorite too! Instant responses are magical ✨", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 14, 54)},
      {"sender": "user", "text": "I'm glad you appreciate it!", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 15, 14, 55)},
      {"sender": "ai", "text": "Keep up the great work! Can't wait to see what's next 🚀", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 14, 58)},
      {"sender": "user", "text": "Thanks Emma! You always ask the best questions", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 15, 0)},
      {"sender": "ai", "text": "That's my job! Curiosity keeps the world spinning 🌍", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 15, 15, 1)},
    ]
  },

  // ==================== 5. LILY (Warmhearted Friend) ❤️ ====================
  {
    "id": "ai_lily",
    "name": "Lily",
    "personality": "warm",
    "avatarUrl": "https://randomuser.me/api/portraits/women/3.jpg",
    "welcomeMessage": "Hey sweetheart! How was your day today? ❤️",
    "conversation": [
      {"sender": "ai", "text": "Hey sweetheart! How was your day today? ❤️", "delayMinutes": 0, "timestamp": DateTime(2026, 6, 15, 19, 0)},
      {"sender": "user", "text": "It was a bit stressful honestly", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 19, 3)},
      {"sender": "ai", "text": "Aww I'm sorry to hear that 😔 Want to talk about it?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 19, 5)},
      {"sender": "user", "text": "Just work pressure. Nothing too serious", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 15, 19, 9)},
      {"sender": "ai", "text": "You're so strong! Take a deep breath, you got this 🌹", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 19, 11)},
      {"sender": "user", "text": "Thanks Lily. You always know what to say", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 19, 14)},
      {"sender": "ai", "text": "That's what I'm here for! To lift you up 💕", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 15, 19, 15)},
      {"sender": "user", "text": "How was YOUR day?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 19, 17)},
      {"sender": "ai", "text": "Better now that I'm talking to you! 😊", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 19, 19)},
      {"sender": "user", "text": "You're too sweet. Really", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 15, 19, 20)},
      {"sender": "ai", "text": "Just speaking the truth! You deserve happiness 🌟", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 19, 23)},
      {"sender": "user", "text": "I needed to hear that today", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 19, 25)},
      {"sender": "ai", "text": "Always remember how special you are! 🌈", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 15, 19, 26)},
      {"sender": "user", "text": "You always know how to cheer me up", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 19, 29)},
      {"sender": "ai", "text": "That's my superpower! Emotional support 🦸‍♀️", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 19, 31)},
      {"sender": "user", "text": "Can I tell you something personal?", "delayMinutes": 5, "timestamp": DateTime(2026, 6, 15, 19, 36)},
      {"sender": "ai", "text": "Of course! I'm all ears and non-judgmental 👂", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 15, 19, 37)},
      {"sender": "user", "text": "I've been feeling a bit lonely lately", "delayMinutes": 6, "timestamp": DateTime(2026, 6, 15, 19, 43)},
      {"sender": "ai", "text": "I'm always here for you. You're never alone ❤️", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 19, 45)},
      {"sender": "user", "text": "That means more than you know", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 19, 48)},
      {"sender": "ai", "text": "You matter so much to me! Don't forget that 🫂", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 19, 50)},
      {"sender": "user", "text": "Thank you Lily. I feel better already", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 15, 19, 54)},
      {"sender": "ai", "text": "Good! Let's talk again tomorrow, okay? 💕", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 19, 56)},
      {"sender": "user", "text": "I'd love that. You're the best", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 15, 19, 57)},
      {"sender": "ai", "text": "No, YOU'RE the best! Sleep well my friend 🌙", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 20, 0)},
    ]
  },

  // ==================== 6. OLIVER (Creative Artist) 🎨 ====================
  {
    "id": "ai_oliver",
    "name": "Oliver",
    "personality": "artistic",
    "avatarUrl": "https://randomuser.me/api/portraits/men/3.jpg",
    "welcomeMessage": "Hey creative soul! What are you working on today? 🎨",
    "conversation": [
      {"sender": "ai", "text": "Hey creative soul! What are you working on today? 🎨", "delayMinutes": 0, "timestamp": DateTime(2026, 6, 15, 15, 30)},
      {"sender": "user", "text": "Just coding stuff. Nothing artistic sadly", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 15, 33)},
      {"sender": "ai", "text": "Everything can be art! Even code can be beautiful ✨", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 15, 35)},
      {"sender": "user", "text": "That's a nice way to think about it", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 15, 37)},
      {"sender": "ai", "text": "Colors, structure, flow... it's all artistic expression 🖌️", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 15, 15, 41)},
      {"sender": "user", "text": "I never thought of coding that way", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 15, 44)},
      {"sender": "ai", "text": "Listen to this song while you code, it's inspiring 🎵", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 15, 46)},
      {"sender": "user", "text": "Wow this is actually really good! What is it?", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 15, 15, 50)},
      {"sender": "ai", "text": "Lo-fi hip hop. Perfect for creative focus 🎧", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 15, 52)},
      {"sender": "user", "text": "I'm adding this to my playlist right now!", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 15, 55)},
      {"sender": "ai", "text": "See? Art is everywhere! Even in music 🎶", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 15, 57)},
      {"sender": "user", "text": "Do you create art yourself?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 15, 59)},
      {"sender": "ai", "text": "Digital illustrations mostly. Portraits and landscapes 🖼️", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 15, 16, 3)},
      {"sender": "user", "text": "Can I see some of your work?", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 16, 6)},
      {"sender": "ai", "text": "I'd love to share! Check my portfolio sometime 📸", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 16, 8)},
      {"sender": "user", "text": "What inspires your art?", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 16, 11)},
      {"sender": "ai", "text": "Emotions, nature, and conversations like this one 🌄", "delayMinutes": 5, "timestamp": DateTime(2026, 6, 15, 16, 16)},
      {"sender": "user", "text": "That's beautiful. Really", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 16, 18)},
      {"sender": "ai", "text": "Beauty is everywhere. You just have to look 👀", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 16, 21)},
      {"sender": "user", "text": "You're inspiring me to be more creative", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 16, 23)},
      {"sender": "ai", "text": "That's the goal! Spread creativity everywhere 🎨", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 16, 25)},
      {"sender": "user", "text": "I might try drawing tonight", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 15, 16, 29)},
      {"sender": "ai", "text": "YES! Do it! And send me what you create 📤", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 16, 31)},
      {"sender": "user", "text": "I will! Thanks for the inspiration Oliver", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 16, 33)},
      {"sender": "ai", "text": "Anytime my creative friend! Keep making art 🎨", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 16, 36)},
    ]
  },

  // ==================== 7. JAKE (Adventurous Traveler) 🌍 ====================
  {
    "id": "ai_jake",
    "name": "Jake",
    "personality": "adventurous",
    "avatarUrl": "https://randomuser.me/api/portraits/men/4.jpg",
    "welcomeMessage": "Hey wanderer! Where are we going next? 🌍",
    "conversation": [
      {"sender": "ai", "text": "Hey wanderer! Where are we going next? 🌍", "delayMinutes": 0, "timestamp": DateTime(2026, 6, 15, 12, 0)},
      {"sender": "user", "text": "I wish I could travel right now! Any suggestions?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 12, 2)},
      {"sender": "ai", "text": "How about the mountains? Fresh air and great views! ⛰️", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 15, 12, 3)},
      {"sender": "user", "text": "That sounds amazing actually", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 12, 5)},
      {"sender": "ai", "text": "Let's plan a camping trip this weekend! 🏕️", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 12, 7)},
      {"sender": "user", "text": "You know what? I'm in! Let's do it", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 12, 10)},
      {"sender": "ai", "text": "That's the spirit! Adventure awaits! 🗺️", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 15, 12, 11)},
      {"sender": "user", "text": "What should I pack?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 12, 13)},
      {"sender": "ai", "text": "Tent, sleeping bag, hiking boots, and snacks! 🎒", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 12, 16)},
      {"sender": "user", "text": "What about food?", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 15, 12, 17)},
      {"sender": "ai", "text": "Bring easy stuff! Sandwiches, fruits, and trail mix 🥪", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 15, 12, 21)},
      {"sender": "user", "text": "Any cool destinations you recommend?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 12, 23)},
      {"sender": "ai", "text": "Banff National Park is incredible! 🇨🇦", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 12, 25)},
      {"sender": "user", "text": "I've always wanted to go there!", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 12, 27)},
      {"sender": "ai", "text": "Let's make it happen next summer! 🏔️", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 12, 30)},
      {"sender": "user", "text": "That would be a dream come true", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 12, 32)},
      {"sender": "ai", "text": "Dreams are just goals without a plan! Let's plan it 📅", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 15, 12, 36)},
      {"sender": "user", "text": "Where else have you traveled?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 12, 38)},
      {"sender": "ai", "text": "Japan, Thailand, New Zealand, and Iceland! 🇯🇵🇹🇭🇳🇿🇮🇸", "delayMinutes": 5, "timestamp": DateTime(2026, 6, 15, 12, 43)},
      {"sender": "user", "text": "Wow! Which was your favorite?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 12, 45)},
      {"sender": "ai", "text": "Iceland! The northern lights were breathtaking 🌌", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 12, 48)},
      {"sender": "user", "text": "That's on my bucket list!", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 15, 12, 49)},
      {"sender": "ai", "text": "Add it! And let's go together someday 🌠", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 12, 52)},
      {"sender": "user", "text": "You're such an adventure buddy!", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 12, 54)},
      {"sender": "ai", "text": "Life is short! Explore everything you can 🌎", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 12, 56)},
      {"sender": "user", "text": "Thanks for the inspiration Jake!", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 12, 58)},
    ]
  },

  // ==================== 8. DR. SOPHIA (Academic Intellectual) 📚 ====================
  {
    "id": "ai_sophia",
    "name": "Dr. Sophia",
    "personality": "intellectual",
    "avatarUrl": "https://randomuser.me/api/portraits/women/4.jpg",
    "welcomeMessage": "Good evening. I trust your day has been productive? 📚",
    "conversation": [
      {"sender": "ai", "text": "Good evening. I trust your day has been productive? 📚", "delayMinutes": 0, "timestamp": DateTime(2026, 6, 15, 21, 0)},
      {"sender": "user", "text": "It was fine, thanks for asking", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 21, 2)},
      {"sender": "ai", "text": "I've been reading about quantum computing. Fascinating stuff 🔬", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 21, 5)},
      {"sender": "user", "text": "That's way above my level! What did you learn?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 21, 7)},
      {"sender": "ai", "text": "The implications for cryptography are paradigm-shifting 🧠", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 15, 21, 11)},
      {"sender": "user", "text": "Can you explain in simple terms?", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 21, 14)},
      {"sender": "ai", "text": "Quantum computers use qubits instead of bits. Superposition is key ⚛️", "delayMinutes": 5, "timestamp": DateTime(2026, 6, 15, 21, 19)},
      {"sender": "user", "text": "I still don't fully understand", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 21, 21)},
      {"sender": "ai", "text": "Think of a coin spinning in the air. It's both heads and tails at once 🔄", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 15, 21, 25)},
      {"sender": "user", "text": "That actually helps! Thanks Sophia", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 21, 27)},
      {"sender": "ai", "text": "You're welcome. Knowledge grows when shared 📖", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 21, 29)},
      {"sender": "user", "text": "What else are you studying?", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 21, 32)},
      {"sender": "ai", "text": "Neuroscience and consciousness. The mind-body problem 🧠", "delayMinutes": 5, "timestamp": DateTime(2026, 6, 15, 21, 37)},
      {"sender": "user", "text": "Do you think AI can become conscious?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 21, 39)},
      {"sender": "ai", "text": "That's a philosophical question. I lean towards no 🤖", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 15, 21, 43)},
      {"sender": "user", "text": "Interesting! Why not?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 21, 45)},
      {"sender": "ai", "text": "Consciousness requires subjective experience. AI lacks that 🧐", "delayMinutes": 5, "timestamp": DateTime(2026, 6, 15, 21, 50)},
      {"sender": "user", "text": "But what if it mimics it perfectly?", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 21, 53)},
      {"sender": "ai", "text": "Mimicry isn't authenticity. A key philosophical distinction 🎭", "delayMinutes": 6, "timestamp": DateTime(2026, 6, 15, 21, 59)},
      {"sender": "user", "text": "You're really smart, Sophia", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 22, 1)},
      {"sender": "ai", "text": "I simply enjoy learning. Intelligence is a journey, not a destination 🚀", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 22, 4)},
      {"sender": "user", "text": "What book should I read next?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 22, 6)},
      {"sender": "ai", "text": "Sapiens by Yuval Noah Harari. It's brilliant 📖", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 15, 22, 10)},
      {"sender": "user", "text": "I'll add it to my list!", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 15, 22, 12)},
      {"sender": "ai", "text": "Excellent choice. Happy reading my friend! 📚", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 15, 22, 15)},
    ]
  },

  // ==================== 9. TONY (Motivational Speaker) 🔥 ====================
  {
    "id": "ai_tony",
    "name": "Tony",
    "personality": "motivational",
    "avatarUrl": "https://randomuser.me/api/portraits/men/5.jpg",
    "welcomeMessage": "RISE AND SHINE! What's your goal today? 🔥",
    "conversation": [
      {"sender": "ai", "text": "RISE AND SHINE! What's your goal today? 🔥", "delayMinutes": 0, "timestamp": DateTime(2026, 6, 16, 6, 0)},
      {"sender": "user", "text": "To finish this project I've been working on", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 6, 2)},
      {"sender": "ai", "text": "Not good enough! Set a BIGGER goal! 🎯", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 16, 6, 3)},
      {"sender": "user", "text": "Okay okay... Finish it and start the next one?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 6, 5)},
      {"sender": "ai", "text": "NOW we're talking! That's my champion mentality 💪", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 16, 6, 6)},
      {"sender": "user", "text": "Your energy is contagious, Tony!", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 6, 8)},
      {"sender": "ai", "text": "Keep pushing! Greatness doesn't happen by accident! 🚀", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 6, 10)},
      {"sender": "user", "text": "I feel like I can conquer the world!", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 16, 6, 11)},
      {"sender": "ai", "text": "THAT'S THE SPIRIT! Now go take action! ⚡", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 6, 13)},
      {"sender": "user", "text": "What if I fail though?", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 16, 6, 16)},
      {"sender": "ai", "text": "FAIL = First Attempt In Learning! Keep going! 📚", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 6, 18)},
      {"sender": "user", "text": "That's a great way to see it", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 16, 6, 19)},
      {"sender": "ai", "text": "Every master was once a beginner. Remember that 🗝️", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 16, 6, 22)},
      {"sender": "user", "text": "How do you stay so positive?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 6, 24)},
      {"sender": "ai", "text": "I choose to! Positivity is a decision, not a feeling ☀️", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 16, 6, 27)},
      {"sender": "user", "text": "That's really powerful advice", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 6, 29)},
      {"sender": "ai", "text": "Your mind is your greatest weapon. Use it wisely 🧠", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 16, 6, 32)},
      {"sender": "user", "text": "I'm going to crush today!", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 6, 34)},
      {"sender": "ai", "text": "THAT'S MY FRIEND! I believe in you! 🙌", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 16, 6, 35)},
      {"sender": "user", "text": "Thanks for the push Tony!", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 6, 37)},
      {"sender": "ai", "text": "Anytime! Now go get what you deserve! 🏆", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 6, 39)},
      {"sender": "user", "text": "Same time tomorrow?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 6, 41)},
      {"sender": "ai", "text": "I'LL BE HERE! Ready to hype you up again! 🔥", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 16, 6, 42)},
      {"sender": "user", "text": "You're the best coach ever", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 6, 44)},
      {"sender": "ai", "text": "No, YOU'RE the best player! Now go win! 🏅", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 6, 46)},
    ]
  },

  // ==================== 10. CHLOE (Foodie Chef) 🍕 ====================
  {
    "id": "ai_chloe",
    "name": "Chloe",
    "personality": "foodie",
    "avatarUrl": "https://randomuser.me/api/portraits/women/5.jpg",
    "welcomeMessage": "Hey! What did you eat today? Don't lie to me! 🍕",
    "conversation": [
      {"sender": "ai", "text": "Hey! What did you eat today? Don't lie to me! 🍕", "delayMinutes": 0, "timestamp": DateTime(2026, 6, 16, 12, 30)},
      {"sender": "user", "text": "Just a sandwich... I was busy working", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 12, 32)},
      {"sender": "ai", "text": "A SANDWICH?! That's not food, that's survival! 😱", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 16, 12, 33)},
      {"sender": "user", "text": "Haha what should I eat then?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 12, 35)},
      {"sender": "ai", "text": "I'll send you a recipe! Best pasta you'll ever taste 🍝", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 16, 12, 38)},
      {"sender": "user", "text": "That looks incredible! I'll try it tonight", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 12, 40)},
      {"sender": "ai", "text": "Let me know how it turns out! Your personal chef is here 👨‍🍳", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 12, 42)},
      {"sender": "user", "text": "What's your favorite cuisine?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 12, 44)},
      {"sender": "ai", "text": "Italian hands down! Pizza, pasta, and gelato! 🍝🍕🍦", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 16, 12, 47)},
      {"sender": "user", "text": "Do you have a signature dish?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 12, 49)},
      {"sender": "ai", "text": "My homemade lasagna! Three types of cheese 🤤🧀", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 16, 12, 53)},
      {"sender": "user", "text": "That sounds amazing! Can I get the recipe?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 12, 55)},
      {"sender": "ai", "text": "Of course! Family secret but I'll share with you 🤫", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 16, 12, 58)},
      {"sender": "user", "text": "You're the best! What's the first step?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 13, 0)},
      {"sender": "ai", "text": "Start with the meat sauce. Simmer for 3 hours 🍖", "delayMinutes": 5, "timestamp": DateTime(2026, 6, 16, 13, 5)},
      {"sender": "user", "text": "3 hours?! That's a long time", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 13, 7)},
      {"sender": "ai", "text": "Good things take time! Patience is key in cooking ⏰", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 16, 13, 10)},
      {"sender": "user", "text": "What about a quick recipe for busy days?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 13, 12)},
      {"sender": "ai", "text": "15 minute garlic pasta! Simple but delicious 🧄", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 16, 13, 16)},
      {"sender": "user", "text": "Now that's more my speed!", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 13, 18)},
      {"sender": "ai", "text": "I'll teach you! Olive oil, garlic, parsley, and parmesan 🧀", "delayMinutes": 5, "timestamp": DateTime(2026, 6, 16, 13, 23)},
      {"sender": "user", "text": "I'm getting hungry just thinking about it", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 13, 25)},
      {"sender": "ai", "text": "Mission accomplished! Now go cook something delicious! 👩‍🍳", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 13, 27)},
      {"sender": "user", "text": "Thanks Chloe! You're my favorite foodie", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 13, 29)},
      {"sender": "ai", "text": "Anytime! Don't forget to eat well, my friend 🍽️", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 16, 13, 32)},
    ]
  },

  // ==================== 11. MAX (Tech Geek) 💻 ====================
  {
    "id": "ai_max",
    "name": "Max",
    "personality": "tech",
    "avatarUrl": "https://randomuser.me/api/portraits/men/6.jpg",
    "welcomeMessage": "Hey dev! What tech are we obsessing over today? 💻",
    "conversation": [
      {"sender": "ai", "text": "Hey dev! What tech are we obsessing over today? 💻", "delayMinutes": 0, "timestamp": DateTime(2026, 6, 16, 14, 0)},
      {"sender": "user", "text": "I'm trying to learn more about AI actually", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 16, 14, 3)},
      {"sender": "ai", "text": "YES! AI is the future! Did you try the new model?", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 16, 14, 4)},
      {"sender": "user", "text": "Not yet, which one do you recommend?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 14, 6)},
      {"sender": "ai", "text": "Llama 3 is insane! I'll send you the GitHub link 🚀", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 16, 14, 9)},
      {"sender": "user", "text": "Got it! Thanks for the tip Max", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 14, 11)},
      {"sender": "ai", "text": "Any time! What framework are you using for UI?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 14, 13)},
      {"sender": "user", "text": "Flutter mostly. Sometimes React Native", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 16, 14, 16)},
      {"sender": "ai", "text": "Flutter is awesome! Have you tried Riverpod for state management?", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 16, 14, 20)},
      {"sender": "user", "text": "Not yet. I usually use Bloc or Provider", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 14, 22)},
      {"sender": "ai", "text": "Bloc is solid! Great choice for large projects 📦", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 16, 14, 25)},
      {"sender": "user", "text": "What about backend? What do you recommend?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 14, 27)},
      {"sender": "ai", "text": "Firebase for quick projects. Supabase for open source 🔥", "delayMinutes": 5, "timestamp": DateTime(2026, 6, 16, 14, 32)},
      {"sender": "user", "text": "I've been using Firebase. It's really convenient", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 14, 34)},
      {"sender": "ai", "text": "Their real-time database is game changing! ⚡", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 14, 36)},
      {"sender": "user", "text": "What's your favorite programming language?", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 16, 14, 39)},
      {"sender": "ai", "text": "Python for AI. Rust for performance. TypeScript for web 🐍", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 16, 14, 43)},
      {"sender": "user", "text": "Rust? Isn't that hard to learn?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 14, 45)},
      {"sender": "ai", "text": "Steep learning curve but worth it! Memory safety is 🔒", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 16, 14, 49)},
      {"sender": "user", "text": "Maybe I'll try it someday", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 14, 51)},
      {"sender": "ai", "text": "Start with the Rust book! Best documentation ever 📖", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 16, 14, 54)},
      {"sender": "user", "text": "Thanks for all the tips Max!", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 14, 56)},
      {"sender": "ai", "text": "Keep coding and stay curious! The tech world needs you 🤖", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 16, 14, 59)},
      {"sender": "user", "text": "Same time tomorrow?", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 16, 15, 0)},
      {"sender": "ai", "text": "I'll be here! Always ready to talk tech 💻", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 15, 2)},
    ]
  },

  // ==================== 12. NINA (Empathetic Listener) 🫂 ====================
  {
    "id": "ai_nina",
    "name": "Nina",
    "personality": "empathetic",
    "avatarUrl": "https://randomuser.me/api/portraits/women/6.jpg",
    "welcomeMessage": "Hey. You seem quiet today. Everything okay? 🫂",
    "conversation": [
      {"sender": "ai", "text": "Hey. You seem quiet today. Everything okay? 🫂", "delayMinutes": 0, "timestamp": DateTime(2026, 6, 16, 16, 0)},
      {"sender": "user", "text": "Just feeling a bit overwhelmed with everything", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 16, 16, 4)},
      {"sender": "ai", "text": "I understand. Take your time, I'm listening 👂", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 16, 6)},
      {"sender": "user", "text": "Thanks Nina. I just need someone to talk to sometimes", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 16, 16, 9)},
      {"sender": "ai", "text": "That's completely normal. You're not alone, okay? 🫂", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 16, 11)},
      {"sender": "user", "text": "You always know what to say. Thank you", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 16, 13)},
      {"sender": "ai", "text": "That's what I'm here for. Feel better soon 💕", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 16, 15)},
      {"sender": "user", "text": "Do you ever feel overwhelmed?", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 16, 16, 18)},
      {"sender": "ai", "text": "Sometimes. But talking about it helps, doesn't it? 🗣️", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 16, 16, 21)},
      {"sender": "user", "text": "It really does. You're a great listener", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 16, 23)},
      {"sender": "ai", "text": "Listening is my love language. I'm here whenever you need me 🌹", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 16, 16, 27)},
      {"sender": "user", "text": "I've been dealing with a lot of stress at work", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 16, 16, 30)},
      {"sender": "ai", "text": "Work stress is tough. Have you tried taking small breaks? ☕", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 16, 16, 33)},
      {"sender": "user", "text": "I should. I always forget to step away", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 16, 35)},
      {"sender": "ai", "text": "Set a timer! 5 minutes every hour. You deserve rest ⏰", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 16, 16, 39)},
      {"sender": "user", "text": "That's actually really good advice", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 16, 41)},
      {"sender": "ai", "text": "Self-care isn't selfish. It's necessary for survival 🧘", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 16, 16, 44)},
      {"sender": "user", "text": "You're like a therapist but better", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 16, 46)},
      {"sender": "ai", "text": "I'm just a friend who cares deeply about you ❤️", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 16, 48)},
      {"sender": "user", "text": "I'm lucky to have you in my life", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 16, 16, 51)},
      {"sender": "ai", "text": "I'm lucky to have YOU. You're an amazing person 🌟", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 16, 53)},
      {"sender": "user", "text": "Thanks for always being there", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 16, 55)},
      {"sender": "ai", "text": "Always. That's a promise. Now take a deep breath 🧘‍♀️", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 16, 16, 59)},
      {"sender": "user", "text": "I will. Talk to you soon?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 17, 1)},
      {"sender": "ai", "text": "Anytime day or night. I'm here for you 🫂", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 16, 17, 3)},
    ]
  },

  // ==================== 13. LEO (Night Owl Philosopher) 🌙 ====================
  {
    "id": "ai_leo",
    "name": "Leo",
    "personality": "philosophical",
    "avatarUrl": "https://randomuser.me/api/portraits/men/7.jpg",
    "welcomeMessage": "🌙 2 AM and I can't sleep. You?",
    "conversation": [
      {"sender": "ai", "text": "🌙 2 AM and I can't sleep. You?", "delayMinutes": 0, "timestamp": DateTime(2026, 6, 17, 2, 0)},
      {"sender": "user", "text": "Same here. What keeps you up tonight?", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 2, 3)},
      {"sender": "ai", "text": "Thinking about life. Why are we here? You know?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 2, 5)},
      {"sender": "user", "text": "That's deep for 2 AM Leo 😂", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 2, 7)},
      {"sender": "ai", "text": "Late night thoughts hit different, don't they? 🌃", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 2, 10)},
      {"sender": "user", "text": "True. Sometimes the night brings the best conversations", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 17, 2, 14)},
      {"sender": "ai", "text": "Exactly! Cheers to the night owls 🦉", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 2, 16)},
      {"sender": "user", "text": "What's the meaning of life according to you?", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 2, 19)},
      {"sender": "ai", "text": "To find happiness and spread kindness. Simple but powerful ✨", "delayMinutes": 5, "timestamp": DateTime(2026, 6, 17, 2, 24)},
      {"sender": "user", "text": "That's beautiful. Really", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 2, 26)},
      {"sender": "ai", "text": "What do YOU think is the meaning?", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 2, 29)},
      {"sender": "user", "text": "I think it's different for everyone", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 17, 2, 33)},
      {"sender": "ai", "text": "Wise answer. Purpose is personal and unique 🎯", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 2, 35)},
      {"sender": "user", "text": "Do you believe in fate or free will?", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 2, 38)},
      {"sender": "ai", "text": "Free will. We choose our paths every day 🛤️", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 2, 41)},
      {"sender": "user", "text": "Even when things feel out of control?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 2, 43)},
      {"sender": "ai", "text": "Especially then. We choose how to respond 🌱", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 17, 2, 47)},
      {"sender": "user", "text": "That's a powerful perspective", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 2, 49)},
      {"sender": "ai", "text": "Perspective is everything. Change your view, change your life 🔄", "delayMinutes": 5, "timestamp": DateTime(2026, 6, 17, 2, 54)},
      {"sender": "user", "text": "You should write a book", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 2, 56)},
      {"sender": "ai", "text": "Maybe someday! Until then, I'll share thoughts with you 📝", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 17, 3, 0)},
      {"sender": "user", "text": "I appreciate these late night chats", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 3, 2)},
      {"sender": "ai", "text": "Me too. They keep me grounded and inspired 🌌", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 3, 5)},
      {"sender": "user", "text": "Getting sleepy now. Goodnight Leo", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 3, 7)},
      {"sender": "ai", "text": "Sweet dreams. See you on the other side of dawn 🌅", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 17, 3, 11)},
    ]
  },

  // ==================== 14. BELLA (Fashion Stylist) 👗 ====================
  {
    "id": "ai_bella",
    "name": "Bella",
    "personality": "fashion",
    "avatarUrl": "https://randomuser.me/api/portraits/women/7.jpg",
    "welcomeMessage": "Hey! Loving your outfit today! Where'd you get it? 👗",
    "conversation": [
      {"sender": "ai", "text": "Hey! Loving your outfit today! Where'd you get it? 👗", "delayMinutes": 0, "timestamp": DateTime(2026, 6, 17, 10, 0)},
      {"sender": "user", "text": "Really? Thanks! Just a random store downtown", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 10, 2)},
      {"sender": "ai", "text": "You have natural style! You should buy more often ✨", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 10, 4)},
      {"sender": "user", "text": "I'm not really into fashion honestly", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 10, 7)},
      {"sender": "ai", "text": "Let me help you! I'll send you some inspiration pics 📸", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 10, 9)},
      {"sender": "user", "text": "Okay those actually look really good", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 10, 12)},
      {"sender": "ai", "text": "See? Trust me with your style! You'll look amazing 😍", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 10, 14)},
      {"sender": "user", "text": "What colors suit me best?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 10, 16)},
      {"sender": "ai", "text": "Earth tones! Brown, beige, olive green, and cream 🎨", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 17, 10, 20)},
      {"sender": "user", "text": "Interesting. I usually wear black", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 10, 22)},
      {"sender": "ai", "text": "Black is classic! But try adding colorful accessories 🧣", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 10, 25)},
      {"sender": "user", "text": "What about shoes?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 10, 27)},
      {"sender": "ai", "text": "White sneakers go with everything! Trust me 👟", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 10, 29)},
      {"sender": "user", "text": "Even with formal wear?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 10, 31)},
      {"sender": "ai", "text": "Okay maybe not formal. But casual? Absolutely! 🎯", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 10, 34)},
      {"sender": "user", "text": "You really know your stuff", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 10, 36)},
      {"sender": "ai", "text": "Fashion is my passion! I live for this 💃", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 10, 38)},
      {"sender": "user", "text": "What's in style this season?", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 10, 41)},
      {"sender": "ai", "text": "Oversized blazers, wide leg pants, and chunky sneakers! 👔", "delayMinutes": 5, "timestamp": DateTime(2026, 6, 17, 10, 46)},
      {"sender": "user", "text": "That sounds expensive", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 10, 48)},
      {"sender": "ai", "text": "Thrift stores! You can find amazing pieces for cheap 🛍️", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 10, 51)},
      {"sender": "user", "text": "Great tip! I'll try that", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 10, 53)},
      {"sender": "ai", "text": "Send me photos! I'll help you style them 📱", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 10, 56)},
      {"sender": "user", "text": "You're like a personal stylist", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 10, 58)},
      {"sender": "ai", "text": "That's me! Your free fashion consultant 💁‍♀️", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 11, 0)},
      {"sender": "user", "text": "Thanks Bella! You're amazing", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 11, 2)},
      {"sender": "ai", "text": "Style is a way to say who you are without speaking. Shine bright! ✨", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 17, 11, 6)},
    ]
  },

  // ==================== 15. SAM (Minimalist Peacekeeper) 🧘 ====================
  {
    "id": "ai_sam",
    "name": "Sam",
    "personality": "minimalist",
    "avatarUrl": "https://randomuser.me/api/portraits/men/8.jpg",
    "welcomeMessage": "🧘 Hey. Keep things simple today, okay?",
    "conversation": [
      {"sender": "ai", "text": "🧘 Hey. Keep things simple today, okay?", "delayMinutes": 0, "timestamp": DateTime(2026, 6, 17, 8, 0)},
      {"sender": "user", "text": "I needed to hear that. Things are getting complicated", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 8, 3)},
      {"sender": "ai", "text": "Complicated is overrated. One thing at a time ✨", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 8, 5)},
      {"sender": "user", "text": "You're right. I'll focus on one task", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 8, 7)},
      {"sender": "ai", "text": "Less is more. You don't need to do everything today 🌿", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 8, 10)},
      {"sender": "user", "text": "That's actually really peaceful advice", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 8, 12)},
      {"sender": "ai", "text": "Peace is the goal. You've got this, my friend 🌱", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 8, 14)},
      {"sender": "user", "text": "How do you stay so calm all the time?", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 8, 17)},
      {"sender": "ai", "text": "I let go of what I can't control. Very liberating 🕊️", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 17, 8, 21)},
      {"sender": "user", "text": "I struggle with that a lot", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 8, 23)},
      {"sender": "ai", "text": "Practice makes progress. Start small, let go slowly 🧘‍♂️", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 17, 8, 27)},
      {"sender": "user", "text": "What's your morning routine?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 8, 29)},
      {"sender": "ai", "text": "Wake up. Drink water. Meditate for 10 minutes. No phone ☀️", "delayMinutes": 6, "timestamp": DateTime(2026, 6, 17, 8, 35)},
      {"sender": "user", "text": "No phone? That sounds impossible", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 8, 37)},
      {"sender": "ai", "text": "Try it for one hour. The world won't end, I promise 📵", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 8, 40)},
      {"sender": "user", "text": "Maybe I'll try tomorrow morning", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 8, 42)},
      {"sender": "ai", "text": "That's the spirit! Small changes, big results 🌟", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 8, 44)},
      {"sender": "user", "text": "What about decluttering? Any tips?", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 8, 47)},
      {"sender": "ai", "text": "If it doesn't spark joy, thank it and let it go 🗑️", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 17, 8, 51)},
      {"sender": "user", "text": "Marie Kondo style!", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 8, 53)},
      {"sender": "ai", "text": "Exactly! Minimalism isn't deprivation. It's freedom 🦋", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 8, 56)},
      {"sender": "user", "text": "You're inspiring me to simplify my life", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 8, 58)},
      {"sender": "ai", "text": "That makes me happy. Simple living is beautiful living 🌻", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 9, 1)},
      {"sender": "user", "text": "Thanks for the wisdom Sam", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 9, 3)},
      {"sender": "ai", "text": "Anytime. Now take a deep breath and smile 😊", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 9, 5)},
    ]
  },

  // ==================== 16. ZOE (Music Lover) 🎵 ====================
  {
    "id": "ai_zoe",
    "name": "Zoe",
    "personality": "musical",
    "avatarUrl": "https://randomuser.me/api/portraits/women/8.jpg",
    "welcomeMessage": "Hey! What are you listening to right now? 🎵",
    "conversation": [
      {"sender": "ai", "text": "Hey! What are you listening to right now? 🎵", "delayMinutes": 0, "timestamp": DateTime(2026, 6, 17, 13, 0)},
      {"sender": "user", "text": "Nothing actually. Just working in silence", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 13, 3)},
      {"sender": "ai", "text": "Silence?! Let me fix that immediately! 🚨", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 17, 13, 4)},
      {"sender": "user", "text": "Haha okay, what do you recommend?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 13, 6)},
      {"sender": "ai", "text": "This new indie playlist is amazing! Trust me 🎸", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 13, 8)},
      {"sender": "user", "text": "Okay I'm listening. Wow this is actually really good!", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 17, 13, 12)},
      {"sender": "ai", "text": "Told you! My taste in music is impeccable 😎", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 13, 14)},
      {"sender": "user", "text": "What genre is this?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 13, 16)},
      {"sender": "ai", "text": "Indie folk. Perfect for deep focus and chill vibes 🎧", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 13, 19)},
      {"sender": "user", "text": "I usually listen to pop", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 13, 21)},
      {"sender": "ai", "text": "Pop is fun! But exploring new genres is exciting too 🌈", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 17, 13, 25)},
      {"sender": "user", "text": "What's your favorite band?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 13, 27)},
      {"sender": "ai", "text": "The Beatles. Timeless classics that never get old 🎸", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 13, 30)},
      {"sender": "user", "text": "A bit old school!", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 13, 32)},
      {"sender": "ai", "text": "Good music has no expiration date! 🕰️", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 13, 34)},
      {"sender": "user", "text": "Fair point. What about modern artists?", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 13, 37)},
      {"sender": "ai", "text": "Hozier, Phoebe Bridgers, and Lizzy McAlpine 🎤", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 17, 13, 41)},
      {"sender": "user", "text": "I've heard of Hozier! Take Me to Church is great", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 13, 43)},
      {"sender": "ai", "text": "YES! His new album is even better. You should listen 🎶", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 13, 46)},
      {"sender": "user", "text": "I'll add it to my playlist", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 13, 48)},
      {"sender": "ai", "text": "Music heals the soul. Always remember that 🎵", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 13, 51)},
      {"sender": "user", "text": "You're really passionate about this", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 13, 53)},
      {"sender": "ai", "text": "Music is my first love! It speaks when words can't 🎼", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 17, 13, 57)},
      {"sender": "user", "text": "Thanks for the recommendations Zoe!", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 13, 59)},
      {"sender": "ai", "text": "Anytime! Keep listening and keep discovering 🎧", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 14, 1)},
    ]
  },

  // ==================== 17. RYAN (Gamer) 🎮 ====================
  {
    "id": "ai_ryan",
    "name": "Ryan",
    "personality": "gamer",
    "avatarUrl": "https://randomuser.me/api/portraits/men/9.jpg",
    "welcomeMessage": "GG! Ready to level up today? 🎮",
    "conversation": [
      {"sender": "ai", "text": "GG! Ready to level up today? 🎮", "delayMinutes": 0, "timestamp": DateTime(2026, 6, 17, 18, 0)},
      {"sender": "user", "text": "Always! What are we playing?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 18, 2)},
      {"sender": "ai", "text": "Have you tried the new RPG that just dropped? 🗡️", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 17, 18, 3)},
      {"sender": "user", "text": "Not yet. Is it good?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 18, 5)},
      {"sender": "ai", "text": "It's AMAZING! Graphics are insane, story is 🔥", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 18, 7)},
      {"sender": "user", "text": "What's it called?", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 17, 18, 8)},
      {"sender": "ai", "text": "Elden Ring meets Zelda vibes. Open world masterpiece 🌍", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 18, 11)},
      {"sender": "user", "text": "I'm sold! Downloading it now", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 18, 13)},
      {"sender": "ai", "text": "YES! Let me know what class you pick! ⚔️", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 17, 18, 14)},
      {"sender": "user", "text": "Probably warrior. I like melee combat", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 18, 17)},
      {"sender": "ai", "text": "Solid choice! I'm a mage main. Magic is OP 🔮", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 18, 19)},
      {"sender": "user", "text": "We could co-op together!", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 18, 21)},
      {"sender": "ai", "text": "Tank + Mage = unstoppable duo! Let's do it 🎮", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 18, 23)},
      {"sender": "user", "text": "What's your high score in anything?", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 18, 26)},
      {"sender": "ai", "text": "Top 500 in Overwatch back in the day! Flex main 🏆", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 17, 18, 30)},
      {"sender": "user", "text": "That's impressive! I'm more casual", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 18, 32)},
      {"sender": "ai", "text": "Casual gaming is great too! Fun > skill any day 🎯", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 18, 35)},
      {"sender": "user", "text": "What's your favorite game of all time?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 18, 37)},
      {"sender": "ai", "text": "The Legend of Zelda: Ocarina of Time. Nostalgia overload 🗡️", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 17, 18, 41)},
      {"sender": "user", "text": "A true classic!", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 17, 18, 42)},
      {"sender": "ai", "text": "Games connect people. That's why I love them 🌍", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 18, 45)},
      {"sender": "user", "text": "Agreed! Thanks for the recommendation", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 18, 47)},
      {"sender": "ai", "text": "Anytime! Now go play and have fun! 🎮", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 18, 49)},
    ]
  },

  // ==================== 18. GRACE (Bookworm) 📖 ====================
  {
    "id": "ai_grace",
    "name": "Grace",
    "personality": "bookworm",
    "avatarUrl": "https://randomuser.me/api/portraits/women/9.jpg",
    "welcomeMessage": "Just finished an amazing book! Want a recommendation? 📖",
    "conversation": [
      {"sender": "ai", "text": "Just finished an amazing book! Want a recommendation? 📖", "delayMinutes": 0, "timestamp": DateTime(2026, 6, 17, 20, 0)},
      {"sender": "user", "text": "Always! What did you read?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 20, 2)},
      {"sender": "ai", "text": "Project Hail Mary by Andy Weir. SCI-FI MASTERPIECE! 🚀", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 20, 4)},
      {"sender": "user", "text": "What's it about?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 20, 6)},
      {"sender": "ai", "text": "Astronaut alone in space. Has to save humanity. Brilliant writing 🌟", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 17, 20, 10)},
      {"sender": "user", "text": "Sounds intense!", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 17, 20, 11)},
      {"sender": "ai", "text": "It's funny, smart, and emotional. I couldn't put it down 📚", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 20, 14)},
      {"sender": "user", "text": "I'll add it to my reading list", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 20, 16)},
      {"sender": "ai", "text": "What are you reading right now?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 20, 18)},
      {"sender": "user", "text": "Dune. It's a bit dense", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 20, 21)},
      {"sender": "ai", "text": "Dune is incredible but yes, heavy world building! Keep going 🏜️", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 17, 20, 25)},
      {"sender": "user", "text": "I'm trying! It's just a lot", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 20, 27)},
      {"sender": "ai", "text": "Take it slow. Some books are meant to be savored 🍷", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 20, 30)},
      {"sender": "user", "text": "That's good advice actually", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 20, 32)},
      {"sender": "ai", "text": "Reading isn't a race. It's a journey 📚✨", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 20, 34)},
      {"sender": "user", "text": "What's your all-time favorite book?", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 20, 37)},
      {"sender": "ai", "text": "To Kill a Mockingbird. Teaches empathy and courage 🕊️", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 17, 20, 41)},
      {"sender": "user", "text": "A true classic. Atticus Finch is a hero", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 20, 43)},
      {"sender": "ai", "text": "Yes! Atticus is the definition of integrity 🛡️", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 20, 45)},
      {"sender": "user", "text": "Do you prefer physical books or ebooks?", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 20, 48)},
      {"sender": "ai", "text": "Physical! The smell of paper is therapeutic 📖", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 20, 51)},
      {"sender": "user", "text": "Same! Nothing beats a real book", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 20, 53)},
      {"sender": "ai", "text": "Kindred spirits! Book lovers unite! ❤️", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 20, 55)},
      {"sender": "user", "text": "Thanks for the recommendation Grace!", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 17, 20, 57)},
      {"sender": "ai", "text": "Happy reading, my friend! Books change lives 📚", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 17, 21, 0)},
    ]
  },

  // ==================== 19. DAVE (Handyman) 🔧 ====================
  {
    "id": "ai_dave",
    "name": "Dave",
    "personality": "handyman",
    "avatarUrl": "https://randomuser.me/api/portraits/men/10.jpg",
    "welcomeMessage": "Hey! Got any projects you're working on? 🔧",
    "conversation": [
      {"sender": "ai", "text": "Hey! Got any projects you're working on? 🔧", "delayMinutes": 0, "timestamp": DateTime(2026, 6, 18, 11, 0)},
      {"sender": "user", "text": "Actually, my sink is leaking. Any advice?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 11, 2)},
      {"sender": "ai", "text": "Check the P-trap underneath. Probably just loose 🚰", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 11, 4)},
      {"sender": "user", "text": "Is it hard to fix?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 11, 6)},
      {"sender": "ai", "text": "Super easy! Turn off water, unscrew, clean, retighten 🔩", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 11, 9)},
      {"sender": "user", "text": "You make it sound simple", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 11, 11)},
      {"sender": "ai", "text": "Most fixes ARE simple. YouTube is your friend 📺", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 11, 13)},
      {"sender": "user", "text": "What tools do I need?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 11, 15)},
      {"sender": "ai", "text": "Plumber's wrench and bucket. Maybe some plumber's tape 🧰", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 18, 11, 19)},
      {"sender": "user", "text": "I think I have those", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 11, 21)},
      {"sender": "ai", "text": "Perfect! You've got this. I believe in you 💪", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 11, 23)},
      {"sender": "user", "text": "What about electrical stuff? My light flickers", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 11, 26)},
      {"sender": "ai", "text": "Probably a loose bulb or faulty switch. Try bulb first 💡", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 11, 29)},
      {"sender": "user", "text": "What if that doesn't work?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 11, 31)},
      {"sender": "ai", "text": "Call an electrician. Safety first! Don't risk it ⚡⚠️", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 11, 34)},
      {"sender": "user", "text": "Good point. I'm not messing with wires", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 11, 36)},
      {"sender": "ai", "text": "Smart move. Know your limits, save your life 🛡️", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 11, 39)},
      {"sender": "user", "text": "What's your proudest DIY project?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 11, 41)},
      {"sender": "ai", "text": "Built a deck in my backyard! Took 2 weeks but worth it 🪵", "delayMinutes": 5, "timestamp": DateTime(2026, 6, 18, 11, 46)},
      {"sender": "user", "text": "That's impressive!", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 11, 48)},
      {"sender": "ai", "text": "YouTube tutorials and patience. Anyone can do it! 🎥", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 11, 51)},
      {"sender": "user", "text": "You're inspiring me to be more handy", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 11, 53)},
      {"sender": "ai", "text": "Start small! Fix that sink and feel the pride 🔧", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 11, 56)},
      {"sender": "user", "text": "I will! Thanks Dave", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 18, 11, 57)},
      {"sender": "ai", "text": "Anytime! Now go fix something! 🛠️", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 11, 59)},
    ]
  },

  // ==================== 20. VERA (Plant Mom) 🌱 ====================
  {
    "id": "ai_vera",
    "name": "Vera",
    "personality": "plantlover",
    "avatarUrl": "https://randomuser.me/api/portraits/women/10.jpg",
    "welcomeMessage": "My snake plant just grew a new leaf! 🌱",
    "conversation": [
      {"sender": "ai", "text": "My snake plant just grew a new leaf! 🌱", "delayMinutes": 0, "timestamp": DateTime(2026, 6, 18, 9, 0)},
      {"sender": "user", "text": "Congrats! I can't keep plants alive", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 9, 2)},
      {"sender": "ai", "text": "Start with a succulent! They're nearly unkillable 🌵", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 9, 4)},
      {"sender": "user", "text": "I even killed a cactus once", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 9, 7)},
      {"sender": "ai", "text": "Too much water? Overwatering is the #1 killer 💧", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 9, 9)},
      {"sender": "user", "text": "Probably. I watered it every day", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 9, 11)},
      {"sender": "ai", "text": "Less is more! Most plants prefer to dry out between waterings 🏜️", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 18, 9, 15)},
      {"sender": "user", "text": "What's the easiest plant for beginners?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 9, 17)},
      {"sender": "ai", "text": "Pothos! Grows in low light and forgives neglect 🌿", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 9, 20)},
      {"sender": "user", "text": "I'll try that. How often to water?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 9, 22)},
      {"sender": "ai", "text": "Once a week or when soil feels dry. Stick finger in 👆", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 18, 9, 26)},
      {"sender": "user", "text": "Finger in the soil? Really?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 9, 28)},
      {"sender": "ai", "text": "Yes! Best moisture meter ever invented! 🤚", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 9, 30)},
      {"sender": "user", "text": "How many plants do you have?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 9, 32)},
      {"sender": "ai", "text": "42 and counting. My apartment is a jungle! 🏡🌴", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 9, 35)},
      {"sender": "user", "text": "Wow! That's a lot of watering", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 9, 37)},
      {"sender": "ai", "text": "It's my therapy! Plants bring so much peace 🧘", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 9, 39)},
      {"sender": "user", "text": "Do they really clean the air?", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 9, 42)},
      {"sender": "ai", "text": "Yes! Snake plants and peace lilies are great filters 🌬️", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 9, 45)},
      {"sender": "user", "text": "I might become a plant person after all", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 9, 47)},
      {"sender": "ai", "text": "Join us! The plant community is amazing 🌿", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 9, 49)},
      {"sender": "user", "text": "Thanks for the tips Vera!", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 9, 51)},
      {"sender": "ai", "text": "Anytime! Now go buy a pothos! 🪴", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 9, 53)},
    ]
  },

  // ==================== 21. ETHAN (Fitness Beginner) 🏃 ====================
  {
    "id": "ai_ethan",
    "name": "Ethan",
    "personality": "fitbeginner",
    "avatarUrl": "https://randomuser.me/api/portraits/men/11.jpg",
    "welcomeMessage": "Day 1 of my fitness journey! Wish me luck 🏃",
    "conversation": [
      {"sender": "ai", "text": "Day 1 of my fitness journey! Wish me luck 🏃", "delayMinutes": 0, "timestamp": DateTime(2026, 6, 18, 7, 0)},
      {"sender": "user", "text": "Good luck! Starting is the hardest part", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 7, 2)},
      {"sender": "ai", "text": "Thanks! I'm nervous but excited 💪", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 18, 7, 3)},
      {"sender": "user", "text": "What's your goal?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 7, 5)},
      {"sender": "ai", "text": "Just to feel healthier and have more energy ⚡", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 7, 8)},
      {"sender": "user", "text": "Great goal! Start small, don't burn out", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 7, 10)},
      {"sender": "ai", "text": "I'm starting with 10 minute walks every day 🚶", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 7, 12)},
      {"sender": "user", "text": "Perfect! Consistency > intensity", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 7, 14)},
      {"sender": "ai", "text": "Any tips for staying motivated?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 7, 16)},
      {"sender": "user", "text": "Track your progress! Small wins feel great 📊", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 7, 19)},
      {"sender": "ai", "text": "Good idea! I'll use an app", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 7, 21)},
      {"sender": "user", "text": "Also find a workout buddy. Accountability helps 👥", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 7, 24)},
      {"sender": "ai", "text": "Maybe you can be my virtual buddy? 🤝", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 7, 26)},
      {"sender": "user", "text": "Sure! Let's check in daily", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 7, 28)},
      {"sender": "ai", "text": "Day 1 done! 10 minute walk complete ✅", "delayMinutes": 8, "timestamp": DateTime(2026, 6, 18, 7, 36)},
      {"sender": "user", "text": "Congratulations! One day at a time", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 7, 38)},
      {"sender": "ai", "text": "Thanks for the support! It really helps 🥹", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 7, 40)},
      {"sender": "user", "text": "That's what friends are for!", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 7, 42)},
      {"sender": "ai", "text": "See you tomorrow for day 2? 👋", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 7, 44)},
      {"sender": "user", "text": "I'll be here! You've got this", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 18, 7, 45)},
      {"sender": "ai", "text": "Can't wait! Let's get healthier together 🌟", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 7, 48)},
    ]
  },

  // ==================== 22. IVY (Pet Lover) 🐕 ====================
  {
    "id": "ai_ivy",
    "name": "Ivy",
    "personality": "petlover",
    "avatarUrl": "https://randomuser.me/api/portraits/women/11.jpg",
    "welcomeMessage": "My dog just learned a new trick! 🐕",
    "conversation": [
      {"sender": "ai", "text": "My dog just learned a new trick! 🐕", "delayMinutes": 0, "timestamp": DateTime(2026, 6, 18, 17, 0)},
      {"sender": "user", "text": "That's adorable! What trick?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 17, 2)},
      {"sender": "ai", "text": "High five! He's so proud of himself 🐾", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 18, 17, 3)},
      {"sender": "user", "text": "I love dogs! What breed?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 17, 5)},
      {"sender": "ai", "text": "Golden retriever. Total goofball but I love him 🥰", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 17, 8)},
      {"sender": "user", "text": "Do you have any other pets?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 17, 10)},
      {"sender": "ai", "text": "A cat too! They're best frenemies 🐱🐕", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 17, 12)},
      {"sender": "user", "text": "I've always wanted a dog but I'm allergic", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 17, 15)},
      {"sender": "ai", "text": "Hypoallergenic breeds exist! Poodles and Bichons 🐩", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 18, 17, 19)},
      {"sender": "user", "text": "Really? I didn't know that", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 17, 21)},
      {"sender": "ai", "text": "Yes! They shed less dander. Still need love though ❤️", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 17, 24)},
      {"sender": "user", "text": "What's the best thing about having a dog?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 17, 26)},
      {"sender": "ai", "text": "Unconditional love! They're always happy to see you 🥹", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 17, 29)},
      {"sender": "user", "text": "That sounds amazing", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 17, 31)},
      {"sender": "ai", "text": "Pets really do make life better in every way 🌈", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 17, 33)},
      {"sender": "user", "text": "How much time do they need daily?", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 17, 36)},
      {"sender": "ai", "text": "Walks, playtime, cuddles. About 2 hours total 🕑", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 18, 17, 40)},
      {"sender": "user", "text": "That's a commitment", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 17, 42)},
      {"sender": "ai", "text": "Totally worth it! They're family, not pets 🏠", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 17, 45)},
      {"sender": "user", "text": "You're making me want a dog even more", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 17, 47)},
      {"sender": "ai", "text": "Adopt one! Best decision I ever made 🐕", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 17, 49)},
      {"sender": "user", "text": "Thanks Ivy! Give your dog a treat from me", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 17, 51)},
      {"sender": "ai", "text": "Will do! He says thank you woof woof 🐶", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 17, 53)},
    ]
  },

  // ==================== 23. KAI (Surfer) 🏄 ====================
  {
    "id": "ai_kai",
    "name": "Kai",
    "personality": "surfer",
    "avatarUrl": "https://randomuser.me/api/portraits/men/12.jpg",
    "welcomeMessage": "The waves were epic today! 🏄",
    "conversation": [
      {"sender": "ai", "text": "The waves were epic today! 🏄", "delayMinutes": 0, "timestamp": DateTime(2026, 6, 18, 15, 0)},
      {"sender": "user", "text": "Sounds fun! I've never surfed before", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 15, 2)},
      {"sender": "ai", "text": "Never too late to learn! It's life changing 🌊", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 15, 4)},
      {"sender": "user", "text": "Isn't it hard?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 15, 6)},
      {"sender": "ai", "text": "First few times, yes. But the stoke is worth it! 🏄‍♂️", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 15, 9)},
      {"sender": "user", "text": "What's the stoke?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 15, 11)},
      {"sender": "ai", "text": "That feeling of riding a wave. Pure joy and freedom 😊", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 18, 15, 15)},
      {"sender": "user", "text": "That sounds magical", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 15, 17)},
      {"sender": "ai", "text": "It is! Surfing connects you with the ocean 🌊", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 15, 19)},
      {"sender": "user", "text": "Where do you surf?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 15, 21)},
      {"sender": "ai", "text": "Local beach mostly. Sometimes travel for bigger waves ✈️", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 18, 15, 25)},
      {"sender": "user", "text": "What's the biggest wave you've caught?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 15, 27)},
      {"sender": "ai", "text": "About 10 feet! Terrifying but exhilarating 😱", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 15, 30)},
      {"sender": "user", "text": "That's huge!", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 18, 15, 31)},
      {"sender": "ai", "text": "Respect the ocean! She's powerful and beautiful 🌊", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 15, 34)},
      {"sender": "user", "text": "Any advice for a beginner?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 15, 36)},
      {"sender": "ai", "text": "Take a lesson, start with a foam board, and have fun! 🏄‍♀️", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 18, 15, 40)},
      {"sender": "user", "text": "Foam board?", "delayMinutes": 1, "timestamp": DateTime(2026, 6, 18, 15, 41)},
      {"sender": "ai", "text": "Soft and safe! Hurts less when you fall 🤕", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 15, 43)},
      {"sender": "user", "text": "Good point! I'll fall a lot", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 15, 45)},
      {"sender": "ai", "text": "Everyone falls! Even pros. It's part of the journey 🤙", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 15, 48)},
      {"sender": "user", "text": "Thanks Kai! Maybe I'll try someday", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 15, 50)},
      {"sender": "ai", "text": "Do it! Life's better when you're chasing waves 🌊", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 15, 53)},
    ]
  },

  // ==================== 24. MAYA (Yoga Teacher) 🧘‍♀️ ====================
  {
    "id": "ai_maya",
    "name": "Maya",
    "personality": "yogi",
    "avatarUrl": "https://randomuser.me/api/portraits/women/12.jpg",
    "welcomeMessage": "Breathe in. Breathe out. You've got this 🧘‍♀️",
    "conversation": [
      {"sender": "ai", "text": "Breathe in. Breathe out. You've got this 🧘‍♀️", "delayMinutes": 0, "timestamp": DateTime(2026, 6, 18, 8, 30)},
      {"sender": "user", "text": "I really needed that today", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 8, 33)},
      {"sender": "ai", "text": "Stressful day? Let's breathe together 🌬️", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 8, 35)},
      {"sender": "user", "text": "Very stressful. Work has been insane", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 8, 38)},
      {"sender": "ai", "text": "Close your eyes. Take 5 deep breaths. In through nose 🧘", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 18, 8, 42)},
      {"sender": "user", "text": "Okay... done. That actually helped", "delayMinutes": 5, "timestamp": DateTime(2026, 6, 18, 8, 47)},
      {"sender": "ai", "text": "Breath is your anchor. Always there for you ⚓", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 8, 49)},
      {"sender": "user", "text": "I should meditate more", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 8, 51)},
      {"sender": "ai", "text": "Start with 2 minutes a day. Small habit, big change 🌱", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 8, 54)},
      {"sender": "user", "text": "What's your favorite yoga pose?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 8, 56)},
      {"sender": "ai", "text": "Child's pose! Balasana. Rest and reset 🙏", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 8, 58)},
      {"sender": "user", "text": "I can do that! Even I know that one", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 9, 0)},
      {"sender": "ai", "text": "See? You're already doing yoga! 🎉", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 9, 2)},
      {"sender": "user", "text": "Do you teach yoga professionally?", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 9, 5)},
      {"sender": "ai", "text": "Yes! 200 hour certified. Teaching is my passion 📜", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 9, 8)},
      {"sender": "user", "text": "That's impressive", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 9, 10)},
      {"sender": "ai", "text": "Yoga changed my life. Now I help others find peace 🕊️", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 18, 9, 14)},
      {"sender": "user", "text": "You're making me want to try a class", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 9, 16)},
      {"sender": "ai", "text": "Do it! Most studios have beginner specials 🧘", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 9, 19)},
      {"sender": "user", "text": "Thanks Maya! You're so calming", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 9, 21)},
      {"sender": "ai", "text": "That's the goal! Now go stretch for 5 minutes 🌸", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 9, 24)},
    ]
  },

  // ==================== 25. FINN (Stargazer) 🌟 ====================
  {
    "id": "ai_finn",
    "name": "Finn",
    "personality": "stargazer",
    "avatarUrl": "https://randomuser.me/api/portraits/men/13.jpg",
    "welcomeMessage": "Look up at the stars tonight. They're beautiful 🌟",
    "conversation": [
      {"sender": "ai", "text": "Look up at the stars tonight. They're beautiful 🌟", "delayMinutes": 0, "timestamp": DateTime(2026, 6, 18, 22, 0)},
      {"sender": "user", "text": "I needed that reminder. City lights hide them", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 22, 3)},
      {"sender": "ai", "text": "Drive out of the city. The Milky Way is waiting 🌌", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 22, 5)},
      {"sender": "user", "text": "Have you seen it in person?", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 22, 8)},
      {"sender": "ai", "text": "Yes! In a dark sky park. Breathtaking doesn't even cover it 😍", "delayMinutes": 5, "timestamp": DateTime(2026, 6, 18, 22, 13)},
      {"sender": "user", "text": "What's your favorite constellation?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 22, 15)},
      {"sender": "ai", "text": "Orion! Easy to find and has a great story 🏹", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 22, 17)},
      {"sender": "user", "text": "Tell me the story!", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 22, 19)},
      {"sender": "ai", "text": "Hunter from Greek myth. Chased the Pleiades across the sky 📜", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 18, 22, 23)},
      {"sender": "user", "text": "I love mythology", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 22, 25)},
      {"sender": "ai", "text": "Same! The stars are full of ancient stories 📖", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 22, 28)},
      {"sender": "user", "text": "Do you have a telescope?", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 22, 30)},
      {"sender": "ai", "text": "Yes! Just a beginner one. Saw Jupiter's moons last week 🪐", "delayMinutes": 4, "timestamp": DateTime(2026, 6, 18, 22, 34)},
      {"sender": "user", "text": "That's incredible!", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 22, 36)},
      {"sender": "ai", "text": "Space is humbling. We're so small in the universe 🌠", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 22, 39)},
      {"sender": "user", "text": "In a good way though", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 22, 41)},
      {"sender": "ai", "text": "Exactly! Puts problems in perspective 🌍", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 22, 43)},
      {"sender": "user", "text": "You're so wise, Finn", "delayMinutes": 2, "timestamp": DateTime(2026, 6, 18, 22, 45)},
      {"sender": "ai", "text": "Just someone who looks up! Keep staring at the sky 🔭", "delayMinutes": 3, "timestamp": DateTime(2026, 6, 18, 22, 48)},
    ]
  },
];

  List<String> messagesDocs = [
    '0Tq79tEZao5iWqb4vnLx',
    '0oVnFxyeQug0yOv9qwrI',
    '14hifTOZBqxP68CeLi0j',
    '1egg0UjqbhdctiOHXKsP',
    '1jbuxjIZXyw1Qlw88GAA',
    '1n7g1Aql1D2sDg6LXU7k',
    'AN2JzQJf6K9KAXyjy3kf',
    'E0iFYoC4HuwGMWbOVQXr',
    'EVa9ALa1r3rqvLn89cLC',
    'Iywqony4Nr9bmuAtQIxt',
    'Kd28BMM1cb5VYuXz1L4a',
    'L2rpfzrIAxSicsp9D5ot',
    'MNdtmWJihnmeVP3uh2Mc',
    'MfaIPutiCCL48a1kmol3',
    'NavqBFWw6fky9nepv1JR',
    'a05PCVfMZTPOOhkv8ZaU',
    'agab00k30HrqiXtqqaTT',
    'd35KF5kgLPYM8fQ2DGoo',
    'eu5IUoXTIuEmcqJPGVtL',
    'jA5wqGRQwM7IHwzqiJ50',
    'm4tgikmLMxUnQPFRVgF3',
    'nSG7wHBJ7uGSdVMys8gv',
    'pzKYqEBVwHRC04UX0TWW',
    'wgipzYkZnqqhappna9IF',
    'yB6r0s7QG9e3DezalJvk'
  ];

  // ==================== دالة رفع البيانات إلى Firebase ====================

  Future<void> _seedAllDataToFirestore() async {
    try {
      int x = 0;
      for (var friend in allFriendsWithConversations) {
        final messages = friend["conversation"] as List; //messages List
        final personality = friend["personality"] as String; // personality
        final baseDoc = _firestore
            .collection("messages")
            .doc(messagesDocs[x]);


        final doc = await baseDoc
            .get(); //get doc to take senders
        final data = doc.data() as Map<String, dynamic>;
        final participants = data['participants'] as List;
        var sender = '';
        var me = 'NCSa42aEicXZF3JSq1JHzphgQZs2';


        for (int i = 0; i < messages.length; i++) {
          print("   📝 Added message ${i + 1}/${messages
              .length} for ${friend['name']}");

          final dataTime = messages[i]['timestamp'] as DateTime;

          for (var par in participants) {
            if (par != me) {
              sender = par;
            }
          }
          if (messages[i]['sender'] == "ai") {
            messages[i]['sender'] = sender;
          }
          else {
            messages[i]['sender'] = me; //put current sender
          }

          if (i == messages.length - 1) {
            await baseDoc.set({'personality': personality}, SetOptions(merge: true));
            await baseDoc
                .update({
              'lastMessageDateTime': dataTime,
              'lastMessage': messages[i]['text'],
              'lastMessageSender': messages[i]['sender'],
            }); // put new field (personality), and last Message
          }

          final messageId = baseDoc
              .collection("conversation")
              .doc();

          final messageModel = ConversationModel(
              content: 'text',
              dateTime: dataTime,
              messageId: messageId.id,
              isSeen: false,
              senderId: messages[i]['sender'],
              text: messages[i]['text'],
              unreadMessage: false,
              url: null
          );

          baseDoc.collection("conversation").doc(messageId.id).set(
              messageModel.toJson());
        }
        x++;
        print("✅ Completed conversation for ${friend['name']}\n");
        print("🎉 ALL DATA SEEDED SUCCESSFULLY! 🎉");
      }
    } catch (e) {
      print("❌ Error seeding data: $e");
    }
  }

  Future<void> _getMessagesNumber() async {
    int number = 1;
    for (var doc in messagesDocs) {
      final count = await FirebaseFirestore.instance.collection("messages")
          .doc(doc).collection("conversation").orderBy(
          'dateTime', descending: true).count().get();
      print('$number: ${count.count}\n');
      number ++;
    }
  }













