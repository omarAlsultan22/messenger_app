import 'package:test_app/core/constants/app_colors.dart';
import '../features/messenger_screen/presentation/cubits/cubit.dart';
import '../features/sign_in/presentation/screens/sign_in_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/services/theme_notifier.dart';
import '../core/constants/user_details.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart'; 
import '../main.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const _white = AppColors.white;
  static const _black = AppColors.black;
  static const _grey = AppColors.grey_900;

  ThemeData _getLightTheme() {
    return ThemeData(
      colorScheme: const ColorScheme.light(
        primary: _black,
        onPrimary: _white,
        // نص على العناصر الأساسية (أبيض)
        secondary: _black,
        onSecondary: _white,
        // نص على العناصر الثانوية (أبيض)
        background: _white,
        // لون الخلفية العامة
        onBackground: _black,
        // لون النص على الخلفية العامة (أسود)
        error: AppColors.redPrimaryValue,
        onError: _white,
        // نص على ألوان الخطأ (أبيض)
        surface: _white,
        onSurface: _black, // لون النص على السطح (أسود)
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(_black),
          foregroundColor: MaterialStateProperty.all(_white), // لون النص
          textStyle: MaterialStateProperty.all(
            const TextStyle(color: _white), // لون النص داخل الأزرار
          ),
        ),
      ),
      indicatorColor: _black,
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          iconColor: MaterialStateProperty.all(_black),
        ),
      ),
    );
  }

  ThemeData _getDarkTheme() {
    return ThemeData(
      colorScheme: const ColorScheme.dark(
        primary: _white,
        // لون العناصر الرئيسية
        onPrimary: _white,
        // لون النص على العناصر الرئيسية
        secondary: AppColors.blue,
        // لون العناصر الثانوية
        onSecondary: _white,
        // لون النص على العناصر الثانوية
        surface: _grey,
        // لون السطح
        background: _grey,
        // لون الخلفية العامة
        error: AppColors.redPrimaryValue,
        // لون الخطأ
        onError: _white, // لون النص على الخطأ (أبيض)
      ),
      indicatorColor: _black,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(_black),
          foregroundColor: MaterialStateProperty.all(_black), // لون النص
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          iconColor: MaterialStateProperty.all(_white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<MainScreenCubit>(
            create: (context) =>
            MainScreenCubit()
              ..getProfileImage(userId: UserDetails.userId)
              ..getFriends(userId: UserDetails.userId),
          ),
        ],
        child: ChangeNotifierProvider(
            create: (_) => ThemeNotifier(),
            child: Consumer<ThemeNotifier>(
                builder: (context, themeNotifier, child) {
                  return MaterialApp(
                    navigatorKey: navigatorKey,
                    theme: _getLightTheme(),
                    darkTheme: _getDarkTheme(),
                    themeMode: themeNotifier.themeMode,
                    debugShowCheckedModeBanner: false,
                    home: const SignInScreen(),
                  );
                }
            )
        )
    );
  }
}