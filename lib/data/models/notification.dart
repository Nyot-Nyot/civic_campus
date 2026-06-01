import 'package:flutter/material.dart';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String timeAgo;
  bool isUnread;
  final IconData icon;
  final Color iconColor;
  final String? incidentId;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timeAgo,
    this.isUnread = true,
    required this.icon,
    required this.iconColor,
    this.incidentId,
  });

  NotificationItem.from(NotificationItem other)
      : id = other.id,
        title = other.title,
        body = other.body,
        timeAgo = other.timeAgo,
        isUnread = other.isUnread,
        icon = other.icon,
        iconColor = other.iconColor,
        incidentId = other.incidentId;
}
