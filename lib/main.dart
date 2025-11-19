import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'modules/sign_in/sign_in_screen.dart';
import 'modules/messenger_screen/cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:test_app/shared/constants/user_details.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'modules/notification_service/notification_service.dart';
import 'package:test_app/shared/networks/local/shared_preferences.dart';
import 'package:test_app/shared/networks/remote/firebase_options.dart';
import 'package:test_app/modules/online_status_service/online_status_service.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await CacheHelper.init();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await NotificationService.setupBackgroundIsolate();
    await OnlineStatusService().initialize();
    await NotificationService().initialize();

    final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      NotificationService().handleNotification(initialMessage.data);
    }

    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print('Refreshed FCM token: $newToken');
    });

    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider<MainScreenCubit>(
            create: (context) => MainScreenCubit()
              ..getProfileImage(userId: UserDetails.userId)
              ..getFriends(userId: UserDetails.userId),
          ),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    print("Initialization error: $e");
  }
}


class ThemeNotifier with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeNotifier() {
    _loadTheme();
  }

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    // Save the selected theme to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeColor', mode.toString());
  }

  void _loadTheme() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? theme = prefs.getString('themeColor');
      if (theme == ThemeMode.dark.toString()) {
        _themeMode = ThemeMode.dark;
      } else if (theme == ThemeMode.light.toString()) {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.system;
      }
      notifyListeners();
    } catch (e) {
      print("Error loading theme: $e");
    }
  }
}

ThemeData getLightTheme() {
  return ThemeData(
    colorScheme: const ColorScheme.light(
      primary: Colors.black,
      onPrimary: Colors.white, // نص على العناصر الأساسية (أبيض)
      secondary: Colors.black,
      onSecondary: Colors.white, // نص على العناصر الثانوية (أبيض)
      background: Colors.white, // لون الخلفية العامة
      onBackground: Colors.black, // لون النص على الخلفية العامة (أسود)
      error: Colors.red,
      onError: Colors.white, // نص على ألوان الخطأ (أبيض)
      surface: Colors.white,
      onSurface: Colors.black, // لون النص على السطح (أسود)
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.black),
        foregroundColor: MaterialStateProperty.all(Colors.white), // لون النص
        textStyle: MaterialStateProperty.all(
          const TextStyle(color: Colors.white), // لون النص داخل الأزرار
        ),
      ),
    ),
    indicatorColor: Colors.black,
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        iconColor: MaterialStateProperty.all(Colors.black),
      ),
    ),
  );
}

ThemeData getDarkTheme() {
  return ThemeData(
    colorScheme: ColorScheme.dark(
      primary: Colors.white, // لون العناصر الرئيسية
      onPrimary: Colors.white, // لون النص على العناصر الرئيسية
      secondary: Colors.blue, // لون العناصر الثانوية
      onSecondary: Colors.white, // لون النص على العناصر الثانوية
      surface: Colors.grey.shade900, // لون السطح
      background: Colors.grey.shade900, // لون الخلفية العامة
      error: Colors.red, // لون الخطأ
      onError: Colors.white, // لون النص على الخطأ (أبيض)
    ),
    indicatorColor: Colors.black,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.black),
        foregroundColor: MaterialStateProperty.all(Colors.black), // لون النص
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        iconColor: MaterialStateProperty.all(Colors.white),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            theme: getLightTheme(),
            darkTheme: getDarkTheme(),
            themeMode: themeNotifier.themeMode,
            debugShowCheckedModeBanner: false,
            home: const SignInScreen(),
          );
        },
      ),
    );
  }
}