import 'package:flutter/material.dart';
import 'package:messenger/services/chat_service.dart';
import 'package:messenger/services/websocket_service.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ChatService _chatService;
  late WebSocketService _webSocketService;
  List<Chat> _chats = [];

  @override
  void initState() {
    super.initState();
    _chatService = Provider.of<ChatService>(context, listen: false);
    _webSocketService = Provider.of<WebSocketService>(context, listen: false);
    _loadChats();
    _setupWebSocket();
  }

  Future<void> _loadChats() async {
    final chats = await _chatService.getChats();
    setState(() {
      _chats = chats;
    });
  }

  void _setupWebSocket() {
    _webSocketService.messageStream.listen((message) {
      _updateChatWithNewMessage(message);
    });
  }

  void _updateChatWithNewMessage(Map<String, dynamic> message) {
    setState(() {
      final chatIndex =
          _chats.indexWhere((chat) => chat.id == message['chatId']);
      if (chatIndex != -1) {
        final updatedChat = Chat(
          id: _chats[chatIndex].id,
          name: _chats[chatIndex].name,
          participants: _chats[chatIndex].participants,
          lastMessage: Message.fromJson(message),
        );
        _chats[chatIndex] = updatedChat;
        _chats.insert(0, _chats.removeAt(chatIndex));
      } else {
        _loadChats();
      }
    });
  }

  void _createNewChat() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        String chatName = '';
        List<String> participants = [];
        return AlertDialog(
          title: const Text('Create New Chat'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Chat Name'),
                onChanged: (value) => chatName = value,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                    labelText: 'Participants (comma-separated)'),
                onChanged: (value) => participants =
                    value.split(',').map((e) => e.trim()).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context)
                  .pop({'name': chatName, 'participants': participants}),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      try {
        await _chatService.createGroup(result['name'], result['participants']);
        _loadChats();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create chat: $e')),
        );
      }
    }
  }

  void _searchChats() async {
    final String? query = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String searchQuery = '';
        return AlertDialog(
          title: const Text('Search Chats'),
          content: TextField(
            onChanged: (value) => searchQuery = value,
            decoration: const InputDecoration(hintText: 'Enter search query'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(searchQuery),
              child: const Text('Search'),
            ),
          ],
        );
      },
    );

    if (query != null && query.isNotEmpty) {
      final searchResults = await _chatService.searchMessages(query);
      setState(() {
        _chats = searchResults.map((message) {
          return Chat(
            id: message.id,
            name: 'Search Result',
            participants: [],
            lastMessage: message,
          );
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _searchChats,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewChat,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _chats.length,
        itemBuilder: (context, index) {
          final chat = _chats[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(chat.name[0]),
            ),
            title: Text(chat.name),
            subtitle: Text(
              chat.lastMessage?.content ?? 'No messages yet',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: chat.lastMessage != null
                ? Text(
                    '${chat.lastMessage!.timestamp.hour}:${chat.lastMessage!.timestamp.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.grey),
                  )
                : null,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/chat',
                arguments: chat,
              ).then((_) => _loadChats());
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewChat,
        child: const Icon(Icons.message),
      ),
    );
  }
}
