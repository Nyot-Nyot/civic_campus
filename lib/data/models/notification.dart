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

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      timeAgo: json['created_at'] as String,
      isUnread: json['read_at'] == null,
      icon: Icons.notifications,
      iconColor: Colors.blue,
      incidentId: json['entity_id'] as String?,
    );
  }

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
