import 'package:civic_campus/data/models/incident.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final base = DateTime(2026, 6, 1, 12, 0);

  group('isOverdue', () {
    test('returns false for terminal status Resolved even when old', () {
      final incident = Incident(
        id: 'T-001',
        title: 'test',
        location: 'x',
        category: 'AC',
        status: 'Resolved',
        timeAgo: '3 hari lalu',
        createdAt: base.subtract(const Duration(hours: 72)),
      );
      expect(incident.isOverdue(base), false);
    });

    test('returns false for terminal status Closed even when old', () {
      final incident = Incident(
        id: 'T-002',
        title: 'test',
        location: 'x',
        category: 'Lampu',
        status: 'Closed',
        timeAgo: '1 minggu lalu',
        createdAt: base.subtract(const Duration(hours: 168)),
      );
      expect(incident.isOverdue(base), false);
    });

    test('returns false for non-terminal within 24 hours', () {
      final incident = Incident(
        id: 'T-003',
        title: 'test',
        location: 'x',
        category: 'Toilet',
        status: 'Open',
        timeAgo: '2 jam lalu',
        createdAt: base.subtract(const Duration(hours: 2)),
      );
      expect(incident.isOverdue(base), false);
    });

    test('returns false for non-terminal exactly 24 hours (boundary)', () {
      final incident = Incident(
        id: 'T-004',
        title: 'test',
        location: 'x',
        category: 'WiFi',
        status: 'Assigned',
        timeAgo: '1 hari lalu',
        createdAt: base.subtract(const Duration(hours: 24)),
      );
      expect(incident.isOverdue(base), false);
    });

    test('returns true for non-terminal just over 24 hours', () {
      final incident = Incident(
        id: 'T-005',
        title: 'test',
        location: 'x',
        category: 'AC',
        status: 'In Progress',
        timeAgo: '1 hari lalu',
        createdAt: base.subtract(const Duration(hours: 25)),
      );
      expect(incident.isOverdue(base), true);
    });

    test('returns true for Open status well over 24 hours', () {
      final incident = Incident(
        id: 'T-006',
        title: 'test',
        location: 'x',
        category: 'Furnitur',
        status: 'Open',
        timeAgo: '3 hari lalu',
        createdAt: base.subtract(const Duration(hours: 72)),
      );
      expect(incident.isOverdue(base), true);
    });
  });

  group('formatTimeAgo', () {
    test('returns "Baru saja" for less than 1 minute', () {
      final dt = DateTime.now().subtract(const Duration(seconds: 30));
      expect(formatTimeAgo(dt.toIso8601String()), 'Baru saja');
    });

    test('returns minutes for less than 60 minutes', () {
      final dt = DateTime.now().subtract(const Duration(minutes: 5));
      expect(formatTimeAgo(dt.toIso8601String()), '5 menit yang lalu');
    });

    test('returns hours for less than 24 hours', () {
      final dt = DateTime.now().subtract(const Duration(hours: 3));
      expect(formatTimeAgo(dt.toIso8601String()), '3 jam yang lalu');
    });

    test('returns days for less than 7 days', () {
      final dt = DateTime.now().subtract(const Duration(days: 2));
      expect(formatTimeAgo(dt.toIso8601String()), '2 hari yang lalu');
    });

    test('returns formatted date for 7+ days', () {
      final dt = DateTime(2026, 1, 15, 10, 30);
      expect(formatTimeAgo(dt.toIso8601String()), '15 Jan 2026, 10:30');
    });

    test('returns raw string for invalid input', () {
      expect(formatTimeAgo('not-a-date'), 'not-a-date');
    });
  });

  group('Incident.fromJson', () {
    test('calls formatTimeAgo on updated_at', () {
      final json = {
        'id': 'T-001',
        'title': 'test',
        'location_name': 'room',
        'category_name': 'AC',
        'status': 'Open',
        'updated_at': DateTime.now()
            .subtract(const Duration(hours: 3))
            .toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      };
      final incident = Incident.fromJson(json);
      expect(incident.timeAgo, '3 jam yang lalu');
    });

    test('falls back to location_id when location_name is null', () {
      final json = {
        'id': 'T-002',
        'title': 'test',
        'location_id': 'loc-123',
        'category_name': 'AC',
        'status': 'Open',
        'updated_at': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      };
      final incident = Incident.fromJson(json);
      expect(incident.location, 'loc-123');
    });

    test('falls back to empty category when category_name is null', () {
      final json = {
        'id': 'T-003',
        'title': 'test',
        'location_name': 'room',
        'status': 'Open',
        'updated_at': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      };
      final incident = Incident.fromJson(json);
      expect(incident.category, '');
    });

    test('falls back to Rendah priority when priority_label is null', () {
      final json = {
        'id': 'T-004',
        'title': 'test',
        'location_name': 'room',
        'category_name': 'AC',
        'status': 'Open',
        'updated_at': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      };
      final incident = Incident.fromJson(json);
      expect(incident.priority, 'Rendah');
    });

    test('parses priority_label correctly', () {
      final json = {
        'id': 'T-005',
        'title': 'test',
        'location_name': 'room',
        'category_name': 'AC',
        'status': 'Open',
        'priority_label': 'Tinggi',
        'updated_at': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      };
      final incident = Incident.fromJson(json);
      expect(incident.priority, 'Tinggi');
    });
  });
}
