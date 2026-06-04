import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:civic_campus/core/api_config.dart';

typedef NotificationCallback = void Function(Map<String, dynamic> notification);

class RealtimeService {
  io.Socket? _socket;
  NotificationCallback? _onNewNotification;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  void setOnNewNotification(NotificationCallback callback) {
    _onNewNotification = callback;
  }

  Future<void> connect(String accessToken) async {
    if (_socket != null) return;

    try {
      _socket = io.io(
        ApiConfig.baseUrl,
        <String, dynamic>{
          'transports': ['websocket'],
          'auth': {'token': accessToken},
          'autoConnect': false,
        },
      );

      _socket!.onConnect((_) {
        debugPrint('RealtimeService: connected');
        _isConnected = true;
      });

      _socket!.onConnectError((data) {
        debugPrint('RealtimeService: connect error $data');
      });

      _socket!.onDisconnect((_) {
        debugPrint('RealtimeService: disconnected');
        _isConnected = false;
      });

      _socket!.on('new_notification', (data) {
        if (data is Map<String, dynamic>) {
          _onNewNotification?.call(data);
        }
      });

      _socket!.connect();
    } catch (e) {
      debugPrint('RealtimeService: init error $e');
    }
  }

  void subscribe(String channel) {
    if (_socket == null || !_isConnected) return;
    _socket!.emit('realtime:subscribe', {'channel': channel});
    debugPrint('RealtimeService: subscribed to $channel');
  }

  void unsubscribe(String channel) {
    if (_socket == null) return;
    _socket!.emit('realtime:unsubscribe', {'channel': channel});
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
  }
}
