import 'package:flutter/foundation.dart';
import 'package:civic_campus/api/notification_api.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationApi _api;

  List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  NotificationProvider(this._api);

  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _api.list(userId: userId);
    if (response.isSuccess && response.data is List) {
      _notifications = (response.data as List).cast<Map<String, dynamic>>();
      await _loadUnreadCount(userId);
    } else {
      _error = response.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadUnreadCount(String userId) async {
    final response = await _api.getUnreadCount(userId);
    if (response.isSuccess && response.data is List) {
      final list = response.data as List;
      if (list.isNotEmpty && list.first is Map) {
        _unreadCount = (list.first as Map)['count'] as int? ?? 0;
      }
    }
  }

  Future<String?> markRead(String id) async {
    final response = await _api.markRead(id);
    if (response.isError) return response.error;
    return null;
  }

  Future<String?> markAllRead(String userId) async {
    final response = await _api.markAllRead(userId);
    if (response.isError) return response.error;
    _unreadCount = 0;
    notifyListeners();
    return null;
  }
}
