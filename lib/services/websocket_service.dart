import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class WebSocketService extends ChangeNotifier {
  static const String _baseUrl = 'http://localhost:3000';
  late IO.Socket _socket;
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  Future<void> connect() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    _socket = IO.io(_baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {'token': token},
    });

    _socket.connect();

    _socket.on('connect', (_) {
      print('Connected to WebSocket server');
    });

    _socket.on('message', (data) {
      _messageController.add(data);
    });

    _socket.on('disconnect', (_) {
      print('Disconnected from WebSocket server');
    });

    _socket.on('error', (error) {
      print('WebSocket error: $error');
    });
  }

  void sendMessage(Map<String, dynamic> message) {
    _socket.emit('sendMessage', message);
  }

  void joinGroup(String groupId) {
    _socket.emit('joinGroup', {'groupId': groupId});
  }

  void leaveGroup(String groupId) {
    _socket.emit('leaveGroup', {'groupId': groupId});
  }

  void disconnect() {
    _socket.disconnect();
    _messageController.close();
  }

  void onNewMessage(Function(dynamic message) callback) {
    _socket.on('message', (data) => callback(data));
  }

  void sendTypingStatus(String chatId, bool isTyping) {
    _socket.emit('typing', {'chatId': chatId, 'isTyping': isTyping});
  }

  void onTypingStatus(Function(Map<String, dynamic> status) callback) {
    _socket.on('typing', (data) => callback(data));
  }

  void sendReadReceipt(String messageId) {
    _socket.emit('readReceipt', {'messageId': messageId});
  }

  void onReadReceipt(Function(Map<String, dynamic> receipt) callback) {
    _socket.on('readReceipt', (data) => callback(data));
  }

  void subscribeToUserStatus(String userId) {
    _socket.emit('subscribeUserStatus', {'userId': userId});
  }

  void onUserStatusChange(Function(Map<String, dynamic> status) callback) {
    _socket.on('userStatusChange', (data) => callback(data));
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}