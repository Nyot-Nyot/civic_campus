import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

class CivicCampusApp extends StatelessWidget {
  const CivicCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CIVIC Campus',
      debugShowCheckedModeBanner: false,
      theme: CivicCampusTheme.themeData,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (context) => const SplashScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
      },
    );
  }
}
