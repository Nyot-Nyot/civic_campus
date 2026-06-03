import 'package:civic_campus/data/models/notification.dart';
import 'package:civic_campus/data/dummy_data.dart';

class NotificationRepository {
  late List<NotificationItem> _items;

  NotificationRepository() {
    _items = allNotifications
        .map((n) => NotificationItem.from(n))
        .toList();
  }

  Future<List<NotificationItem>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_items);
  }

  Future<int> getUnreadCount() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _items.where((n) => n.isUnread).length;
  }

  void markAllRead() {
    for (final n in _items) {
      n.isUnread = false;
    }
  }
}
