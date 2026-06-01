import 'package:civic_campus/data/repositories/building_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BuildingRepository.search', () {
    late BuildingRepository repo;

    setUp(() {
      repo = BuildingRepository();
    });

    test('returns all buildings for empty query', () async {
      final result = await repo.search('');
      final all = await repo.getAll();
      expect(result.length, all.length);
    });

    test('returns all buildings for whitespace-only query', () async {
      final result = await repo.search('   ');
      final all = await repo.getAll();
      expect(result.length, all.length);
    });

    test('matches by building name (case-insensitive)', () async {
      final result = await repo.search('gedung a');
      expect(result, hasLength(1));
      expect(result.first.name, 'Gedung A');
    });

    test('matches by building name with different case', () async {
      final result = await repo.search('GEDUNG A');
      expect(result, hasLength(1));
      expect(result.first.name, 'Gedung A');
    });

    test('matches by floor name', () async {
      final result = await repo.search('Lantai 3');
      expect(result, hasLength(2));
      for (final b in result) {
        expect(b.floors.any((f) => f.name.contains('Lantai 3')), isTrue);
      }
    });

    test('matches by area name', () async {
      final result = await repo.search('Lab Komputer');
      expect(result, hasLength(1));
      expect(result.first.name, 'Gedung B');
    });

    test('matches by area name (case-insensitive)', () async {
      final result = await repo.search('lab komputer');
      expect(result, hasLength(1));
      expect(result.first.name, 'Gedung B');
    });

    test('returns empty list for no match', () async {
      final result = await repo.search('xyzzy_nonexistent');
      expect(result, isEmpty);
    });

    test('returns all buildings for query matching multiple buildings', () async {
      final result = await repo.search('Toilet');
      expect(result.length, greaterThan(1));
    });
  });
}
