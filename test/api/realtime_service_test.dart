import 'package:flutter_test/flutter_test.dart';
import 'package:civic_campus/api/realtime_service.dart';

void main() {
  late RealtimeService service;

  setUp(() {
    service = RealtimeService();
  });

  tearDown(() {
    service.disconnect();
  });

  group('initial state', () {
    test('isConnected is false', () {
      expect(service.isConnected, false);
    });
  });

  group('connect', () {
    test('does not throw when called with a token', () async {
      await service.connect('test-token');
      // No exception = pass
    });

    test('can be called multiple times without throwing', () async {
      await service.connect('test-token-1');
      await service.connect('test-token-2');
      // No exception = pass
    });
  });

  group('disconnect', () {
    test('does not throw when called without connecting', () {
      service.disconnect();
      // No exception = pass
    });

    test('disconnects cleanly after connecting', () async {
      await service.connect('test-token');
      service.disconnect();
      expect(service.isConnected, false);
    });
  });

  group('subscribe / unsubscribe', () {
    test('subscribe does not throw before connect', () {
      service.subscribe('test-channel');
      // No exception = pass
    });

    test('unsubscribe does not throw before connect', () {
      service.unsubscribe('test-channel');
      // No exception = pass
    });

    test('subscribe does not throw after connect', () async {
      await service.connect('test-token');
      service.subscribe('test-channel');
      // No exception = pass
    });
  });

  group('setOnNewNotification', () {
    test('can set and replace callback without throwing', () {
      service.setOnNewNotification((data) {});
      service.setOnNewNotification((data) {});
      // No exception = pass
    });
  });
}
