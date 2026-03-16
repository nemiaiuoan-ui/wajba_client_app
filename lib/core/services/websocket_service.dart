import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/env_config.dart';
import '../error/failures.dart';

// ═══════════════════════════════════════════════
// WebSocket Events
// ═══════════════════════════════════════════════
enum WsEvent {
  driverLocation,
  orderStatusUpdate,
  orderAssigned,
  newMessage,
  unknown,
}

class WsMessage {
  final WsEvent event;
  final Map<String, dynamic> data;
  const WsMessage({required this.event, required this.data});

  factory WsMessage.fromJson(Map<String, dynamic> json) {
    final eventStr = json['event'] as String? ?? '';
    final event = switch (eventStr) {
      'driver_location' => WsEvent.driverLocation,
      'order_status_update' => WsEvent.orderStatusUpdate,
      'order_assigned' => WsEvent.orderAssigned,
      'new_message' => WsEvent.newMessage,
      _ => WsEvent.unknown,
    };
    return WsMessage(event: event, data: json['data'] as Map<String, dynamic>? ?? {});
  }
}

// Driver location payload
class DriverLocation {
  final String driverId;
  final double lat;
  final double lng;
  final double? heading;
  final String orderId;

  const DriverLocation({
    required this.driverId,
    required this.lat,
    required this.lng,
    this.heading,
    required this.orderId,
  });

  factory DriverLocation.fromJson(Map<String, dynamic> json) => DriverLocation(
    driverId: json['driver_id'],
    lat: (json['lat'] as num).toDouble(),
    lng: (json['lng'] as num).toDouble(),
    heading: (json['heading'] as num?)?.toDouble(),
    orderId: json['order_id'],
  );
}

// ═══════════════════════════════════════════════
// WebSocket Service
// ═══════════════════════════════════════════════
class WsService {
  WebSocketChannel? _channel;
  final _messageController = StreamController<WsMessage>.broadcast();
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  bool _intentionalClose = false;
  String? _token;
  int _reconnectAttempts = 0;
  static const _maxReconnectAttempts = 5;

  Stream<WsMessage> get messages => _messageController.stream;

  Stream<DriverLocation> get driverLocations => messages
      .where((m) => m.event == WsEvent.driverLocation)
      .map((m) => DriverLocation.fromJson(m.data));

  Stream<Map<String, dynamic>> get orderUpdates => messages
      .where((m) => m.event == WsEvent.orderStatusUpdate)
      .map((m) => m.data);

  Future<void> connect(String token) async {
    _token = token;
    _intentionalClose = false;
    _reconnectAttempts = 0;
    await _connect();
  }

  Future<void> _connect() async {
    try {
      final uri = Uri.parse('${envConfig.wsUrl}?token=$_token');
      _channel = WebSocketChannel.connect(uri);

      _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      _startPing();
      _reconnectAttempts = 0;
    } catch (e) {
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic raw) {
    try {
      final json = jsonDecode(raw as String) as Map<String, dynamic>;
      final msg = WsMessage.fromJson(json);
      if (!_messageController.isClosed) {
        _messageController.add(msg);
      }
    } catch (_) {}
  }

  void _onError(Object error) {
    if (!_intentionalClose) _scheduleReconnect();
  }

  void _onDone() {
    if (!_intentionalClose) _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) return;
    _reconnectAttempts++;
    final delay = Duration(seconds: _reconnectAttempts * 2);
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, _connect);
  }

  void _startPing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      _send({'type': 'ping'});
    });
  }

  void subscribeToOrder(String orderId) {
    _send({'type': 'subscribe_order', 'order_id': orderId});
  }

  void unsubscribeFromOrder(String orderId) {
    _send({'type': 'unsubscribe_order', 'order_id': orderId});
  }

  void _send(Map<String, dynamic> data) {
    try {
      _channel?.sink.add(jsonEncode(data));
    } catch (_) {}
  }

  Future<void> disconnect() async {
    _intentionalClose = true;
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    await _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}

// ── Provider ──────────────────────────────────
final wsServiceProvider = Provider<WsService>((ref) {
  final service = WsService();
  ref.onDispose(service.dispose);
  return service;
});
