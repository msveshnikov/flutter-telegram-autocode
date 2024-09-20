import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:messenger/services/auth_service.dart';
import 'package:messenger/services/websocket_service.dart';

class ChatService {
  final String _baseUrl = 'http://localhost:3000';
  final AuthService _authService;
  final WebSocketService _webSocketService;
  final StreamController<List<Message>> _messagesController =
      StreamController<List<Message>>.broadcast();

  ChatService(this._authService, this._webSocketService);

  Stream<List<Message>> get messagesStream => _messagesController.stream;

  Future<void> initialize() async {
    await _webSocketService.connect();
    _webSocketService.messageStream.listen(_handleNewMessage);
    await _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/messages'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> messagesJson = json.decode(response.body);
        final messages =
            messagesJson.map((json) => Message.fromJson(json)).toList();
        _messagesController.add(messages);
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }

  void _handleNewMessage(Map<String, dynamic> data) {
    final message = Message.fromJson(data);
    // _messagesController.add([..._messagesController.value, message]);
  }

  void sendMessage(String content) {
    _webSocketService.sendMessage({'content': content});
  }

  Future<void> uploadFile(File file) async {
    try {
      final token = await _authService.getToken();
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/upload'));
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      request.headers['Authorization'] = 'Bearer $token';

      var response = await request.send();
      if (response.statusCode == 200) {
        print('File uploaded successfully');
      } else {
        throw Exception('Failed to upload file');
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  Future<void> createGroup(String groupName, List<String> members) async {
    try {
      final token = await _authService.getToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/groups'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': groupName,
          'members': members,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to create group');
      }
    } catch (e) {
      print('Error creating group: $e');
    }
  }

  Future<List<Message>> searchMessages(String query) async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/messages/search?q=$query'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> messagesJson = json.decode(response.body);
        return messagesJson.map((json) => Message.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search messages');
      }
    } catch (e) {
      print('Error searching messages: $e');
      return [];
    }
  }

  Future<List<Chat>> getChats() async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/chats'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> chatsJson = json.decode(response.body);
        return chatsJson.map((json) => Chat.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load chats');
      }
    } catch (e) {
      print('Error fetching chats: $e');
      return [];
    }
  }

  void dispose() {
    _messagesController.close();
  }
}

class Message {
  final String id;
  final String sender;
  final String content;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.sender,
    required this.content,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'],
      sender: json['sender']['username'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class Chat {
  final String id;
  final String name;
  final List<String> participants;
  final Message? lastMessage;

  Chat({
    required this.id,
    required this.name,
    required this.participants,
    this.lastMessage,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['_id'],
      name: json['name'],
      participants: List<String>.from(json['participants']),
      lastMessage: json['lastMessage'] != null
          ? Message.fromJson(json['lastMessage'])
          : null,
    );
  }
}