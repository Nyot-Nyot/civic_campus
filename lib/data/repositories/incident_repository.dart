import '../models/incident.dart';
import '../dummy_data.dart';

class IncidentRepository {
  Future<List<Incident>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(allIncidents);
  }

  Future<Incident?> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return allIncidents.where((i) => i.id == id).firstOrNull;
  }

  Future<List<Incident>> getActive() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return allIncidents
        .where((i) => i.status != 'Resolved' && i.status != 'Closed')
        .toList();
  }

  Future<List<Incident>> getCompleted() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return allIncidents
        .where((i) => i.status == 'Resolved' || i.status == 'Closed')
        .toList();
  }
}
