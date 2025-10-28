// تحديث في lib/main.dart
import 'package:accuntant/screens/home_screen.dart';
import 'package:flutter/material.dart';
// import 'package:kidcolor/services/text_to_speech_service.dart';
import 'controller/app_rout.dart';
import 'splash_screen/splash_screen.dart';
// import 'splash_screen/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'المحاسب الشخصي',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Tajawal',
        useMaterial3: true,
      ),
      onGenerateRoute: AppRoutes.generateRoute,
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}