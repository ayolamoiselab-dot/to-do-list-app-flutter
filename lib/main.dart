// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_list_app/views/onboarding/onboarding_screen.dart';
import 'package:todo_list_app/views/login/login_screen.dart';
import 'package:todo_list_app/views/signup/signup_screen.dart';
//import 'package:todo_list_app/views/todo_list_screen.dart'; // À créer plus tard

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
          initialRoute: OnboardingScreen.route,
          routes: {
            OnboardingScreen.route: (context) => const OnboardingScreen(),
            LoginScreen.route: (context) => const LoginScreen(),
            SignUpScreen.route: (context) => const SignUpScreen(),
            '/todo_list': (context) => const TodoListScreen(),
          },
        );
      },
    );
  }
}

class TodoListScreen extends StatelessWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Todo List Screen")),
    );
  }
}