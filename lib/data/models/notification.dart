import 'package:flutter/material.dart';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String timeAgo;
  bool isUnread;
  final IconData icon;
  final Color iconColor;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timeAgo,
    this.isUnread = true,
    required this.icon,
    required this.iconColor,
  });

  NotificationItem.from(NotificationItem other)
      : id = other.id,
        title = other.title,
        body = other.body,
        timeAgo = other.timeAgo,
        isUnread = other.isUnread,
        icon = other.icon,
        iconColor = other.iconColor;
}
