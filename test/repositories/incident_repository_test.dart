import 'package:civic_campus/data/dummy_data.dart';
import 'package:civic_campus/data/models/incident.dart';
import 'package:civic_campus/data/repositories/incident_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late IncidentRepository repo;

  setUp(() {
    repo = IncidentRepository();
  });

  group('updateStatus', () {
    test('returns true and changes status when id exists', () async {
      final original = allIncidents.firstWhere((i) => i.id == 'INC-001');
      final oldStatus = original.status;

      final ok = await repo.updateStatus('INC-001', statusResolved);
      expect(ok, true);

      final updated = allIncidents.firstWhere((i) => i.id == 'INC-001');
      expect(updated.status, statusResolved);

      allIncidents[allIncidents.indexWhere((i) => i.id == 'INC-001')] =
          original.copyWith(status: oldStatus);
    });

    test('returns false for unknown id', () async {
      final ok = await repo.updateStatus('NONEXISTENT', statusResolved);
      expect(ok, false);
    });

    test('trims whitespace from notes before storing', () async {
      await repo.updateStatus('INC-002', statusAssigned, notes: '  catatan  ');
      final notes = repo.getNotes('INC-002');
      expect(notes, contains('catatan'));
      expect(notes, isNot(contains('  catatan  ')));
    });

    test('does not store empty or whitespace-only notes', () async {
      await repo.updateStatus('INC-005', statusAssigned, notes: '   ');
      final notes = repo.getNotes('INC-005');
      expect(notes, isEmpty);
    });

    test('appends multiple notes for the same incident', () async {
      await repo.updateStatus('INC-003', statusInProgress, notes: 'note one');
      await repo.updateStatus('INC-003', statusResolved, notes: 'note two');
      final notes = repo.getNotes('INC-003');
      expect(notes, ['note one', 'note two']);
    });
  });

  group('getNotes', () {
    test('returns empty list for id with no notes', () async {
      final notes = repo.getNotes('UNKNOWN_ID');
      expect(notes, isEmpty);
    });

    test('returns an unmodifiable list', () async {
      await repo.updateStatus('INC-004', statusResolved, notes: 'test note');
      final notes = repo.getNotes('INC-004');
      expect(
        () => notes.add('should fail'),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });
}
