import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';

enum WebSocketConnectionStatus { connected, disconnected, connecting }

class SeatUpdateEvent {
  final int seatId;
  final String status;
  final String rowLabel;
  final int seatNumber;
  final int? reservedBy;
  final bool isMine;

  SeatUpdateEvent({
    required this.seatId,
    required this.status,
    required this.rowLabel,
    required this.seatNumber,
    this.reservedBy,
    this.isMine = false,
  });

  factory SeatUpdateEvent.fromJson(Map<String, dynamic> json) {
    return SeatUpdateEvent(
      seatId: json['seat_id'] ?? 0,
      status: json['status'] ?? 'available',
      rowLabel: json['row_label'] ?? 'A',
      seatNumber: json['seat_number'] ?? 1,
      reservedBy: json['reserved_by'],
      isMine: json['is_mine'] ?? false,
    );
  }
}

class ScreeningWebSocketService {
  WebSocketChannel? _channel;
  final _seatUpdateController = StreamController<SeatUpdateEvent>.broadcast();
  final _statusController = StreamController<WebSocketConnectionStatus>.broadcast();

  Stream<SeatUpdateEvent> get seatUpdates => _seatUpdateController.stream;
  Stream<WebSocketConnectionStatus> get connectionStatus => _statusController.stream;

  static String get wsBaseUrl {
    if (Platform.isAndroid) {
      return 'ws://10.0.2.2:8000';
    } else if (Platform.isIOS) {
      return 'ws://localhost:8000';
    }
    return 'ws://localhost:8000';
  }

  void connect(int screeningId, String token) {
    try {
      _statusController.add(WebSocketConnectionStatus.connecting);
      final url = Uri.parse('$wsBaseUrl/api/v1/ws/seat-updates/$screeningId?token=$token');
      _channel = WebSocketChannel.connect(url);

      _statusController.add(WebSocketConnectionStatus.connected);

      _channel!.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message);
            if (data['type'] == 'seat_update') {
              final event = SeatUpdateEvent.fromJson(data['data']);
              _seatUpdateController.add(event);
            }
          } catch (e) {
            print('Error parsing WebSocket message: $e');
          }
        },
        onError: (error) {
          _statusController.add(WebSocketConnectionStatus.disconnected);
        },
        onDone: () {
          _statusController.add(WebSocketConnectionStatus.disconnected);
        },
        cancelOnError: false,
      );
    } catch (e) {
      _statusController.add(WebSocketConnectionStatus.disconnected);
    }
  }

  void dispose() {
    _channel?.sink.close();
    _seatUpdateController.close();
    _statusController.close();
  }
}
