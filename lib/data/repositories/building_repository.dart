import '../models/building.dart';
import '../dummy_data.dart';

class BuildingRepository {
  Future<List<Building>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(allBuildings);
  }

  Future<List<Building>> search(String query) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (query.trim().isEmpty) return List.unmodifiable(allBuildings);
    final q = query.toLowerCase();
    return allBuildings.where((b) {
      if (b.name.toLowerCase().contains(q)) return true;
      for (final f in b.floors) {
        if (f.name.toLowerCase().contains(q)) return true;
        for (final a in f.areas) {
          if (a.toLowerCase().contains(q)) return true;
        }
      }
      return false;
    }).toList();
  }

  Future<void> add(Building building) async {
    await Future.delayed(const Duration(milliseconds: 100));
    allBuildings.add(building);
  }

  Future<void> update(int index, Building building) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (index >= 0 && index < allBuildings.length) {
      allBuildings[index] = building;
    }
  }

  Future<void> delete(int index) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (index >= 0 && index < allBuildings.length) {
      allBuildings.removeAt(index);
    }
  }
}
