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
}
