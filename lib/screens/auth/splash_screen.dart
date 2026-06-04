import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:civic_campus/data/providers/auth_provider.dart';
import 'package:civic_campus/screens/auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/';
  static const duration = Duration(milliseconds: 1800);

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(SplashScreen.duration, _checkSession);
  }

  Future<void> _checkSession() async {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();

    if (auth.isAuthenticated) {
      await auth.loadProfile();
      if (!mounted) return;

      final role = auth.profile?['role'] as String?;
      String route;
      switch (role) {
        case 'Super Admin':
          route = '/super-admin-home';
          break;
        case 'Facility Admin':
          route = '/admin-home';
          break;
        case 'Maintenance Staff':
          route = '/staff-home';
          break;
        default:
          route = '/student-home';
      }
      Navigator.of(context).pushReplacementNamed(route);
    } else {
      Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF111827), Color(0xFF3B82F6)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.12),
                        blurRadius: 24,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.location_city_rounded,
                    size: 56,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'CIVIC Campus',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Aplikasi manajemen insiden fasilitas kampus dengan alur pelaporan cepat dan transparansi status.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
