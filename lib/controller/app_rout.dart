
import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
// import '../splash_screen/splash_screen.dart';

class AppRoutes {
  // تعريف أسماء الراوتس
  static const String splash = '/';               // عادة نقطة البداية
  static const String home = '/home';

  // دالة تولد الراوت حسب الاسم
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
      // ممكن تستخدم SplashScreen أو IntroScreen كبداية
      //   return MaterialPageRoute(builder: (_) => SplashScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
        default:
      // صفحة الخطأ في حالة راوت غير معروف
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('صفحة غير موجودة')),
            body: const Center(child: Text('الصفحة غير موجودة')),
          ),
        );
    }
  }
}
