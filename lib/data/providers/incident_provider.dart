import 'package:flutter/foundation.dart';
import 'package:civic_campus/api/incident_api.dart';

class IncidentProvider extends ChangeNotifier {
  final IncidentApi _api;

  List<Map<String, dynamic>> _incidents = [];
  Map<String, dynamic>? _selectedIncident;
  bool _isLoading = false;
  String? _error;
  String _statusFilter = '';
  String _searchQuery = '';

  IncidentProvider(this._api);

  List<Map<String, dynamic>> get incidents => _incidents;
  Map<String, dynamic>? get selectedIncident => _selectedIncident;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get statusFilter => _statusFilter;

  Future<void> loadAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _api.list(
      status: _statusFilter.isEmpty ? null : _statusFilter,
      search: _searchQuery.isEmpty ? null : _searchQuery,
    );
    if (response.isSuccess && response.data is List) {
      _incidents = (response.data as List).cast<Map<String, dynamic>>();
    } else {
      _error = response.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    loadAll();
  }

  void setSearch(String query) {
    _searchQuery = query;
    loadAll();
  }

  Future<void> loadById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _api.getById(id);
    if (response.isSuccess && response.data is List) {
      final list = response.data as List;
      _selectedIncident = list.isNotEmpty ? list.first as Map<String, dynamic> : null;
    } else {
      _error = response.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<String?> updateStatus(String id, String status, {String? assignedTo}) async {
    final response = await _api.updateStatus(id, status, assignedTo: assignedTo);
    if (response.isError) return response.error;
    await loadAll();
    return null;
  }

  Future<String?> addNote(String incidentId, String content) async {
    final response = await _api.addNote(incidentId, content);
    if (response.isError) return response.error;
    return null;
  }

  Future<List<Map<String, dynamic>>> getHistory(String incidentId) async {
    final response = await _api.getHistory(incidentId);
    if (response.isSuccess && response.data is List) {
      return (response.data as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getNotes(String incidentId) async {
    final response = await _api.getNotes(incidentId);
    if (response.isSuccess && response.data is List) {
      return (response.data as List).cast<Map<String, dynamic>>();
    }
    return [];
  }
}
