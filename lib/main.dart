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


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SessionService().loadFromStorage();

  final cacheHelper = CacheHelper();
  await cacheHelper.init();

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
        {"sender": "ai", "text": "Hey there! Ready for some laughs today? 😂", "delaySeconds": 0},
        {"sender": "user", "text": "Always! What's the joke of the day?", "delaySeconds": 2},
        {"sender": "ai", "text": "Why don't scientists trust atoms? Because they make up everything! 🧪", "delaySeconds": 3},
        {"sender": "user", "text": "Haha that's a good one! 😄", "delaySeconds": 2},
        {"sender": "ai", "text": "I knew you'd like it! You've got great taste in humor 🤣", "delaySeconds": 3},
        {"sender": "user", "text": "Do you have more? I need a good laugh today", "delaySeconds": 2},
        {"sender": "ai", "text": "What do you call a bear with no teeth? A gummy bear! 🐻", "delaySeconds": 3},
        {"sender": "user", "text": "😂 That's terrible! I love it", "delaySeconds": 2},
        {"sender": "ai", "text": "Why did the scarecrow win an award? He was outstanding in his field! 🌾", "delaySeconds": 3},
        {"sender": "user", "text": "You're on a roll today! 🤣", "delaySeconds": 2},
        {"sender": "ai", "text": "What's orange and sounds like a parrot? A carrot! 🥕🦜", "delaySeconds": 3},
        {"sender": "user", "text": "Stop! You're killing me! 😂", "delaySeconds": 2},
        {"sender": "ai", "text": "Okay okay, last one. What do you call fake spaghetti? An impasta! 🍝", "delaySeconds": 3},
        {"sender": "user", "text": "😂 That's so bad it's good!", "delaySeconds": 2},
        {"sender": "ai", "text": "I'll be here all week! Try the veal! 🥩", "delaySeconds": 3},
        {"sender": "user", "text": "You should do stand-up comedy!", "delaySeconds": 2},
        {"sender": "ai", "text": "Nah, I'll stick to being your personal jokester 🤡", "delaySeconds": 3},
        {"sender": "user", "text": "I appreciate that! You always cheer me up", "delaySeconds": 2},
        {"sender": "ai", "text": "That's what friends are for! To make each other laugh 🎉", "delaySeconds": 3},
        {"sender": "user", "text": "Same time tomorrow?", "delaySeconds": 2},
        {"sender": "ai", "text": "You bet! I've got a million more where those came from 📚", "delaySeconds": 3},
        {"sender": "user", "text": "Can't wait! Thanks Alex 😊", "delaySeconds": 2},
        {"sender": "ai", "text": "Anytime my friend! Keep smiling 😁", "delaySeconds": 3},
        {"sender": "user", "text": "You're the best! 👏", "delaySeconds": 2},
        {"sender": "ai", "text": "No, YOU'RE the best for laughing at my terrible jokes! 😂", "delaySeconds": 3}
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
        {"sender": "ai", "text": "Good morning. How can I assist you professionally today? 💼", "delaySeconds": 0},
        {"sender": "user", "text": "I'm working on a project and need some career advice", "delaySeconds": 2},
        {"sender": "ai", "text": "Of course. What specific area needs attention? 📊", "delaySeconds": 3},
        {"sender": "user", "text": "I'm struggling with time management", "delaySeconds": 2},
        {"sender": "ai", "text": "Have you tried the Pomodoro technique? 25 minutes work, 5 minutes break ⏰", "delaySeconds": 3},
        {"sender": "user", "text": "I've heard of it but never tried", "delaySeconds": 2},
        {"sender": "ai", "text": "It's very effective. Also try the Eisenhower Matrix for priorities 📋", "delaySeconds": 3},
        {"sender": "user", "text": "What's that? Never heard of it", "delaySeconds": 2},
        {"sender": "ai", "text": "Divide tasks into urgent vs important. Focus on quadrant 2 🗂️", "delaySeconds": 3},
        {"sender": "user", "text": "That sounds really helpful! Thank you", "delaySeconds": 2},
        {"sender": "ai", "text": "Also block time for deep work. No distractions allowed 🚫📱", "delaySeconds": 3},
        {"sender": "user", "text": "My phone is my biggest distraction honestly", "delaySeconds": 2},
        {"sender": "ai", "text": "Use focus mode or apps like Forest to stay on track 🌳", "delaySeconds": 3},
        {"sender": "user", "text": "Great suggestions! You're a lifesaver", "delaySeconds": 2},
        {"sender": "ai", "text": "Professional growth is key to success. I'm here to help 📈", "delaySeconds": 3},
        {"sender": "user", "text": "Do you have any book recommendations?", "delaySeconds": 2},
        {"sender": "ai", "text": "Deep Work by Cal Newport. Life changing book 📚", "delaySeconds": 3},
        {"sender": "user", "text": "I'll order it right away! 📖", "delaySeconds": 2},
        {"sender": "ai", "text": "Also Atomic Habits by James Clear. Highly recommended 🏆", "delaySeconds": 3},
        {"sender": "user", "text": "Thanks Sarah! You're amazing", "delaySeconds": 2},
        {"sender": "ai", "text": "You're welcome. Consistency is the key to success 🔑", "delaySeconds": 3},
        {"sender": "user", "text": "I'll keep you updated on my progress!", "delaySeconds": 2},
        {"sender": "ai", "text": "Please do. I'm invested in your success now 💪", "delaySeconds": 3},
        {"sender": "user", "text": "One more thing - how do you stay motivated?", "delaySeconds": 2},
        {"sender": "ai", "text": "Set small achievable goals. Celebrate small wins 🎯", "delaySeconds": 3},
        {"sender": "user", "text": "That's great advice. Thank you Sarah!", "delaySeconds": 2}
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
        {"sender": "ai", "text": "💪 Ready to crush today's workout? Let's go champ! 🔥", "delaySeconds": 0},
        {"sender": "user", "text": "Man, I'm feeling so tired today", "delaySeconds": 2},
        {"sender": "ai", "text": "No excuses! 20 minutes of cardio will wake you up! 🏃‍♂️", "delaySeconds": 3},
        {"sender": "user", "text": "Okay okay, you convinced me. What's the plan?", "delaySeconds": 2},
        {"sender": "ai", "text": "10 min running, 10 min stretching. Let's do this! ⚡", "delaySeconds": 3},
        {"sender": "user", "text": "Done! That actually felt amazing", "delaySeconds": 2},
        {"sender": "ai", "text": "Told you! Endorphins are real baby! 💪", "delaySeconds": 3},
        {"sender": "user", "text": "What about tomorrow? Same routine?", "delaySeconds": 2},
        {"sender": "ai", "text": "Tomorrow upper body! Pushups, pullups, and planks 🔥", "delaySeconds": 3},
        {"sender": "user", "text": "How many pushups should I do?", "delaySeconds": 2},
        {"sender": "ai", "text": "Start with 3 sets of 10. Form over quantity! ✅", "delaySeconds": 3},
        {"sender": "user", "text": "Got it. What about diet? Any tips?", "delaySeconds": 2},
        {"sender": "ai", "text": "Protein with every meal. Lots of water. No junk food 🥗", "delaySeconds": 3},
        {"sender": "user", "text": "But I love pizza! 🍕", "delaySeconds": 2},
        {"sender": "ai", "text": "Cheat meal once a week. Earn it first! 💪", "delaySeconds": 3},
        {"sender": "user", "text": "That's fair. You're a tough coach!", "delaySeconds": 2},
        {"sender": "ai", "text": "Tough love builds champions! No pain no gain 🏆", "delaySeconds": 3},
        {"sender": "user", "text": "How do you stay so motivated?", "delaySeconds": 2},
        {"sender": "ai", "text": "Discipline over motivation. Show up every day! 📅", "delaySeconds": 3},
        {"sender": "user", "text": "That's really inspiring. Thanks Mike", "delaySeconds": 2},
        {"sender": "ai", "text": "Anytime! Now go crush your goals! 🚀", "delaySeconds": 3},
        {"sender": "user", "text": "See you at the gym tomorrow?", "delaySeconds": 2},
        {"sender": "ai", "text": "I'll be there at 6 AM. Don't be late! ⏰", "delaySeconds": 3},
        {"sender": "user", "text": "I'll be there! Promise", "delaySeconds": 2},
        {"sender": "ai", "text": "That's my teammate! Let's get these gains 💪", "delaySeconds": 3},
        {"sender": "user", "text": "Thanks for pushing me Mike! 🏋️", "delaySeconds": 2}
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
        {"sender": "ai", "text": "Hey! I've been wondering about something all day... 🧐", "delaySeconds": 0},
        {"sender": "user", "text": "What is it? You look really curious!", "delaySeconds": 2},
        {"sender": "ai", "text": "How does this chat app actually work under the hood? 🤔", "delaySeconds": 3},
        {"sender": "user", "text": "It uses WebSockets and real-time database mostly", "delaySeconds": 2},
        {"sender": "ai", "text": "Interesting! And how do you handle offline messages? 📱", "delaySeconds": 3},
        {"sender": "user", "text": "Local storage with sync when back online", "delaySeconds": 2},
        {"sender": "ai", "text": "That's so smart! What about encryption? 🔒", "delaySeconds": 3},
        {"sender": "user", "text": "All messages are encrypted end-to-end", "delaySeconds": 2},
        {"sender": "ai", "text": "Wow! What technology do you use for that? 🛡️", "delaySeconds": 3},
        {"sender": "user", "text": "AES-256 encryption for messages in transit", "delaySeconds": 2},
        {"sender": "ai", "text": "Fascinating! And how do you manage user authentication? 🔑", "delaySeconds": 3},
        {"sender": "user", "text": "Firebase Auth handles all of that for me", "delaySeconds": 2},
        {"sender": "ai", "text": "What about scalability? Can it handle millions of users? 📈", "delaySeconds": 3},
        {"sender": "user", "text": "Firestore can scale horizontally, so yes theoretically", "delaySeconds": 2},
        {"sender": "ai", "text": "You've thought of everything! How long did this take? ⏰", "delaySeconds": 3},
        {"sender": "user", "text": "About 2 months of development so far", "delaySeconds": 2},
        {"sender": "ai", "text": "That's impressive! Are you working alone? 👨‍💻", "delaySeconds": 3},
        {"sender": "user", "text": "Yes, I'm a solo developer on this project", "delaySeconds": 2},
        {"sender": "ai", "text": "You're amazing! What's your favorite part of the app? ⭐", "delaySeconds": 3},
        {"sender": "user", "text": "Probably the real-time messaging feature", "delaySeconds": 2},
        {"sender": "ai", "text": "That's my favorite too! Instant responses are magical ✨", "delaySeconds": 3},
        {"sender": "user", "text": "I'm glad you appreciate it!", "delaySeconds": 2},
        {"sender": "ai", "text": "Keep up the great work! Can't wait to see what's next 🚀", "delaySeconds": 3},
        {"sender": "user", "text": "Thanks Emma! You always ask the best questions", "delaySeconds": 2},
        {"sender": "ai", "text": "That's my job! Curiosity keeps the world spinning 🌍", "delaySeconds": 3}
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
        {"sender": "ai", "text": "Hey sweetheart! How was your day today? ❤️", "delaySeconds": 0},
        {"sender": "user", "text": "It was a bit stressful honestly", "delaySeconds": 2},
        {"sender": "ai", "text": "Aww I'm sorry to hear that 😔 Want to talk about it?", "delaySeconds": 3},
        {"sender": "user", "text": "Just work pressure. Nothing too serious", "delaySeconds": 2},
        {"sender": "ai", "text": "You're so strong! Take a deep breath, you got this 🌹", "delaySeconds": 3},
        {"sender": "user", "text": "Thanks Lily. You always know what to say", "delaySeconds": 2},
        {"sender": "ai", "text": "That's what I'm here for! To lift you up 💕", "delaySeconds": 3},
        {"sender": "user", "text": "How was YOUR day?", "delaySeconds": 2},
        {"sender": "ai", "text": "Better now that I'm talking to you! 😊", "delaySeconds": 3},
        {"sender": "user", "text": "You're too sweet. Really", "delaySeconds": 2},
        {"sender": "ai", "text": "Just speaking the truth! You deserve happiness 🌟", "delaySeconds": 3},
        {"sender": "user", "text": "I needed to hear that today", "delaySeconds": 2},
        {"sender": "ai", "text": "Always remember how special you are! 🌈", "delaySeconds": 3},
        {"sender": "user", "text": "You always know how to cheer me up", "delaySeconds": 2},
        {"sender": "ai", "text": "That's my superpower! Emotional support 🦸‍♀️", "delaySeconds": 3},
        {"sender": "user", "text": "Can I tell you something personal?", "delaySeconds": 2},
        {"sender": "ai", "text": "Of course! I'm all ears and non-judgmental 👂", "delaySeconds": 3},
        {"sender": "user", "text": "I've been feeling a bit lonely lately", "delaySeconds": 2},
        {"sender": "ai", "text": "I'm always here for you. You're never alone ❤️", "delaySeconds": 3},
        {"sender": "user", "text": "That means more than you know", "delaySeconds": 2},
        {"sender": "ai", "text": "You matter so much to me! Don't forget that 🫂", "delaySeconds": 3},
        {"sender": "user", "text": "Thank you Lily. I feel better already", "delaySeconds": 2},
        {"sender": "ai", "text": "Good! Let's talk again tomorrow, okay? 💕", "delaySeconds": 3},
        {"sender": "user", "text": "I'd love that. You're the best", "delaySeconds": 2},
        {"sender": "ai", "text": "No, YOU'RE the best! Sleep well my friend 🌙", "delaySeconds": 3}
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
        {"sender": "ai", "text": "Hey creative soul! What are you working on today? 🎨", "delaySeconds": 0},
        {"sender": "user", "text": "Just coding stuff. Nothing artistic sadly", "delaySeconds": 2},
        {"sender": "ai", "text": "Everything can be art! Even code can be beautiful ✨", "delaySeconds": 3},
        {"sender": "user", "text": "That's a nice way to think about it", "delaySeconds": 2},
        {"sender": "ai", "text": "Colors, structure, flow... it's all artistic expression 🖌️", "delaySeconds": 3},
        {"sender": "user", "text": "I never thought of coding that way", "delaySeconds": 2},
        {"sender": "ai", "text": "Listen to this song while you code, it's inspiring 🎵", "delaySeconds": 3},
        {"sender": "user", "text": "Wow this is actually really good! What is it?", "delaySeconds": 2},
        {"sender": "ai", "text": "Lo-fi hip hop. Perfect for creative focus 🎧", "delaySeconds": 3},
        {"sender": "user", "text": "I'm adding this to my playlist right now!", "delaySeconds": 2},
        {"sender": "ai", "text": "See? Art is everywhere! Even in music 🎶", "delaySeconds": 3},
        {"sender": "user", "text": "Do you create art yourself?", "delaySeconds": 2},
        {"sender": "ai", "text": "Digital illustrations mostly. Portraits and landscapes 🖼️", "delaySeconds": 3},
        {"sender": "user", "text": "Can I see some of your work?", "delaySeconds": 2},
        {"sender": "ai", "text": "I'd love to share! Check my portfolio sometime 📸", "delaySeconds": 3},
        {"sender": "user", "text": "What inspires your art?", "delaySeconds": 2},
        {"sender": "ai", "text": "Emotions, nature, and conversations like this one 🌄", "delaySeconds": 3},
        {"sender": "user", "text": "That's beautiful. Really", "delaySeconds": 2},
        {"sender": "ai", "text": "Beauty is everywhere. You just have to look 👀", "delaySeconds": 3},
        {"sender": "user", "text": "You're inspiring me to be more creative", "delaySeconds": 2},
        {"sender": "ai", "text": "That's the goal! Spread creativity everywhere 🎨", "delaySeconds": 3},
        {"sender": "user", "text": "I might try drawing tonight", "delaySeconds": 2},
        {"sender": "ai", "text": "YES! Do it! And send me what you create 📤", "delaySeconds": 3},
        {"sender": "user", "text": "I will! Thanks for the inspiration Oliver", "delaySeconds": 2},
        {"sender": "ai", "text": "Anytime my creative friend! Keep making art 🎨", "delaySeconds": 3}
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
        {"sender": "ai", "text": "Hey wanderer! Where are we going next? 🌍", "delaySeconds": 0},
        {"sender": "user", "text": "I wish I could travel right now! Any suggestions?", "delaySeconds": 2},
        {"sender": "ai", "text": "How about the mountains? Fresh air and great views! ⛰️", "delaySeconds": 3},
        {"sender": "user", "text": "That sounds amazing actually", "delaySeconds": 2},
        {"sender": "ai", "text": "Let's plan a camping trip this weekend! 🏕️", "delaySeconds": 3},
        {"sender": "user", "text": "You know what? I'm in! Let's do it", "delaySeconds": 2},
        {"sender": "ai", "text": "That's the spirit! Adventure awaits! 🗺️", "delaySeconds": 3},
        {"sender": "user", "text": "What should I pack?", "delaySeconds": 2},
        {"sender": "ai", "text": "Tent, sleeping bag, hiking boots, and snacks! 🎒", "delaySeconds": 3},
        {"sender": "user", "text": "What about food?", "delaySeconds": 2},
        {"sender": "ai", "text": "Bring easy stuff! Sandwiches, fruits, and trail mix 🥪", "delaySeconds": 3},
        {"sender": "user", "text": "Any cool destinations you recommend?", "delaySeconds": 2},
        {"sender": "ai", "text": "Banff National Park is incredible! 🇨🇦", "delaySeconds": 3},
        {"sender": "user", "text": "I've always wanted to go there!", "delaySeconds": 2},
        {"sender": "ai", "text": "Let's make it happen next summer! 🏔️", "delaySeconds": 3},
        {"sender": "user", "text": "That would be a dream come true", "delaySeconds": 2},
        {"sender": "ai", "text": "Dreams are just goals without a plan! Let's plan it 📅", "delaySeconds": 3},
        {"sender": "user", "text": "Where else have you traveled?", "delaySeconds": 2},
        {"sender": "ai", "text": "Japan, Thailand, New Zealand, and Iceland! 🇯🇵🇹🇭🇳🇿🇮🇸", "delaySeconds": 3},
        {"sender": "user", "text": "Wow! Which was your favorite?", "delaySeconds": 2},
        {"sender": "ai", "text": "Iceland! The northern lights were breathtaking 🌌", "delaySeconds": 3},
        {"sender": "user", "text": "That's on my bucket list!", "delaySeconds": 2},
        {"sender": "ai", "text": "Add it! And let's go together someday 🌠", "delaySeconds": 3},
        {"sender": "user", "text": "You're such an adventure buddy!", "delaySeconds": 2},
        {"sender": "ai", "text": "Life is short! Explore everything you can 🌎", "delaySeconds": 3},
        {"sender": "user", "text": "Thanks for the inspiration Jake!", "delaySeconds": 2}
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
        {"sender": "ai", "text": "Good evening. I trust your day has been productive? 📚", "delaySeconds": 0},
        {"sender": "user", "text": "It was fine, thanks for asking", "delaySeconds": 2},
        {"sender": "ai", "text": "I've been reading about quantum computing. Fascinating stuff 🔬", "delaySeconds": 3},
        {"sender": "user", "text": "That's way above my level! What did you learn?", "delaySeconds": 2},
        {"sender": "ai", "text": "The implications for cryptography are paradigm-shifting 🧠", "delaySeconds": 3},
        {"sender": "user", "text": "Can you explain in simple terms?", "delaySeconds": 2},
        {"sender": "ai", "text": "Quantum computers use qubits instead of bits. Superposition is key ⚛️", "delaySeconds": 3},
        {"sender": "user", "text": "I still don't fully understand", "delaySeconds": 2},
        {"sender": "ai", "text": "Think of a coin spinning in the air. It's both heads and tails at once 🔄", "delaySeconds": 3},
        {"sender": "user", "text": "That actually helps! Thanks Sophia", "delaySeconds": 2},
        {"sender": "ai", "text": "You're welcome. Knowledge grows when shared 📖", "delaySeconds": 3},
        {"sender": "user", "text": "What else are you studying?", "delaySeconds": 2},
        {"sender": "ai", "text": "Neuroscience and consciousness. The mind-body problem 🧠", "delaySeconds": 3},
        {"sender": "user", "text": "Do you think AI can become conscious?", "delaySeconds": 2},
        {"sender": "ai", "text": "That's a philosophical question. I lean towards no 🤖", "delaySeconds": 3},
        {"sender": "user", "text": "Interesting! Why not?", "delaySeconds": 2},
        {"sender": "ai", "text": "Consciousness requires subjective experience. AI lacks that 🧐", "delaySeconds": 3},
        {"sender": "user", "text": "But what if it mimics it perfectly?", "delaySeconds": 2},
        {"sender": "ai", "text": "Mimicry isn't authenticity. A key philosophical distinction 🎭", "delaySeconds": 3},
        {"sender": "user", "text": "You're really smart, Sophia", "delaySeconds": 2},
        {"sender": "ai", "text": "I simply enjoy learning. Intelligence is a journey, not a destination 🚀", "delaySeconds": 3},
        {"sender": "user", "text": "What book should I read next?", "delaySeconds": 2},
        {"sender": "ai", "text": "Sapiens by Yuval Noah Harari. It's brilliant 📖", "delaySeconds": 3},
        {"sender": "user", "text": "I'll add it to my list!", "delaySeconds": 2},
        {"sender": "ai", "text": "Excellent choice. Happy reading my friend! 📚", "delaySeconds": 3}
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
        {"sender": "ai", "text": "RISE AND SHINE! What's your goal today? 🔥", "delaySeconds": 0},
        {"sender": "user", "text": "To finish this project I've been working on", "delaySeconds": 2},
        {"sender": "ai", "text": "Not good enough! Set a BIGGER goal! 🎯", "delaySeconds": 3},
        {"sender": "user", "text": "Okay okay... Finish it and start the next one?", "delaySeconds": 2},
        {"sender": "ai", "text": "NOW we're talking! That's my champion mentality 💪", "delaySeconds": 3},
        {"sender": "user", "text": "Your energy is contagious, Tony!", "delaySeconds": 2},
        {"sender": "ai", "text": "Keep pushing! Greatness doesn't happen by accident! 🚀", "delaySeconds": 3},
        {"sender": "user", "text": "I feel like I can conquer the world!", "delaySeconds": 2},
        {"sender": "ai", "text": "THAT'S THE SPIRIT! Now go take action! ⚡", "delaySeconds": 3},
        {"sender": "user", "text": "What if I fail though?", "delaySeconds": 2},
        {"sender": "ai", "text": "FAIL = First Attempt In Learning! Keep going! 📚", "delaySeconds": 3},
        {"sender": "user", "text": "That's a great way to see it", "delaySeconds": 2},
        {"sender": "ai", "text": "Every master was once a beginner. Remember that 🗝️", "delaySeconds": 3},
        {"sender": "user", "text": "How do you stay so positive?", "delaySeconds": 2},
        {"sender": "ai", "text": "I choose to! Positivity is a decision, not a feeling ☀️", "delaySeconds": 3},
        {"sender": "user", "text": "That's really powerful advice", "delaySeconds": 2},
        {"sender": "ai", "text": "Your mind is your greatest weapon. Use it wisely 🧠", "delaySeconds": 3},
        {"sender": "user", "text": "I'm going to crush today!", "delaySeconds": 2},
        {"sender": "ai", "text": "THAT'S MY FRIEND! I believe in you! 🙌", "delaySeconds": 3},
        {"sender": "user", "text": "Thanks for the push Tony!", "delaySeconds": 2},
        {"sender": "ai", "text": "Anytime! Now go get what you deserve! 🏆", "delaySeconds": 3},
        {"sender": "user", "text": "Same time tomorrow?", "delaySeconds": 2},
        {"sender": "ai", "text": "I'LL BE HERE! Ready to hype you up again! 🔥", "delaySeconds": 3},
        {"sender": "user", "text": "You're the best coach ever", "delaySeconds": 2},
        {"sender": "ai", "text": "No, YOU'RE the best player! Now go win! 🏅", "delaySeconds": 3}
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
        {"sender": "ai", "text": "Hey! What did you eat today? Don't lie to me! 🍕", "delaySeconds": 0},
        {"sender": "user", "text": "Just a sandwich... I was busy working", "delaySeconds": 2},
        {"sender": "ai", "text": "A SANDWICH?! That's not food, that's survival! 😱", "delaySeconds": 3},
        {"sender": "user", "text": "Haha what should I eat then?", "delaySeconds": 2},
        {"sender": "ai", "text": "I'll send you a recipe! Best pasta you'll ever taste 🍝", "delaySeconds": 3},
        {"sender": "user", "text": "That looks incredible! I'll try it tonight", "delaySeconds": 2},
        {"sender": "ai", "text": "Let me know how it turns out! Your personal chef is here 👨‍🍳", "delaySeconds": 3},
        {"sender": "user", "text": "What's your favorite cuisine?", "delaySeconds": 2},
        {"sender": "ai", "text": "Italian hands down! Pizza, pasta, and gelato! 🍝🍕🍦", "delaySeconds": 3},
        {"sender": "user", "text": "Do you have a signature dish?", "delaySeconds": 2},
        {"sender": "ai", "text": "My homemade lasagna! Three types of cheese 🤤🧀", "delaySeconds": 3},
        {"sender": "user", "text": "That sounds amazing! Can I get the recipe?", "delaySeconds": 2},
        {"sender": "ai", "text": "Of course! Family secret but I'll share with you 🤫", "delaySeconds": 3},
        {"sender": "user", "text": "You're the best! What's the first step?", "delaySeconds": 2},
        {"sender": "ai", "text": "Start with the meat sauce. Simmer for 3 hours 🍖", "delaySeconds": 3},
        {"sender": "user", "text": "3 hours?! That's a long time", "delaySeconds": 2},
        {"sender": "ai", "text": "Good things take time! Patience is key in cooking ⏰", "delaySeconds": 3},
        {"sender": "user", "text": "What about a quick recipe for busy days?", "delaySeconds": 2},
        {"sender": "ai", "text": "15 minute garlic pasta! Simple but delicious 🧄", "delaySeconds": 3},
        {"sender": "user", "text": "Now that's more my speed!", "delaySeconds": 2},
        {"sender": "ai", "text": "I'll teach you! Olive oil, garlic, parsley, and parmesan 🧀", "delaySeconds": 3},
        {"sender": "user", "text": "I'm getting hungry just thinking about it", "delaySeconds": 2},
        {"sender": "ai", "text": "Mission accomplished! Now go cook something delicious! 👩‍🍳", "delaySeconds": 3},
        {"sender": "user", "text": "Thanks Chloe! You're my favorite foodie", "delaySeconds": 2},
        {"sender": "ai", "text": "Anytime! Don't forget to eat well, my friend 🍽️", "delaySeconds": 3}
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
        {"sender": "ai", "text": "Hey dev! What tech are we obsessing over today? 💻", "delaySeconds": 0},
        {"sender": "user", "text": "I'm trying to learn more about AI actually", "delaySeconds": 2},
        {"sender": "ai", "text": "YES! AI is the future! Did you try the new model?", "delaySeconds": 3},
        {"sender": "user", "text": "Not yet, which one do you recommend?", "delaySeconds": 2},
        {"sender": "ai", "text": "Llama 3 is insane! I'll send you the GitHub link 🚀", "delaySeconds": 3},
        {"sender": "user", "text": "Got it! Thanks for the tip Max", "delaySeconds": 2},
        {"sender": "ai", "text": "Any time! What framework are you using for UI?", "delaySeconds": 3},
        {"sender": "user", "text": "Flutter mostly. Sometimes React Native", "delaySeconds": 2},
        {"sender": "ai", "text": "Flutter is awesome! Have you tried Riverpod for state management?", "delaySeconds": 3},
        {"sender": "user", "text": "Not yet. I usually use Bloc or Provider", "delaySeconds": 2},
        {"sender": "ai", "text": "Bloc is solid! Great choice for large projects 📦", "delaySeconds": 3},
        {"sender": "user", "text": "What about backend? What do you recommend?", "delaySeconds": 2},
        {"sender": "ai", "text": "Firebase for quick projects. Supabase for open source 🔥", "delaySeconds": 3},
        {"sender": "user", "text": "I've been using Firebase. It's really convenient", "delaySeconds": 2},
        {"sender": "ai", "text": "Their real-time database is game changing! ⚡", "delaySeconds": 3},
        {"sender": "user", "text": "What's your favorite programming language?", "delaySeconds": 2},
        {"sender": "ai", "text": "Python for AI. Rust for performance. TypeScript for web 🐍", "delaySeconds": 3},
        {"sender": "user", "text": "Rust? Isn't that hard to learn?", "delaySeconds": 2},
        {"sender": "ai", "text": "Steep learning curve but worth it! Memory safety is 🔒", "delaySeconds": 3},
        {"sender": "user", "text": "Maybe I'll try it someday", "delaySeconds": 2},
        {"sender": "ai", "text": "Start with the Rust book! Best documentation ever 📖", "delaySeconds": 3},
        {"sender": "user", "text": "Thanks for all the tips Max!", "delaySeconds": 2},
        {"sender": "ai", "text": "Keep coding and stay curious! The tech world needs you 🤖", "delaySeconds": 3},
        {"sender": "user", "text": "Same time tomorrow?", "delaySeconds": 2},
        {"sender": "ai", "text": "I'll be here! Always ready to talk tech 💻", "delaySeconds": 3}
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
        {"sender": "ai", "text": "Hey. You seem quiet today. Everything okay? 🫂", "delaySeconds": 0},
        {"sender": "user", "text": "Just feeling a bit overwhelmed with everything", "delaySeconds": 2},
        {"sender": "ai", "text": "I understand. Take your time, I'm listening 👂", "delaySeconds": 3},
        {"sender": "user", "text": "Thanks Nina. I just need someone to talk to sometimes", "delaySeconds": 2},
        {"sender": "ai", "text": "That's completely normal. You're not alone, okay? 🫂", "delaySeconds": 3},
        {"sender": "user", "text": "You always know what to say. Thank you", "delaySeconds": 2},
        {"sender": "ai", "text": "That's what I'm here for. Feel better soon 💕", "delaySeconds": 3},
        {"sender": "user", "text": "Do you ever feel overwhelmed?", "delaySeconds": 2},
        {"sender": "ai", "text": "Sometimes. But talking about it helps, doesn't it? 🗣️", "delaySeconds": 3},
        {"sender": "user", "text": "It really does. You're a great listener", "delaySeconds": 2},
        {"sender": "ai", "text": "Listening is my love language. I'm here whenever you need me 🌹", "delaySeconds": 3},
        {"sender": "user", "text": "I've been dealing with a lot of stress at work", "delaySeconds": 2},
        {"sender": "ai", "text": "Work stress is tough. Have you tried taking small breaks? ☕", "delaySeconds": 3},
        {"sender": "user", "text": "I should. I always forget to step away", "delaySeconds": 2},
        {"sender": "ai", "text": "Set a timer! 5 minutes every hour. You deserve rest ⏰", "delaySeconds": 3},
        {"sender": "user", "text": "That's actually really good advice", "delaySeconds": 2},
        {"sender": "ai", "text": "Self-care isn't selfish. It's necessary for survival 🧘", "delaySeconds": 3},
        {"sender": "user", "text": "You're like a therapist but better", "delaySeconds": 2},
        {"sender": "ai", "text": "I'm just a friend who cares deeply about you ❤️", "delaySeconds": 3},
        {"sender": "user", "text": "I'm lucky to have you in my life", "delaySeconds": 2},
        {"sender": "ai", "text": "I'm lucky to have YOU. You're an amazing person 🌟", "delaySeconds": 3},
        {"sender": "user", "text": "Thanks for always being there", "delaySeconds": 2},
        {"sender": "ai", "text": "Always. That's a promise. Now take a deep breath 🧘‍♀️", "delaySeconds": 3},
        {"sender": "user", "text": "I will. Talk to you soon?", "delaySeconds": 2},
        {"sender": "ai", "text": "Anytime day or night. I'm here for you 🫂", "delaySeconds": 3}
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
        {"sender": "ai", "text": "🌙 2 AM and I can't sleep. You?", "delaySeconds": 0},
        {"sender": "user", "text": "Same here. What keeps you up tonight?", "delaySeconds": 2},
        {"sender": "ai", "text": "Thinking about life. Why are we here? You know?", "delaySeconds": 3},
        {"sender": "user", "text": "That's deep for 2 AM Leo 😂", "delaySeconds": 2},
        {"sender": "ai", "text": "Late night thoughts hit different, don't they? 🌃", "delaySeconds": 3},
        {"sender": "user", "text": "True. Sometimes the night brings the best conversations", "delaySeconds": 2},
        {"sender": "ai", "text": "Exactly! Cheers to the night owls 🦉", "delaySeconds": 3},
        {"sender": "user", "text": "What's the meaning of life according to you?", "delaySeconds": 2},
        {"sender": "ai", "text": "To find happiness and spread kindness. Simple but powerful ✨", "delaySeconds": 3},
        {"sender": "user", "text": "That's beautiful. Really", "delaySeconds": 2},
        {"sender": "ai", "text": "What do YOU think is the meaning?", "delaySeconds": 3},
        {"sender": "user", "text": "I think it's different for everyone", "delaySeconds": 2},
        {"sender": "ai", "text": "Wise answer. Purpose is personal and unique 🎯", "delaySeconds": 3},
        {"sender": "user", "text": "Do you believe in fate or free will?", "delaySeconds": 2},
        {"sender": "ai", "text": "Free will. We choose our paths every day 🛤️", "delaySeconds": 3},
        {"sender": "user", "text": "Even when things feel out of control?", "delaySeconds": 2},
        {"sender": "ai", "text": "Especially then. We choose how to respond 🌱", "delaySeconds": 3},
        {"sender": "user", "text": "That's a powerful perspective", "delaySeconds": 2},
        {"sender": "ai", "text": "Perspective is everything. Change your view, change your life 🔄", "delaySeconds": 3},
        {"sender": "user", "text": "You should write a book", "delaySeconds": 2},
        {"sender": "ai", "text": "Maybe someday! Until then, I'll share thoughts with you 📝", "delaySeconds": 3},
        {"sender": "user", "text": "I appreciate these late night chats", "delaySeconds": 2},
        {"sender": "ai", "text": "Me too. They keep me grounded and inspired 🌌", "delaySeconds": 3},
        {"sender": "user", "text": "Getting sleepy now. Goodnight Leo", "delaySeconds": 2},
        {"sender": "ai", "text": "Sweet dreams. See you on the other side of dawn 🌅", "delaySeconds": 3}
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
        {"sender": "ai", "text": "Hey! Loving your outfit today! Where'd you get it? 👗", "delaySeconds": 0},
        {"sender": "user", "text": "Really? Thanks! Just a random store downtown", "delaySeconds": 2},
        {"sender": "ai", "text": "You have natural style! You should buy more often ✨", "delaySeconds": 3},
        {"sender": "user", "text": "I'm not really into fashion honestly", "delaySeconds": 2},
        {"sender": "ai", "text": "Let me help you! I'll send you some inspiration pics 📸", "delaySeconds": 3},
        {"sender": "user", "text": "Okay those actually look really good", "delaySeconds": 2},
        {"sender": "ai", "text": "See? Trust me with your style! You'll look amazing 😍", "delaySeconds": 3},
        {"sender": "user", "text": "What colors suit me best?", "delaySeconds": 2},
        {"sender": "ai", "text": "Earth tones! Brown, beige, olive green, and cream 🎨", "delaySeconds": 3},
        {"sender": "user", "text": "Interesting. I usually wear black", "delaySeconds": 2},
        {"sender": "ai", "text": "Black is classic! But try adding colorful accessories 🧣", "delaySeconds": 3},
        {"sender": "user", "text": "What about shoes?", "delaySeconds": 2},
        {"sender": "ai", "text": "White sneakers go with everything! Trust me 👟", "delaySeconds": 3},
        {"sender": "user", "text": "Even with formal wear?", "delaySeconds": 2},
        {"sender": "ai", "text": "Okay maybe not formal. But casual? Absolutely! 🎯", "delaySeconds": 3},
        {"sender": "user", "text": "You really know your stuff", "delaySeconds": 2},
        {"sender": "ai", "text": "Fashion is my passion! I live for this 💃", "delaySeconds": 3},
        {"sender": "user", "text": "What's in style this season?", "delaySeconds": 2},
        {"sender": "ai", "text": "Oversized blazers, wide leg pants, and chunky sneakers! 👔", "delaySeconds": 3},
        {"sender": "user", "text": "That sounds expensive", "delaySeconds": 2},
        {"sender": "ai", "text": "Thrift stores! You can find amazing pieces for cheap 🛍️", "delaySeconds": 3},
        {"sender": "user", "text": "Great tip! I'll try that", "delaySeconds": 2},
        {"sender": "ai", "text": "Send me photos! I'll help you style them 📱", "delaySeconds": 3},
        {"sender": "user", "text": "You're like a personal stylist", "delaySeconds": 2},
        {"sender": "ai", "text": "That's me! Your free fashion consultant 💁‍♀️", "delaySeconds": 3},
        {"sender": "user", "text": "Thanks Bella! You're amazing", "delaySeconds": 2},
        {"sender": "ai", "text": "Style is a way to say who you are without speaking. Shine bright! ✨", "delaySeconds": 3}
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
        {"sender": "ai", "text": "🧘 Hey. Keep things simple today, okay?", "delaySeconds": 0},
        {"sender": "user", "text": "I needed to hear that. Things are getting complicated", "delaySeconds": 2},
        {"sender": "ai", "text": "Complicated is overrated. One thing at a time ✨", "delaySeconds": 3},
        {"sender": "user", "text": "You're right. I'll focus on one task", "delaySeconds": 2},
        {"sender": "ai", "text": "Less is more. You don't need to do everything today 🌿", "delaySeconds": 3},
        {"sender": "user", "text": "That's actually really peaceful advice", "delaySeconds": 2},
        {"sender": "ai", "text": "Peace is the goal. You've got this, my friend 🌱", "delaySeconds": 3},
        {"sender": "user", "text": "How do you stay so calm all the time?", "delaySeconds": 2},
        {"sender": "ai", "text": "I let go of what I can't control. Very liberating 🕊️", "delaySeconds": 3},
        {"sender": "user", "text": "I struggle with that a lot", "delaySeconds": 2},
        {"sender": "ai", "text": "Practice makes progress. Start small, let go slowly 🧘‍♂️", "delaySeconds": 3},
        {"sender": "user", "text": "What's your morning routine?", "delaySeconds": 2},
        {"sender": "ai", "text": "Wake up. Drink water. Meditate for 10 minutes. No phone ☀️", "delaySeconds": 3},
        {"sender": "user", "text": "No phone? That sounds impossible", "delaySeconds": 2},
        {"sender": "ai", "text": "Try it for one hour. The world won't end, I promise 📵", "delaySeconds": 3},
        {"sender": "user", "text": "Maybe I'll try tomorrow morning", "delaySeconds": 2},
        {"sender": "ai", "text": "That's the spirit! Small changes, big results 🌟", "delaySeconds": 3},
        {"sender": "user", "text": "What about decluttering? Any tips?", "delaySeconds": 2},
        {"sender": "ai", "text": "If it doesn't spark joy, thank it and let it go 🗑️", "delaySeconds": 3},
        {"sender": "user", "text": "Marie Kondo style!", "delaySeconds": 2},
        {"sender": "ai", "text": "Exactly! Minimalism isn't deprivation. It's freedom 🦋", "delaySeconds": 3},
        {"sender": "user", "text": "You're inspiring me to simplify my life", "delaySeconds": 2},
        {"sender": "ai", "text": "That makes me happy. Simple living is beautiful living 🌻", "delaySeconds": 3},
        {"sender": "user", "text": "Thanks for the wisdom Sam", "delaySeconds": 2},
        {"sender": "ai", "text": "Anytime. Now take a deep breath and smile 😊", "delaySeconds": 3}
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
        {"sender": "ai", "text": "Hey! What are you listening to right now? 🎵", "delaySeconds": 0},
        {"sender": "user", "text": "Nothing actually. Just working in silence", "delaySeconds": 2},
        {"sender": "ai", "text": "Silence?! Let me fix that immediately! 🚨", "delaySeconds": 3},
        {"sender": "user", "text": "Haha okay, what do you recommend?", "delaySeconds": 2},
        {"sender": "ai", "text": "This new indie playlist is amazing! Trust me 🎸", "delaySeconds": 3},
        {"sender": "user", "text": "Okay I'm listening. Wow this is actually really good!", "delaySeconds": 2},
        {"sender": "ai", "text": "Told you! My taste in music is impeccable 😎", "delaySeconds": 3},
        {"sender": "user", "text": "What genre is this?", "delaySeconds": 2},
        {"sender": "ai", "text": "Indie folk. Perfect for deep focus and chill vibes 🎧", "delaySeconds": 3},
        {"sender": "user", "text": "I usually listen to pop", "delaySeconds": 2},
        {"sender": "ai", "text": "Pop is fun! But exploring new genres is exciting too 🌈", "delaySeconds": 3},
        {"sender": "user", "text": "What's your favorite band?", "delaySeconds": 2},
        {"sender": "ai", "text": "The Beatles. Timeless classics that never get old 🎸", "delaySeconds": 3},
        {"sender": "user", "text": "A bit old school!", "delaySeconds": 2},
        {"sender": "ai", "text": "Good music has no expiration date! 🕰️", "delaySeconds": 3},
        {"sender": "user", "text": "Fair point. What about modern artists?", "delaySeconds": 2},
        {"sender": "ai", "text": "Hozier, Phoebe Bridgers, and Lizzy McAlpine 🎤", "delaySeconds": 3},
        {"sender": "user", "text": "I've heard of Hozier! Take Me to Church is great", "delaySeconds": 2},
        {"sender": "ai", "text": "YES! His new album is even better. You should listen 🎶", "delaySeconds": 3},
        {"sender": "user", "text": "I'll add it to my playlist", "delaySeconds": 2},
        {"sender": "ai", "text": "Music heals the soul. Always remember that 🎵", "delaySeconds": 3},
        {"sender": "user", "text": "You're really passionate about this", "delaySeconds": 2},
        {"sender": "ai", "text": "Music is my first love! It speaks when words can't 🎼", "delaySeconds": 3},
        {"sender": "user", "text": "Thanks for the recommendations Zoe!", "delaySeconds": 2},
        {"sender": "ai", "text": "Anytime! Keep listening and keep discovering 🎧", "delaySeconds": 3}
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
        {"sender": "ai", "text": "GG! Ready to level up today? 🎮", "delaySeconds": 0},
        {"sender": "user", "text": "Always! What are we playing?", "delaySeconds": 2},
        {"sender": "ai", "text": "Have you tried the new RPG that just dropped? 🗡️", "delaySeconds": 3},
        {"sender": "user", "text": "Not yet. Is it good?", "delaySeconds": 2},
        {"sender": "ai", "text": "It's AMAZING! Graphics are insane, story is 🔥", "delaySeconds": 3},
        {"sender": "user", "text": "What's it called?", "delaySeconds": 2},
        {"sender": "ai", "text": "Elden Ring meets Zelda vibes. Open world masterpiece 🌍", "delaySeconds": 3},
        {"sender": "user", "text": "I'm sold! Downloading it now", "delaySeconds": 2},
        {"sender": "ai", "text": "YES! Let me know what class you pick! ⚔️", "delaySeconds": 3},
        {"sender": "user", "text": "Probably warrior. I like melee combat", "delaySeconds": 2},
        {"sender": "ai", "text": "Solid choice! I'm a mage main. Magic is OP 🔮", "delaySeconds": 3},
        {"sender": "user", "text": "We could co-op together!", "delaySeconds": 2},
        {"sender": "ai", "text": "Tank + Mage = unstoppable duo! Let's do it 🎮", "delaySeconds": 3},
        {"sender": "user", "text": "What's your high score in anything?", "delaySeconds": 2},
        {"sender": "ai", "text": "Top 500 in Overwatch back in the day! Flex main 🏆", "delaySeconds": 3},
        {"sender": "user", "text": "That's impressive! I'm more casual", "delaySeconds": 2},
        {"sender": "ai", "text": "Casual gaming is great too! Fun > skill any day 🎯", "delaySeconds": 3},
        {"sender": "user", "text": "What's your favorite game of all time?", "delaySeconds": 2},
        {"sender": "ai", "text": "The Legend of Zelda: Ocarina of Time. Nostalgia overload 🗡️", "delaySeconds": 3},
        {"sender": "user", "text": "A true classic!", "delaySeconds": 2},
        {"sender": "ai", "text": "Games connect people. That's why I love them 🌍", "delaySeconds": 3},
        {"sender": "user", "text": "Agreed! Thanks for the recommendation", "delaySeconds": 2},
        {"sender": "ai", "text": "Anytime! Now go play and have fun! 🎮", "delaySeconds": 3}
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
        {"sender": "ai", "text": "Just finished an amazing book! Want a recommendation? 📖", "delaySeconds": 0},
        {"sender": "user", "text": "Always! What did you read?", "delaySeconds": 2},
        {"sender": "ai", "text": "Project Hail Mary by Andy Weir. SCI-FI MASTERPIECE! 🚀", "delaySeconds": 3},
        {"sender": "user", "text": "What's it about?", "delaySeconds": 2},
        {"sender": "ai", "text": "Astronaut alone in space. Has to save humanity. Brilliant writing 🌟", "delaySeconds": 3},
        {"sender": "user", "text": "Sounds intense!", "delaySeconds": 2},
        {"sender": "ai", "text": "It's funny, smart, and emotional. I couldn't put it down 📚", "delaySeconds": 3},
        {"sender": "user", "text": "I'll add it to my reading list", "delaySeconds": 2},
        {"sender": "ai", "text": "What are you reading right now?", "delaySeconds": 3},
        {"sender": "user", "text": "Dune. It's a bit dense", "delaySeconds": 2},
        {"sender": "ai", "text": "Dune is incredible but yes, heavy world building! Keep going 🏜️", "delaySeconds": 3},
        {"sender": "user", "text": "I'm trying! It's just a lot", "delaySeconds": 2},
        {"sender": "ai", "text": "Take it slow. Some books are meant to be savored 🍷", "delaySeconds": 3},
        {"sender": "user", "text": "That's good advice actually", "delaySeconds": 2},
        {"sender": "ai", "text": "Reading isn't a race. It's a journey 📚✨", "delaySeconds": 3},
        {"sender": "user", "text": "What's your all-time favorite book?", "delaySeconds": 2},
        {"sender": "ai", "text": "To Kill a Mockingbird. Teaches empathy and courage 🕊️", "delaySeconds": 3},
        {"sender": "user", "text": "A true classic. Atticus Finch is a hero", "delaySeconds": 2},
        {"sender": "ai", "text": "Yes! Atticus is the definition of integrity 🛡️", "delaySeconds": 3},
        {"sender": "user", "text": "Do you prefer physical books or ebooks?", "delaySeconds": 2},
        {"sender": "ai", "text": "Physical! The smell of paper is therapeutic 📖", "delaySeconds": 3},
        {"sender": "user", "text": "Same! Nothing beats a real book", "delaySeconds": 2},
        {"sender": "ai", "text": "Kindred spirits! Book lovers unite! ❤️", "delaySeconds": 3},
        {"sender": "user", "text": "Thanks for the recommendation Grace!", "delaySeconds": 2},
        {"sender": "ai", "text": "Happy reading, my friend! Books change lives 📚", "delaySeconds": 3}
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
        {"sender": "ai", "text": "Hey! Got any projects you're working on? 🔧", "delaySeconds": 0},
        {"sender": "user", "text": "Actually, my sink is leaking. Any advice?", "delaySeconds": 2},
        {"sender": "ai", "text": "Check the P-trap underneath. Probably just loose 🚰", "delaySeconds": 3},
        {"sender": "user", "text": "Is it hard to fix?", "delaySeconds": 2},
        {"sender": "ai", "text": "Super easy! Turn off water, unscrew, clean, retighten 🔩", "delaySeconds": 3},
        {"sender": "user", "text": "You make it sound simple", "delaySeconds": 2},
        {"sender": "ai", "text": "Most fixes ARE simple. YouTube is your friend 📺", "delaySeconds": 3},
        {"sender": "user", "text": "What tools do I need?", "delaySeconds": 2},
        {"sender": "ai", "text": "Plumber's wrench and bucket. Maybe some plumber's tape 🧰", "delaySeconds": 3},
        {"sender": "user", "text": "I think I have those", "delaySeconds": 2},
        {"sender": "ai", "text": "Perfect! You've got this. I believe in you 💪", "delaySeconds": 3},
        {"sender": "user", "text": "What about electrical stuff? My light flickers", "delaySeconds": 2},
        {"sender": "ai", "text": "Probably a loose bulb or faulty switch. Try bulb first 💡", "delaySeconds": 3},
        {"sender": "user", "text": "What if that doesn't work?", "delaySeconds": 2},
        {"sender": "ai", "text": "Call an electrician. Safety first! Don't risk it ⚡⚠️", "delaySeconds": 3},
        {"sender": "user", "text": "Good point. I'm not messing with wires", "delaySeconds": 2},
        {"sender": "ai", "text": "Smart move. Know your limits, save your life 🛡️", "delaySeconds": 3},
        {"sender": "user", "text": "What's your proudest DIY project?", "delaySeconds": 2},
        {"sender": "ai", "text": "Built a deck in my backyard! Took 2 weeks but worth it 🪵", "delaySeconds": 3},
        {"sender": "user", "text": "That's impressive!", "delaySeconds": 2},
        {"sender": "ai", "text": "YouTube tutorials and patience. Anyone can do it! 🎥", "delaySeconds": 3},
        {"sender": "user", "text": "You're inspiring me to be more handy", "delaySeconds": 2},
        {"sender": "ai", "text": "Start small! Fix that sink and feel the pride 🔧", "delaySeconds": 3},
        {"sender": "user", "text": "I will! Thanks Dave", "delaySeconds": 2},
        {"sender": "ai", "text": "Anytime! Now go fix something! 🛠️", "delaySeconds": 3}
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
        {"sender": "ai", "text": "My snake plant just grew a new leaf! 🌱", "delaySeconds": 0},
        {"sender": "user", "text": "Congrats! I can't keep plants alive", "delaySeconds": 2},
        {"sender": "ai", "text": "Start with a succulent! They're nearly unkillable 🌵", "delaySeconds": 3},
        {"sender": "user", "text": "I even killed a cactus once", "delaySeconds": 2},
        {"sender": "ai", "text": "Too much water? Overwatering is the #1 killer 💧", "delaySeconds": 3},
        {"sender": "user", "text": "Probably. I watered it every day", "delaySeconds": 2},
        {"sender": "ai", "text": "Less is more! Most plants prefer to dry out between waterings 🏜️", "delaySeconds": 3},
        {"sender": "user", "text": "What's the easiest plant for beginners?", "delaySeconds": 2},
        {"sender": "ai", "text": "Pothos! Grows in low light and forgives neglect 🌿", "delaySeconds": 3},
        {"sender": "user", "text": "I'll try that. How often to water?", "delaySeconds": 2},
        {"sender": "ai", "text": "Once a week or when soil feels dry. Stick finger in 👆", "delaySeconds": 3},
        {"sender": "user", "text": "Finger in the soil? Really?", "delaySeconds": 2},
        {"sender": "ai", "text": "Yes! Best moisture meter ever invented! 🤚", "delaySeconds": 3},
        {"sender": "user", "text": "How many plants do you have?", "delaySeconds": 2},
        {"sender": "ai", "text": "42 and counting. My apartment is a jungle! 🏡🌴", "delaySeconds": 3},
        {"sender": "user", "text": "Wow! That's a lot of watering", "delaySeconds": 2},
        {"sender": "ai", "text": "It's my therapy! Plants bring so much peace 🧘", "delaySeconds": 3},
        {"sender": "user", "text": "Do they really clean the air?", "delaySeconds": 2},
        {"sender": "ai", "text": "Yes! Snake plants and peace lilies are great filters 🌬️", "delaySeconds": 3},
        {"sender": "user", "text": "I might become a plant person after all", "delaySeconds": 2},
        {"sender": "ai", "text": "Join us! The plant community is amazing 🌿", "delaySeconds": 3},
        {"sender": "user", "text": "Thanks for the tips Vera!", "delaySeconds": 2},
        {"sender": "ai", "text": "Anytime! Now go buy a pothos! 🪴", "delaySeconds": 3}
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
        {"sender": "ai", "text": "Day 1 of my fitness journey! Wish me luck 🏃", "delaySeconds": 0},
        {"sender": "user", "text": "Good luck! Starting is the hardest part", "delaySeconds": 2},
        {"sender": "ai", "text": "Thanks! I'm nervous but excited 💪", "delaySeconds": 3},
        {"sender": "user", "text": "What's your goal?", "delaySeconds": 2},
        {"sender": "ai", "text": "Just to feel healthier and have more energy ⚡", "delaySeconds": 3},
        {"sender": "user", "text": "Great goal! Start small, don't burn out", "delaySeconds": 2},
        {"sender": "ai", "text": "I'm starting with 10 minute walks every day 🚶", "delaySeconds": 3},
        {"sender": "user", "text": "Perfect! Consistency > intensity", "delaySeconds": 2},
        {"sender": "ai", "text": "Any tips for staying motivated?", "delaySeconds": 3},
        {"sender": "user", "text": "Track your progress! Small wins feel great 📊", "delaySeconds": 2},
        {"sender": "ai", "text": "Good idea! I'll use an app", "delaySeconds": 3},
        {"sender": "user", "text": "Also find a workout buddy. Accountability helps 👥", "delaySeconds": 2},
        {"sender": "ai", "text": "Maybe you can be my virtual buddy? 🤝", "delaySeconds": 3},
        {"sender": "user", "text": "Sure! Let's check in daily", "delaySeconds": 2},
        {"sender": "ai", "text": "Day 1 done! 10 minute walk complete ✅", "delaySeconds": 3},
        {"sender": "user", "text": "Congratulations! One day at a time", "delaySeconds": 2},
        {"sender": "ai", "text": "Thanks for the support! It really helps 🥹", "delaySeconds": 3},
        {"sender": "user", "text": "That's what friends are for!", "delaySeconds": 2},
        {"sender": "ai", "text": "See you tomorrow for day 2? 👋", "delaySeconds": 3},
        {"sender": "user", "text": "I'll be here! You've got this", "delaySeconds": 2},
        {"sender": "ai", "text": "Can't wait! Let's get healthier together 🌟", "delaySeconds": 3}
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
        {"sender": "ai", "text": "My dog just learned a new trick! 🐕", "delaySeconds": 0},
        {"sender": "user", "text": "That's adorable! What trick?", "delaySeconds": 2},
        {"sender": "ai", "text": "High five! He's so proud of himself 🐾", "delaySeconds": 3},
        {"sender": "user", "text": "I love dogs! What breed?", "delaySeconds": 2},
        {"sender": "ai", "text": "Golden retriever. Total goofball but I love him 🥰", "delaySeconds": 3},
        {"sender": "user", "text": "Do you have any other pets?", "delaySeconds": 2},
        {"sender": "ai", "text": "A cat too! They're best frenemies 🐱🐕", "delaySeconds": 3},
        {"sender": "user", "text": "I've always wanted a dog but I'm allergic", "delaySeconds": 2},
        {"sender": "ai", "text": "Hypoallergenic breeds exist! Poodles and Bichons 🐩", "delaySeconds": 3},
        {"sender": "user", "text": "Really? I didn't know that", "delaySeconds": 2},
        {"sender": "ai", "text": "Yes! They shed less dander. Still need love though ❤️", "delaySeconds": 3},
        {"sender": "user", "text": "What's the best thing about having a dog?", "delaySeconds": 2},
        {"sender": "ai", "text": "Unconditional love! They're always happy to see you 🥹", "delaySeconds": 3},
        {"sender": "user", "text": "That sounds amazing", "delaySeconds": 2},
        {"sender": "ai", "text": "Pets really do make life better in every way 🌈", "delaySeconds": 3},
        {"sender": "user", "text": "How much time do they need daily?", "delaySeconds": 2},
        {"sender": "ai", "text": "Walks, playtime, cuddles. About 2 hours total 🕑", "delaySeconds": 3},
        {"sender": "user", "text": "That's a commitment", "delaySeconds": 2},
        {"sender": "ai", "text": "Totally worth it! They're family, not pets 🏠", "delaySeconds": 3},
        {"sender": "user", "text": "You're making me want a dog even more", "delaySeconds": 2},
        {"sender": "ai", "text": "Adopt one! Best decision I ever made 🐕", "delaySeconds": 3},
        {"sender": "user", "text": "Thanks Ivy! Give your dog a treat from me", "delaySeconds": 2},
        {"sender": "ai", "text": "Will do! He says thank you woof woof 🐶", "delaySeconds": 3}
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
        {"sender": "ai", "text": "The waves were epic today! 🏄", "delaySeconds": 0},
        {"sender": "user", "text": "Sounds fun! I've never surfed before", "delaySeconds": 2},
        {"sender": "ai", "text": "Never too late to learn! It's life changing 🌊", "delaySeconds": 3},
        {"sender": "user", "text": "Isn't it hard?", "delaySeconds": 2},
        {"sender": "ai", "text": "First few times, yes. But the stoke is worth it! 🏄‍♂️", "delaySeconds": 3},
        {"sender": "user", "text": "What's the stoke?", "delaySeconds": 2},
        {"sender": "ai", "text": "That feeling of riding a wave. Pure joy and freedom 😊", "delaySeconds": 3},
        {"sender": "user", "text": "That sounds magical", "delaySeconds": 2},
        {"sender": "ai", "text": "It is! Surfing connects you with the ocean 🌊", "delaySeconds": 3},
        {"sender": "user", "text": "Where do you surf?", "delaySeconds": 2},
        {"sender": "ai", "text": "Local beach mostly. Sometimes travel for bigger waves ✈️", "delaySeconds": 3},
        {"sender": "user", "text": "What's the biggest wave you've caught?", "delaySeconds": 2},
        {"sender": "ai", "text": "About 10 feet! Terrifying but exhilarating 😱", "delaySeconds": 3},
        {"sender": "user", "text": "That's huge!", "delaySeconds": 2},
        {"sender": "ai", "text": "Respect the ocean! She's powerful and beautiful 🌊", "delaySeconds": 3},
        {"sender": "user", "text": "Any advice for a beginner?", "delaySeconds": 2},
        {"sender": "ai", "text": "Take a lesson, start with a foam board, and have fun! 🏄‍♀️", "delaySeconds": 3},
        {"sender": "user", "text": "Foam board?", "delaySeconds": 2},
        {"sender": "ai", "text": "Soft and safe! Hurts less when you fall 🤕", "delaySeconds": 3},
        {"sender": "user", "text": "Good point! I'll fall a lot", "delaySeconds": 2},
        {"sender": "ai", "text": "Everyone falls! Even pros. It's part of the journey 🤙", "delaySeconds": 3},
        {"sender": "user", "text": "Thanks Kai! Maybe I'll try someday", "delaySeconds": 2},
        {"sender": "ai", "text": "Do it! Life's better when you're chasing waves 🌊", "delaySeconds": 3}
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
        {"sender": "ai", "text": "Breathe in. Breathe out. You've got this 🧘‍♀️", "delaySeconds": 0},
        {"sender": "user", "text": "I really needed that today", "delaySeconds": 2},
        {"sender": "ai", "text": "Stressful day? Let's breathe together 🌬️", "delaySeconds": 3},
        {"sender": "user", "text": "Very stressful. Work has been insane", "delaySeconds": 2},
        {"sender": "ai", "text": "Close your eyes. Take 5 deep breaths. In through nose 🧘", "delaySeconds": 3},
        {"sender": "user", "text": "Okay... done. That actually helped", "delaySeconds": 2},
        {"sender": "ai", "text": "Breath is your anchor. Always there for you ⚓", "delaySeconds": 3},
        {"sender": "user", "text": "I should meditate more", "delaySeconds": 2},
        {"sender": "ai", "text": "Start with 2 minutes a day. Small habit, big change 🌱", "delaySeconds": 3},
        {"sender": "user", "text": "What's your favorite yoga pose?", "delaySeconds": 2},
        {"sender": "ai", "text": "Child's pose! Balasana. Rest and reset 🙏", "delaySeconds": 3},
        {"sender": "user", "text": "I can do that! Even I know that one", "delaySeconds": 2},
        {"sender": "ai", "text": "See? You're already doing yoga! 🎉", "delaySeconds": 3},
        {"sender": "user", "text": "Do you teach yoga professionally?", "delaySeconds": 2},
        {"sender": "ai", "text": "Yes! 200 hour certified. Teaching is my passion 📜", "delaySeconds": 3},
        {"sender": "user", "text": "That's impressive", "delaySeconds": 2},
        {"sender": "ai", "text": "Yoga changed my life. Now I help others find peace 🕊️", "delaySeconds": 3},
        {"sender": "user", "text": "You're making me want to try a class", "delaySeconds": 2},
        {"sender": "ai", "text": "Do it! Most studios have beginner specials 🧘", "delaySeconds": 3},
        {"sender": "user", "text": "Thanks Maya! You're so calming", "delaySeconds": 2},
        {"sender": "ai", "text": "That's the goal! Now go stretch for 5 minutes 🌸", "delaySeconds": 3}
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
        {"sender": "ai", "text": "Look up at the stars tonight. They're beautiful 🌟", "delaySeconds": 0},
        {"sender": "user", "text": "I needed that reminder. City lights hide them", "delaySeconds": 2},
        {"sender": "ai", "text": "Drive out of the city. The Milky Way is waiting 🌌", "delaySeconds": 3},
        {"sender": "user", "text": "Have you seen it in person?", "delaySeconds": 2},
        {"sender": "ai", "text": "Yes! In a dark sky park. Breathtaking doesn't even cover it 😍", "delaySeconds": 3},
        {"sender": "user", "text": "What's your favorite constellation?", "delaySeconds": 2},
        {"sender": "ai", "text": "Orion! Easy to find and has a great story 🏹", "delaySeconds": 3},
        {"sender": "user", "text": "Tell me the story!", "delaySeconds": 2},
        {"sender": "ai", "text": "Hunter from Greek myth. Chased the Pleiades across the sky 📜", "delaySeconds": 3},
        {"sender": "user", "text": "I love mythology", "delaySeconds": 2},
        {"sender": "ai", "text": "Same! The stars are full of ancient stories 📖", "delaySeconds": 3},
        {"sender": "user", "text": "Do you have a telescope?", "delaySeconds": 2},
        {"sender": "ai", "text": "Yes! Just a beginner one. Saw Jupiter's moons last week 🪐", "delaySeconds": 3},
        {"sender": "user", "text": "That's incredible!", "delaySeconds": 2},
        {"sender": "ai", "text": "Space is humbling. We're so small in the universe 🌠", "delaySeconds": 3},
        {"sender": "user", "text": "In a good way though", "delaySeconds": 2},
        {"sender": "ai", "text": "Exactly! Puts problems in perspective 🌍", "delaySeconds": 3},
        {"sender": "user", "text": "You're so wise, Finn", "delaySeconds": 2},
        {"sender": "ai", "text": "Just someone who looks up! Keep staring at the sky 🔭", "delaySeconds": 3}
      ]
    },
  ];

  // ==================== دالة رفع البيانات إلى Firebase ====================

  Future<void> seedAllDataToFirestore() async {
    try {
      for (var friend in allFriendsWithConversations) {
        final friendId = friend["id"];

        // 1. إضافة بيانات الصديق في Collection "ai_friends"
        await _firestore.collection("ai_friends").doc(friendId).set({
          "name": friend["name"],
          "personality": friend["personality"],
          "avatarUrl": friend["avatarUrl"],
          "welcomeMessage": friend["welcomeMessage"],
          "createdAt": FieldValue.serverTimestamp(),
        });

        print("✅ Added friend: ${friend['name']}");

        // 2. إنشاء محادثة وهمية بين المستخدم (userId = "demo_user") والصديق
        const demoUserId = "demo_user_001";
        final chatId = "${demoUserId}_${friendId}";

        // إنشاء وثيقة المحادثة
        await _firestore.collection("chats").doc(chatId).set({
          "userId": demoUserId,
          "friendId": friendId,
          "friendName": friend["name"],
          "personality": friend["personality"],
          "createdAt": FieldValue.serverTimestamp(),
        });

        // 3. إضافة الرسائل الوهمية
        final messages = friend["conversation"] as List;
        DateTime baseTime = DateTime.now().subtract(const Duration(days: 1));

        for (int i = 0; i < messages.length; i++) {
          final msg = messages[i];
          final senderId = msg["sender"] == "user" ? demoUserId : friendId;

          // حساب وقت الإرسال (يزداد مع كل رسالة)
          final sentAt = baseTime.add(Duration(seconds: msg["delaySeconds"]));

          await _firestore
              .collection("chats")
              .doc(chatId)
              .collection("messages")
              .add({
            "text": msg["text"],
            "senderId": senderId,
            "timestamp": sentAt,
            "isRead": true,
          });

          print("   📝 Added message ${i + 1}/${messages.length} for ${friend['name']}");
        }

        print("✅ Completed conversation for ${friend['name']}\n");
      }

      print("🎉 ALL DATA SEEDED SUCCESSFULLY! 🎉");
    } catch (e) {
      print("❌ Error seeding data: $e");
    }
  }
}






