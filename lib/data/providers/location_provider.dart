import 'package:flutter/foundation.dart';
import 'package:civic_campus/api/location_api.dart';

class LocationProvider extends ChangeNotifier {
  final LocationApi _api;

  List<Map<String, dynamic>> _buildings = [];
  List<Map<String, dynamic>> _floors = [];
  List<Map<String, dynamic>> _areas = [];
  Map<String, dynamic>? _selectedBuilding;
  Map<String, dynamic>? _selectedFloor;
  Map<String, dynamic>? _selectedArea;
  bool _isLoading = false;
  String? _error;

  LocationProvider(this._api);

  List<Map<String, dynamic>> get buildings => _buildings;
  List<Map<String, dynamic>> get floors => _floors;
  List<Map<String, dynamic>> get areas => _areas;
  Map<String, dynamic>? get selectedBuilding => _selectedBuilding;
  Map<String, dynamic>? get selectedFloor => _selectedFloor;
  Map<String, dynamic>? get selectedArea => _selectedArea;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBuildings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _api.getBuildings();
    if (response.isSuccess && response.data is List) {
      _buildings = (response.data as List).cast<Map<String, dynamic>>();
    } else {
      _error = response.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> selectBuilding(Map<String, dynamic> building) async {
    _selectedBuilding = building;
    _selectedFloor = null;
    _selectedArea = null;
    _floors = [];
    _areas = [];
    notifyListeners();

    _isLoading = true;
    notifyListeners();

    final response = await _api.getFloors(building['id'] as String);
    if (response.isSuccess && response.data is List) {
      _floors = (response.data as List).cast<Map<String, dynamic>>();
    } else {
      _error = response.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> selectFloor(Map<String, dynamic> floor) async {
    _selectedFloor = floor;
    _selectedArea = null;
    _areas = [];
    notifyListeners();

    _isLoading = true;
    notifyListeners();

    final response = await _api.getAreas(floor['id'] as String);
    if (response.isSuccess && response.data is List) {
      _areas = (response.data as List).cast<Map<String, dynamic>>();
    } else {
      _error = response.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  void selectArea(Map<String, dynamic> area) {
    _selectedArea = area;
    notifyListeners();
  }

  void clearSelection() {
    _selectedBuilding = null;
    _selectedFloor = null;
    _selectedArea = null;
    _floors = [];
    _areas = [];
    notifyListeners();
  }

  Future<String?> create(Map<String, dynamic> data) async {
    final response = await _api.create(data);
    if (response.isSuccess) {
      if (data['type'] == 'Building') await loadBuildings();
      return null;
    }
    return response.error;
  }

  Future<String?> update(String id, Map<String, dynamic> data) async {
    final response = await _api.update(id, data);
    if (response.isSuccess) {
      await loadBuildings();
      return null;
    }
    return response.error;
  }

  Future<String?> delete(String id) async {
    final response = await _api.delete(id);
    if (response.isSuccess) {
      await loadBuildings();
      return null;
    }
    return response.error;
  }

  String? getSelectedLocationId() {
    return _selectedArea?['id'] ?? _selectedFloor?['id'] ?? _selectedBuilding?['id'];
  }

  String getSelectedLocationName() {
    final parts = <String>[];
    if (_selectedBuilding != null) parts.add(_selectedBuilding!['name'] as String);
    if (_selectedFloor != null) parts.add(_selectedFloor!['name'] as String);
    if (_selectedArea != null) parts.add(_selectedArea!['name'] as String);
    return parts.join(' / ');
  }
}
