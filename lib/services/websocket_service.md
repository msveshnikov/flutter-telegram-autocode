# WebSocketService Documentation

## Overview

The `WebSocketService` class is a crucial component of the messenger application, responsible for managing real-time communication between the client and the server using WebSockets. It is located in `lib/services/websocket_service.dart` and utilizes the `socket_io_client` package for WebSocket functionality.

This service extends `ChangeNotifier`, allowing it to notify listeners of changes in the WebSocket connection status or incoming messages. It provides methods for connecting to the server, sending and receiving messages, managing group chats, handling typing indicators, and tracking read receipts.

## Class: WebSocketService

### Properties

- `_baseUrl`: The base URL of the WebSocket server (default: 'http://localhost:3000').
- `_socket`: The Socket.IO client instance.
- `_messageController`: A `StreamController` for broadcasting incoming messages.
- `messageStream`: A getter that provides access to the message stream.

### Methods

#### `connect()`

Establishes a connection to the WebSocket server.

**Returns:** `Future<void>`

**Usage:**
```dart
final webSocketService = WebSocketService();
await webSocketService.connect();
```

#### `sendMessage(Map<String, dynamic> message)`

Sends a message to the server.

**Parameters:**
- `message`: A map containing the message data.

**Usage:**
```dart
webSocketService.sendMessage({'text': 'Hello, world!', 'chatId': '123'});
```

#### `joinGroup(String groupId)`

Joins a specific chat group.

**Parameters:**
- `groupId`: The ID of the group to join.

**Usage:**
```dart
webSocketService.joinGroup('group123');
```

#### `leaveGroup(String groupId)`

Leaves a specific chat group.

**Parameters:**
- `groupId`: The ID of the group to leave.

**Usage:**
```dart
webSocketService.leaveGroup('group123');
```

#### `disconnect()`

Disconnects from the WebSocket server and closes the message stream.

**Usage:**
```dart
webSocketService.disconnect();
```

#### `onNewMessage(Function(dynamic message) callback)`

Registers a callback function to handle incoming messages.

**Parameters:**
- `callback`: A function that will be called with the incoming message data.

**Usage:**
```dart
webSocketService.onNewMessage((message) {
  print('New message received: $message');
});
```

#### `sendTypingStatus(String chatId, bool isTyping)`

Sends the user's typing status for a specific chat.

**Parameters:**
- `chatId`: The ID of the chat.
- `isTyping`: A boolean indicating whether the user is currently typing.

**Usage:**
```dart
webSocketService.sendTypingStatus('chat123', true);
```

#### `onTypingStatus(Function(Map<String, dynamic> status) callback)`

Registers a callback function to handle typing status updates.

**Parameters:**
- `callback`: A function that will be called with the typing status data.

**Usage:**
```dart
webSocketService.onTypingStatus((status) {
  print('Typing status update: $status');
});
```

#### `sendReadReceipt(String messageId)`

Sends a read receipt for a specific message.

**Parameters:**
- `messageId`: The ID of the message that has been read.

**Usage:**
```dart
webSocketService.sendReadReceipt('msg123');
```

#### `onReadReceipt(Function(Map<String, dynamic> receipt) callback)`

Registers a callback function to handle incoming read receipts.

**Parameters:**
- `callback`: A function that will be called with the read receipt data.

**Usage:**
```dart
webSocketService.onReadReceipt((receipt) {
  print('Read receipt received: $receipt');
});
```

#### `subscribeToUserStatus(String userId)`

Subscribes to status updates for a specific user.

**Parameters:**
- `userId`: The ID of the user to subscribe to.

**Usage:**
```dart
webSocketService.subscribeToUserStatus('user123');
```

#### `onUserStatusChange(Function(Map<String, dynamic> status) callback)`

Registers a callback function to handle user status changes.

**Parameters:**
- `callback`: A function that will be called with the user status data.

**Usage:**
```dart
webSocketService.onUserStatusChange((status) {
  print('User status changed: $status');
});
```

#### `dispose()`

Cleans up resources when the service is no longer needed. This method is called automatically when the object is disposed of by the Flutter framework.

## Integration in the Project

The `WebSocketService` is a key component in the `services` directory of the messenger application. It works in conjunction with other services like `AuthService` and `ChatService` to provide real-time messaging capabilities.

To use this service in other parts of the application, you would typically:

1. Initialize it in the main app widget or a service locator.
2. Use it in the chat screens (e.g., `chat_screen.dart`) to send and receive messages.
3. Utilize it in the home screen (`home_screen.dart`) to display real-time updates for chats and user statuses.

Example of initializing the service:

```dart
// In main.dart or a service locator
final webSocketService = WebSocketService();
await webSocketService.connect();

// Make it available to the widget tree
return ChangeNotifierProvider(
  create: (_) => webSocketService,
  child: MaterialApp(
    // ... app configuration
  ),
);
```

By providing this service through a `ChangeNotifierProvider`, you can easily access it in any widget using `Provider.of<WebSocketService>(context)` or the `Consumer` widget.