import '../models/incident.dart';
import '../dummy_data.dart';

class IncidentRepository {
  static final Map<String, List<String>> _notes = {};

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
        .where((i) => i.status != statusResolved && i.status != statusClosed)
        .toList();
  }

  Future<List<Incident>> getCompleted() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return allIncidents
        .where((i) => i.status == statusResolved || i.status == statusClosed)
        .toList();
  }

  Future<List<Incident>> getAssignedTo(String staffName) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return allIncidents.where((i) => i.assignedTo == staffName).toList();
  }

  Future<bool> updateStatus(
    String id,
    String newStatus, {
    String? notes,
    String? assignedTo,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = allIncidents.indexWhere((i) => i.id == id);
    if (index == -1) return false;
    allIncidents[index] = allIncidents[index].copyWith(
      status: newStatus,
      assignedTo: assignedTo,
    );
    if (notes != null && notes.trim().isNotEmpty) {
      _notes.putIfAbsent(id, () => []).add(notes.trim());
    }
    return true;
  }

  List<String> getNotes(String id) =>
      List.unmodifiable(_notes[id] ?? []);
}
