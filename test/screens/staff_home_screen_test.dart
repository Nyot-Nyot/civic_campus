import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:civic_campus/core/auth_service.dart';
import 'package:civic_campus/screens/staff/staff_home_screen.dart';
import 'package:civic_campus/screens/staff/tabs/my_tasks_tab.dart';
import '../test_helper.dart';

class StaffAuthService extends AuthService {
  StaffAuthService() : super(client: MockApiClient());

  @override
  bool get isAuthenticated => true;

  @override
  String? get userId => 'test-staff-id';

  @override
  AuthSession? get session => null;

  @override
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    return null;
  }

  @override
  Future<void> signOut() async {}
}

Widget _buildTestScreen() {
  return MaterialApp(
    home: wrapWithProviders(
      authServiceOverride: StaffAuthService(),
      child: const StaffHomeScreen(),
    ),
  );
}

void main() {
  setUpAll(() async {
    await initTestEnv();
  });

  testWidgets('initial tab shows MyTasks', (tester) async {
    await tester.pumpWidget(_buildTestScreen());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(StaffMyTasksTab), findsOneWidget);
    // Selected tab shows filled icon
    expect(find.byIcon(Icons.assignment), findsOneWidget);
    // Unselected tabs show outlined icons
    expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
  });
}
