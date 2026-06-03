import 'package:flutter/material.dart';

import 'package:civic_campus/app_messenger.dart';
import 'package:civic_campus/screens/admin/admin_home_screen.dart';
import 'package:civic_campus/screens/auth/login_screen.dart';
import 'package:civic_campus/screens/auth/splash_screen.dart';
import 'package:civic_campus/screens/staff/staff_home_screen.dart';
import 'package:civic_campus/screens/student/student_home_screen.dart';
import 'package:civic_campus/screens/super_admin/super_admin_home_screen.dart';
import 'package:civic_campus/theme/app_theme.dart';

class CivicCampusApp extends StatelessWidget {
  const CivicCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CIVIC Campus',
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: CivicCampusTheme.themeData,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (context) => const SplashScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        StudentHomeScreen.routeName: (context) => const StudentHomeScreen(),
        StaffHomeScreen.routeName: (context) => const StaffHomeScreen(),
        AdminHomeScreen.routeName: (context) => const AdminHomeScreen(),
        SuperAdminHomeScreen.routeName: (context) => const SuperAdminHomeScreen(),
      },
    );
  }
}
