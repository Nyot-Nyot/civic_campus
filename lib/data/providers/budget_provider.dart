import 'package:civic_campus/api/budget_api.dart';
import 'package:civic_campus/data/models/budget_request.dart';
import 'package:flutter/foundation.dart';

class BudgetProvider extends ChangeNotifier {
  final BudgetApi _api;

  List<BudgetRequest> _budgetRequests = [];
  List<Map<String, dynamic>> _pendingRequests = [];
  bool _isLoading = false;
  String? _error;

  BudgetProvider({required this._api});

  List<BudgetRequest> get budgetRequests => _budgetRequests;
  List<Map<String, dynamic>> get pendingRequests => _pendingRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadForIncident(String incidentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _api.listForIncident(incidentId);
    if (response.isSuccess && response.data is List) {
      _budgetRequests = (response.data as List)
          .map((e) => BudgetRequest.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      _error = response.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadPending() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _api.getPending();
    if (response.isSuccess && response.data is List) {
      _pendingRequests = (response.data as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } else {
      _error = response.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> create({
    required String incidentId,
    required String userId,
    required List<Map<String, dynamic>> items,
    required double totalCost,
    String? notes,
  }) async {
    final response = await _api.create({
      'incident_id': incidentId,
      'items': items,
      'total_cost': totalCost,
      'notes': notes,
      'created_by': userId,
    });
    if (response.isError) return response.error;
    await loadForIncident(incidentId);
    return null;
  }

  Future<String?> approve(String id, String adminNotes) async {
    final response = await _api.approve(id, adminNotes);
    if (response.isError) return response.error;
    await loadPending();
    return null;
  }

  Future<String?> reject(String id, String adminNotes) async {
    final response = await _api.reject(id, adminNotes);
    if (response.isError) return response.error;
    await loadPending();
    return null;
  }
}
