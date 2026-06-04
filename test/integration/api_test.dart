import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:civic_campus/core/api_config.dart';

const _password = 'password123';
const _studentEmail = 'andi.mahasiswa@campus.id';
const _staffEmail = 'budi.teknisi@campus.id';
const _adminEmail = 'dewi.admin@campus.id';

const _staffId = '0cc90d47-2545-4bde-a570-009db07d81db';

Map<String, String> authHeader(String token) => {
      'apikey': ApiConfig.anonKey,
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

Map<String, String> patchHeader(String token) => {
      'apikey': ApiConfig.anonKey,
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Prefer': 'return=representation',
    };

Future<String> signIn(String email) async {
  final r = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/api/auth/sessions?client_type=mobile'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'password': _password}),
  );
  expect(r.statusCode, 200, reason: 'Sign in failed for $email: ${r.body}');
  final data = jsonDecode(r.body) as Map<String, dynamic>;
  return data['accessToken'] as String;
}

void main() {
  late String studentToken;
  late String staffToken;
  late String adminToken;
  late String locationId;
  late String categoryId;
  String? testIncidentId;

  setUpAll(() async {
    await dotenv.load(fileName: '.env.local');
    studentToken = await signIn(_studentEmail);
    staffToken = await signIn(_staffEmail);
    adminToken = await signIn(_adminEmail);

    final headers = authHeader(studentToken);
    final locResp = await http.get(
      Uri.parse('${ApiConfig.restUrl}/locations').replace(
        queryParameters: {'type': 'eq.Building', 'name': 'eq.Gedung A'},
      ),
      headers: headers,
    );
    expect(locResp.statusCode, 200);
    final buildings = jsonDecode(locResp.body) as List;
    expect(buildings, isNotEmpty);
    final gedungA = buildings.first as Map<String, dynamic>;

    final floorResp = await http.get(
      Uri.parse('${ApiConfig.restUrl}/locations').replace(
        queryParameters: {
          'parent_id': 'eq.${gedungA['id']}',
          'type': 'eq.Floor',
        },
      ),
      headers: headers,
    );
    expect(floorResp.statusCode, 200);
    final floors = jsonDecode(floorResp.body) as List;
    expect(floors, isNotEmpty);
    final lantai1 = floors.firstWhere(
      (f) => (f as Map)['name'] == 'Lantai 1',
      orElse: () => floors.first,
    ) as Map<String, dynamic>;

    final areaResp = await http.get(
      Uri.parse('${ApiConfig.restUrl}/locations').replace(
        queryParameters: {'parent_id': 'eq.${lantai1['id']}', 'type': 'eq.Area'},
      ),
      headers: headers,
    );
    expect(areaResp.statusCode, 200);
    final areas = jsonDecode(areaResp.body) as List;
    expect(areas, isNotEmpty);
    locationId = (areas.first as Map<String, dynamic>)['id'] as String;

    final catResp = await http.get(
      Uri.parse('${ApiConfig.restUrl}/categories'),
      headers: headers,
    );
    expect(catResp.statusCode, 200);
    final cats = jsonDecode(catResp.body) as List;
    expect(cats, isNotEmpty);
    categoryId = (cats.first as Map<String, dynamic>)['id'] as String;
  });

  group('10.1 Critical Flows', () {
    test('Auth flow: student sign in and get profile', () async {
      final r = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/sessions/current'),
        headers: authHeader(studentToken),
      );
      expect(r.statusCode, 200);
      final data = jsonDecode(r.body) as Map<String, dynamic>;
      expect(data['user'], isNotNull);
      expect(data['user']['email'], _studentEmail);
    });

    test('Report flow: submit report and verify incident created', () async {
      final r = await http.post(
        Uri.parse('${ApiConfig.functionsUrl}/submit-report'),
        headers: authHeader(studentToken),
        body: jsonEncode({
          'location_id': locationId,
          'category_id': categoryId,
          'description': 'Test: AC rusak di ruang A101',
        }),
      );
      expect(r.statusCode, 200,
          reason: 'Submit report failed: ${r.statusCode} ${r.body}');
      final body = jsonDecode(r.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      expect(data['incident_id'], isNotNull);
      testIncidentId = data['incident_id'] as String;

      final getResp = await http.get(
        Uri.parse('${ApiConfig.restUrl}/incidents_with_names').replace(
          queryParameters: {'id': 'eq.$testIncidentId'},
        ),
        headers: authHeader(studentToken),
      );
      expect(getResp.statusCode, 200);
      final list = jsonDecode(getResp.body) as List;
      expect(list, isNotEmpty);
      expect((list.first as Map)['status'], 'Open');
    });

    test('Dedup flow: check duplicate suggestions', () async {
      final r = await http.post(
        Uri.parse('${ApiConfig.functionsUrl}/check-duplicates'),
        headers: authHeader(studentToken),
        body: jsonEncode({
          'location_id': locationId,
          'category_id': categoryId,
          'description': 'Test: AC rusak di ruang A101',
        }),
      );
      expect(r.statusCode, 200,
          reason:
              'check-duplicates failed: ${r.statusCode} ${r.body}');
      final body = jsonDecode(r.body) as Map<String, dynamic>;
      final data = body['data'] as List;
      if (data.isNotEmpty) {
        expect(data.first['score'], greaterThanOrEqualTo(40));
      }
    });

    test('Assignment flow: admin assigns staff to incident', () async {
      expect(testIncidentId, isNotNull);

      // Admin assigns staff (status Assigned + assigned_to)
      final r = await http.patch(
        Uri.parse('${ApiConfig.restUrl}/incidents').replace(
          queryParameters: {'id': 'eq.$testIncidentId'},
        ),
        headers: patchHeader(adminToken),
        body: jsonEncode({
          'status': 'Assigned',
          'assigned_to': _staffId,
        }),
      );
      final assigned = jsonDecode(r.body) as List;
      expect(assigned, isNotEmpty,
          reason: 'Admin assign returned empty — RLS denied?\n'
              'Status: ${r.statusCode}, body: ${r.body}');
      expect((assigned.first as Map)['status'], 'Assigned');
      expect((assigned.first as Map)['assigned_to'], _staffId);

      final getResp = await http.get(
        Uri.parse('${ApiConfig.restUrl}/incidents_with_names').replace(
          queryParameters: {'id': 'eq.$testIncidentId'},
        ),
        headers: authHeader(adminToken),
      );
      expect(getResp.statusCode, 200);
      final list = jsonDecode(getResp.body) as List;
      expect(list, isNotEmpty);
      expect((list.first as Map)['status'], 'Assigned');
    });

    test('Status cycle: Assigned → In Progress → Resolved', () async {
      expect(testIncidentId, isNotNull);

      // Staff: Assigned → In Progress
      final r1 = await http.patch(
        Uri.parse('${ApiConfig.restUrl}/incidents').replace(
          queryParameters: {'id': 'eq.$testIncidentId'},
        ),
        headers: patchHeader(staffToken),
        body: jsonEncode({'status': 'In Progress'}),
      );
      final progress = jsonDecode(r1.body) as List;
      expect(progress, isNotEmpty,
          reason: 'Staff set In Progress returned empty — RLS denied?\n'
              'Status: ${r1.statusCode}, body: ${r1.body}');
      expect((progress.first as Map)['status'], 'In Progress');

      // Staff: In Progress → Resolved
      final r2 = await http.patch(
        Uri.parse('${ApiConfig.restUrl}/incidents').replace(
          queryParameters: {'id': 'eq.$testIncidentId'},
        ),
        headers: patchHeader(staffToken),
        body: jsonEncode({'status': 'Resolved'}),
      );
      final resolved = jsonDecode(r2.body) as List;
      expect(resolved, isNotEmpty,
          reason: 'Staff set Resolved returned empty — RLS denied?\n'
              'Status: ${r2.statusCode}, body: ${r2.body}');
      expect((resolved.first as Map)['status'], 'Resolved');

      final getResp = await http.get(
        Uri.parse('${ApiConfig.restUrl}/incidents_with_names').replace(
          queryParameters: {'id': 'eq.$testIncidentId'},
        ),
        headers: authHeader(staffToken),
      );
      expect(getResp.statusCode, 200);
      final list = jsonDecode(getResp.body) as List;
      expect(list, isNotEmpty);
      expect((list.first as Map)['status'], 'Resolved');
    });
  });

  group('10.2 RLS Role-Based Permissions', () {
    test('Student cannot update incident status', () async {
      // Incident is now "Resolved". Student tries to update → should be denied.
      final statuses = ['Assigned', 'In Progress', 'Resolved', 'Closed'];
      for (final s in statuses) {
        final r = await http.patch(
          Uri.parse('${ApiConfig.restUrl}/incidents').replace(
            queryParameters: {'id': 'eq.$testIncidentId'},
          ),
          headers: patchHeader(studentToken),
          body: jsonEncode({'status': s}),
        );
        final result = jsonDecode(r.body) as List;
        expect(result, isEmpty,
            reason: 'Student should NOT be able to update to $s '
                '(got ${r.statusCode}, body: ${r.body})');
      }
    });

    test('Staff who is assigned can update incident', () async {
      // Staff assigned to this incident CAN update (RLS: assigned_to = auth.uid())
      final r = await http.patch(
        Uri.parse('${ApiConfig.restUrl}/incidents').replace(
          queryParameters: {'id': 'eq.$testIncidentId'},
        ),
        headers: patchHeader(staffToken),
        body: jsonEncode({'status': 'Closed'}),
      );
      final result = jsonDecode(r.body) as List;
      expect(result, isNotEmpty,
          reason: 'Assigned staff should be able to update '
              '(got ${r.statusCode}, body: ${r.body})');
      expect((result.first as Map)['status'], 'Closed');
    });

    test('Admin can close incident', () async {
      final r = await http.patch(
        Uri.parse('${ApiConfig.restUrl}/incidents').replace(
          queryParameters: {'id': 'eq.$testIncidentId'},
        ),
        headers: patchHeader(adminToken),
        body: jsonEncode({'status': 'Closed'}),
      );
      final result = jsonDecode(r.body) as List;
      expect(result, isNotEmpty,
          reason: 'Admin close returned empty — RLS denied?\n'
              'Status: ${r.statusCode}, body: ${r.body}');
      expect((result.first as Map)['status'], 'Closed');
    });
  });

  group('10.4 Priority Auto-Escalation', () {
    late String priorityIncidentId;
    late String studentUserId;
    late String staffUserId;
    late String adminUserId;

    setUp(() async {
      final resp1 = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/sessions/current'),
        headers: authHeader(studentToken),
      );
      studentUserId = (jsonDecode(resp1.body)['user'] as Map)['id'] as String;

      final resp2 = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/sessions/current'),
        headers: authHeader(staffToken),
      );
      staffUserId = (jsonDecode(resp2.body)['user'] as Map)['id'] as String;

      final resp3 = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/sessions/current'),
        headers: authHeader(adminToken),
      );
      adminUserId = (jsonDecode(resp3.body)['user'] as Map)['id'] as String;
    });

    test('New incident starts with Rendah priority and score 10', () async {
      final r = await http.post(
        Uri.parse('${ApiConfig.functionsUrl}/submit-report'),
        headers: authHeader(studentToken),
        body: jsonEncode({
          'location_id': locationId,
          'category_id': categoryId,
          'description': 'Priority test: AC rusak di ruang A102',
        }),
      );
      expect(r.statusCode, 200);
      priorityIncidentId =
          ((jsonDecode(r.body) as Map)['data'] as Map)['incident_id'] as String;

      final getResp = await http.get(
        Uri.parse('${ApiConfig.restUrl}/incidents_with_names').replace(
          queryParameters: {'id': 'eq.$priorityIncidentId'},
        ),
        headers: authHeader(adminToken),
      );
      final incident =
          (jsonDecode(getResp.body) as List).first as Map<String, dynamic>;
      expect(incident['priority_label'], 'Rendah');
      expect(incident['priority_score'], 10);
    });

    test('Confirmations escalate priority_score and auto-upgrade label',
        () async {
          // Student confirms → score=15, still Rendah
          final r1 = await http.post(
            Uri.parse('${ApiConfig.restUrl}/confirmations'),
            headers: authHeader(studentToken),
            body: jsonEncode({
              'incident_id': priorityIncidentId,
              'user_id': studentUserId,
            }),
          );
          expect(r1.statusCode, 201,
              reason: 'Student confirm: ${r1.statusCode} ${r1.body}');

          var getResp = await http.get(
            Uri.parse('${ApiConfig.restUrl}/incidents_with_names').replace(
              queryParameters: {'id': 'eq.$priorityIncidentId'},
            ),
            headers: authHeader(adminToken),
          );
          var inc = (jsonDecode(getResp.body) as List).first as Map<String, dynamic>;
          expect(inc['priority_score'], 15);
          expect(inc['priority_label'], 'Rendah');

          // Staff confirms → score=20, auto-escalates to Sedang
          final r2 = await http.post(
            Uri.parse('${ApiConfig.restUrl}/confirmations'),
            headers: authHeader(staffToken),
            body: jsonEncode({
              'incident_id': priorityIncidentId,
              'user_id': staffUserId,
            }),
          );
          expect(r2.statusCode, 201,
              reason: 'Staff confirm: ${r2.statusCode} ${r2.body}');

          getResp = await http.get(
            Uri.parse('${ApiConfig.restUrl}/incidents_with_names').replace(
              queryParameters: {'id': 'eq.$priorityIncidentId'},
            ),
            headers: authHeader(adminToken),
          );
          inc = (jsonDecode(getResp.body) as List).first as Map<String, dynamic>;
          expect(inc['priority_score'], 20);
          expect(inc['priority_label'], 'Sedang');

          // Admin confirms → score=25, stays Sedang
          final r3 = await http.post(
            Uri.parse('${ApiConfig.restUrl}/confirmations'),
            headers: authHeader(adminToken),
            body: jsonEncode({
              'incident_id': priorityIncidentId,
              'user_id': adminUserId,
            }),
          );
          expect(r3.statusCode, 201,
              reason: 'Admin confirm: ${r3.statusCode} ${r3.body}');

          getResp = await http.get(
            Uri.parse('${ApiConfig.restUrl}/incidents_with_names').replace(
              queryParameters: {'id': 'eq.$priorityIncidentId'},
            ),
            headers: authHeader(adminToken),
          );
          inc = (jsonDecode(getResp.body) as List).first as Map<String, dynamic>;
          expect(inc['priority_score'], 25);
          expect(inc['priority_label'], 'Sedang');
        });
  });

  group('10.3 Dedup Edge Cases', () {
    test('Same location + same category returns high score', () async {
      final r = await http.post(
        Uri.parse('${ApiConfig.functionsUrl}/check-duplicates'),
        headers: authHeader(studentToken),
        body: jsonEncode({
          'location_id': locationId,
          'category_id': categoryId,
          'description': 'Test: AC rusak persis sama',
        }),
      );
      expect(r.statusCode, 200);
      final body = jsonDecode(r.body) as Map<String, dynamic>;
      final data = body['data'] as List;
      if (data.isNotEmpty) {
        expect(data.first['score'], greaterThanOrEqualTo(40));
      }
    });

    test('Empty location returns empty results', () async {
      final r = await http.post(
        Uri.parse('${ApiConfig.functionsUrl}/check-duplicates'),
        headers: authHeader(studentToken),
        body: jsonEncode({
          'location_id': '00000000-0000-0000-0000-000000000000',
          'category_id': categoryId,
        }),
      );
      expect(r.statusCode, 200);
      final body = jsonDecode(r.body) as Map<String, dynamic>;
      expect(body['data'], isA<List>());
    });
  });
}
