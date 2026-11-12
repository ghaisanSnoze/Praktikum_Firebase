import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'utils/app_color.dart';
import 'firebase_options.dart';
import 'widgets/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pocketwise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColor.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColor.primary,
          primary: AppColor.primary,
          surface: Colors.white,
          error: AppColor.error,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColor.background,
          foregroundColor: AppColor.secondary,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColor.primary),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}