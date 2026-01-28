import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

import '../config/api_config.dart';
import '../repository/seat_reservation_repository.dart';

/// Connection status for the WebSocket.
enum WebSocketConnectionStatus {
  connected,
  disconnected,
  connecting,
}

/// Event payload for seat updates coming from the WebSocket.
class SeatUpdateEvent {
  SeatUpdateEvent({
    required this.seatId,
    required this.status,
    this.userId,
    this.isMine = false,
    this.expiresAt,
    this.previouslyReservedBy,
  });

  final int seatId;
  final SeatStatus status;
  final int? userId;
  final bool isMine;
  final DateTime? expiresAt;
  final int? previouslyReservedBy;

  factory SeatUpdateEvent.fromJson(Map<String, dynamic> json) {
    final statusStr = (json['status'] ?? 'available').toString();
    return SeatUpdateEvent(
      seatId: (json['seat_id'] as num).toInt(),
      status: seatStatusFromString(statusStr),
      userId: (json['user_id'] as num?)?.toInt(),
      isMine: json['is_mine'] == true,
      expiresAt: json['expires_at'] != null ? DateTime.tryParse(json['expires_at'].toString()) : null,
      previouslyReservedBy: (json['previously_reserved_by'] as num?)?.toInt(),
    );
  }
}

/// Service that manages the WebSocket connection for a specific screening,
/// mirroring the Angular `ScreeningWebSocketService`.
class ScreeningWebSocketService {
  final _seatUpdatesController = StreamController<SeatUpdateEvent>.broadcast();
  final _connectionStatusController =
      StreamController<WebSocketConnectionStatus>.broadcast();

  WebSocketChannel? _channel;
  int? _currentScreeningId;
  String? _currentToken;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;
  final Duration _baseReconnectDelay = const Duration(seconds: 2);
  Timer? _reconnectTimer;

  Stream<SeatUpdateEvent> get seatUpdatesStream =>
      _seatUpdatesController.stream;

  Stream<WebSocketConnectionStatus> get connectionStatusStream =>
      _connectionStatusController.stream;

  WebSocketConnectionStatus _status = WebSocketConnectionStatus.disconnected;

  WebSocketConnectionStatus get status => _status;

  bool get isConnected =>
      _channel != null && _status == WebSocketConnectionStatus.connected;

  /// Connect to the WebSocket for a given screening id and JWT token.
  ///
  /// Endpoint (same as Angular):
  ///   ws://host:8000/ws/screenings/{screening_id}?token=<JWT>
  void connect({required int screeningId, required String token}) {
    _currentScreeningId = screeningId;
    _currentToken = token;

    if (_channel != null &&
        _status == WebSocketConnectionStatus.connected) {
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    _setStatus(WebSocketConnectionStatus.connecting);

    try {
      // Build WebSocket base URL from ApiConfig.baseUrl, replacing http(s) and
      // stripping `/api/v1` like the Angular service does.
      final httpBase = ApiConfig.baseUrl;
      final wsBase = httpBase.replaceFirst('http', 'ws').replaceFirst('/api/v1', '');
      final url = '$wsBase/ws/screenings/$screeningId?token=$token';

      _channel = WebSocketChannel.connect(Uri.parse(url));

      _channel!.stream.listen(
        _onMessage,
        onDone: _onDone,
        onError: _onError,
        cancelOnError: true,
      );
    } catch (e) {
      _setStatus(WebSocketConnectionStatus.disconnected);
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic raw) {
    try {
      _setStatus(WebSocketConnectionStatus.connected);

      final data = jsonDecode(raw.toString());
      if (data is Map<String, dynamic>) {
        final type = data['type']?.toString();
        if (type == 'seat_update') {
          _seatUpdatesController.add(SeatUpdateEvent.fromJson(data));
        } else if (type == 'bulk_seat_update' && data['updates'] is List) {
          final updates = data['updates'] as List<dynamic>;
          for (final u in updates) {
            if (u is Map<String, dynamic>) {
              _seatUpdatesController.add(
                SeatUpdateEvent.fromJson(<String, dynamic>{
                  'type': 'seat_update',
                  'seat_id': u['seat_id'],
                  'status': u['status'],
                  'user_id': u['reserved_by'],
                  'is_mine': u['is_mine'],
                  'expires_at': u['expires_at'],
                }),
              );
            }
          }
        }
      }
    } catch (_) {
      // ignore malformed messages; keep connection alive
    }
  }

  void _onDone() {
    _setStatus(WebSocketConnectionStatus.disconnected);
    _channel = null;
    if (_currentScreeningId != null && _currentToken != null) {
      _scheduleReconnect();
    }
  }

  void _onError(Object error) {
    _setStatus(WebSocketConnectionStatus.disconnected);
    _channel = null;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) return;
    _reconnectAttempts++;

    final delay = _baseReconnectDelay * (1 << (_reconnectAttempts - 1));
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      if (_currentScreeningId != null && _currentToken != null) {
        connect(screeningId: _currentScreeningId!, token: _currentToken!);
      }
    });
  }

  void _setStatus(WebSocketConnectionStatus newStatus) {
    if (_status == newStatus) return;
    _status = newStatus;
    _connectionStatusController.add(newStatus);
    if (newStatus == WebSocketConnectionStatus.connected) {
      _reconnectAttempts = 0;
    }
  }

  /// Disconnect intentionally (no reconnect).
  void disconnect() {
    _currentScreeningId = null;
    _currentToken = null;
    _reconnectAttempts = 0;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    if (_channel != null) {
      _channel!.sink.close(ws_status.normalClosure, 'User disconnected');
      _channel = null;
    }
    _setStatus(WebSocketConnectionStatus.disconnected);
  }

  void dispose() {
    disconnect();
    _seatUpdatesController.close();
    _connectionStatusController.close();
  }
}

