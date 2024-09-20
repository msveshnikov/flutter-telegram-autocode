# ChatService Documentation

## Overview

The `ChatService` class is a core component of the messenger application, responsible for managing chat-related operations. It interacts with the backend server, handles WebSocket connections for real-time messaging, and provides methods for various chat functionalities.

This service is part of the `lib/services` directory and works in conjunction with `AuthService` and `WebSocketService` to provide a comprehensive chat experience.

## Class: ChatService

### Properties

- `_baseUrl`: The base URL for the backend API.
- `_authService`: An instance of `AuthService` for authentication-related operations.
- `_webSocketService`: An instance of `WebSocketService` for real-time communication.
- `_messagesController`: A `StreamController` for broadcasting message updates.

### Constructor

```dart
ChatService(this._authService, this._webSocketService);
```

Initializes a new instance of `ChatService` with the provided `AuthService` and `WebSocketService`.

### Methods

#### initialize()

```dart
Future<void> initialize() async
```

Initializes the chat service by connecting to the WebSocket and fetching initial messages.

#### _fetchMessages()

```dart
Future<void> _fetchMessages() async
```

Private method to fetch messages from the server and update the message stream.

#### _handleNewMessage(Map<String, dynamic> data)

```dart
void _handleNewMessage(Map<String, dynamic> data)
```

Handles new messages received from the WebSocket and updates the message stream.

#### sendMessage(String content)

```dart
void sendMessage(String content)
```

Sends a new message through the WebSocket.

**Parameters:**
- `content`: The content of the message to be sent.

#### uploadFile(File file)

```dart
Future<void> uploadFile(File file) async
```

Uploads a file to the server.

**Parameters:**
- `file`: The `File` object to be uploaded.

#### createGroup(String groupName, List<String> members)

```dart
Future<void> createGroup(String groupName, List<String> members) async
```

Creates a new group chat.

**Parameters:**
- `groupName`: The name of the group to be created.
- `members`: A list of member usernames to be added to the group.

#### searchMessages(String query)

```dart
Future<List<Message>> searchMessages(String query) async
```

Searches for messages based on the provided query.

**Parameters:**
- `query`: The search query string.

**Returns:**
A list of `Message` objects matching the search query.

#### getChats()

```dart
Future<List<Chat>> getChats() async
```

Retrieves the list of chats for the current user.

**Returns:**
A list of `Chat` objects representing the user's chats.

#### dispose()

```dart
void dispose()
```

Closes the message stream controller and performs cleanup.

## Classes: Message and Chat

### Message

Represents a single message in the chat.

#### Properties

- `id`: Unique identifier for the message.
- `sender`: The username of the message sender.
- `content`: The content of the message.
- `timestamp`: The date and time when the message was sent.

#### Constructor

```dart
Message({
  required this.id,
  required this.sender,
  required this.content,
  required this.timestamp,
});
```

#### Factory Method

```dart
factory Message.fromJson(Map<String, dynamic> json)
```

Creates a `Message` instance from a JSON object.

### Chat

Represents a chat conversation, which can be either a one-on-one chat or a group chat.

#### Properties

- `id`: Unique identifier for the chat.
- `name`: The name of the chat (for group chats) or the other participant's name (for one-on-one chats).
- `participants`: A list of usernames of the chat participants.
- `lastMessage`: The most recent message in the chat (optional).

#### Constructor

```dart
Chat({
  required this.id,
  required this.name,
  required this.participants,
  this.lastMessage,
});
```

#### Factory Method

```dart
factory Chat.fromJson(Map<String, dynamic> json)
```

Creates a `Chat` instance from a JSON object.

## Usage Examples

### Initializing the ChatService

```dart
final authService = AuthService();
final webSocketService = WebSocketService();
final chatService = ChatService(authService, webSocketService);

await chatService.initialize();
```

### Sending a Message

```dart
chatService.sendMessage('Hello, how are you?');
```

### Uploading a File

```dart
File imageFile = File('path/to/image.jpg');
await chatService.uploadFile(imageFile);
```

### Creating a Group

```dart
List<String> members = ['user1', 'user2', 'user3'];
await chatService.createGroup('My Group Chat', members);
```

### Searching Messages

```dart
List<Message> results = await chatService.searchMessages('important');
```

### Getting User's Chats

```dart
List<Chat> userChats = await chatService.getChats();
```

## Conclusion

The `ChatService` class provides a comprehensive set of methods for managing chat functionality in the messenger application. It handles real-time messaging, file uploads, group creation, and message searching, making it a crucial component of the chat system.