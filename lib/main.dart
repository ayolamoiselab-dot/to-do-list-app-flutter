// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list_app/views/onboarding/onboarding_screen.dart';
import 'package:todo_list_app/views/login/login_screen.dart';
import 'package:todo_list_app/views/signup/signup_screen.dart';
import 'package:todo_list_app/views/home_screen.dart';
import 'package:todo_list_app/views/add_task_screen.dart';
import 'package:todo_list_app/views/edit_task_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Vérifier si l'onboarding a été vu
  bool isOnboardingSeen = false;
  try {
    final prefs = await SharedPreferences.getInstance();
    isOnboardingSeen = prefs.getBool('isSeen') ?? false;
  } catch (e) {
    print("Erreur lors de la vérification de l'onboarding : $e");
  }

  runApp(MyApp(initialRoute: isOnboardingSeen ? LoginScreen.route : OnboardingScreen.route));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'To-Do List',
          theme: ThemeData(
            primarySwatch: Colors.green,
          ),
          debugShowCheckedModeBanner: false,
          initialRoute: initialRoute,
          routes: {
            OnboardingScreen.route: (context) => const OnboardingScreen(),
            LoginScreen.route: (context) => const LoginScreen(),
            SignUpScreen.route: (context) => const SignUpScreen(),
            HomeScreen.route: (context) => const HomeScreen(),
            AddTaskScreen.route: (context) => const AddTaskScreen(),
            EditTaskScreen.route: (context) => EditTaskScreen(),
          },
        );
      },
    );
  }
}