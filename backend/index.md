# Backend Server Documentation

## Overview

This file (`backend/index.js`) serves as the main entry point for the backend server of a real-time messaging application. It sets up an Express.js server with Socket.IO for real-time communication, integrates with MongoDB for data storage, and implements various API endpoints for user authentication, messaging, file uploads, and group management.

## Dependencies

- express: Web application framework
- http: HTTP server
- socket.io: Real-time bidirectional event-based communication
- mongoose: MongoDB object modeling tool
- jsonwebtoken (jwt): JSON Web Token implementation
- bcrypt: Password hashing function
- cors: Cross-Origin Resource Sharing middleware
- dotenv: Loads environment variables from a .env file
- helmet: Helps secure Express apps with various HTTP headers
- compression: Compression middleware
- multer: Middleware for handling multipart/form-data
- path, url, fs: Node.js built-in modules for file and path operations

## Database Models

### User
- `username`: String (unique, required)
- `password`: String (required)
- `profilePicture`: String (default: '')

### Message
- `sender`: ObjectId (ref: 'User')
- `receiver`: ObjectId (ref: 'User')
- `content`: String
- `timestamp`: Date (default: current date)
- `isGroupMessage`: Boolean (default: false)
- `groupId`: ObjectId (ref: 'Group')

### Group
- `name`: String (required)
- `members`: Array of ObjectId (ref: 'User')
- `admins`: Array of ObjectId (ref: 'User')

## Middleware

### authenticateToken
Verifies the JWT token in the request header.

**Usage:**
```javascript
app.get('/protected-route', authenticateToken, (req, res) => {
  // Protected route logic
});
```

## API Endpoints

### POST /register
Registers a new user.

**Body:**
- `username`: String
- `password`: String

**Response:**
- 201: User registered successfully
- 500: Error registering user

### POST /login
Authenticates a user and returns a JWT token.

**Body:**
- `username`: String
- `password`: String

**Response:**
- 200: `{ accessToken: String }`
- 400: Cannot find user
- 500: Server error

### GET /messages
Retrieves messages for the authenticated user.

**Headers:**
- `Authorization`: Bearer token

**Response:**
- 200: Array of message objects
- 500: Error fetching messages

### POST /messages
Sends a new message.

**Headers:**
- `Authorization`: Bearer token

**Body:**
- `receiver`: String (username of receiver)
- `content`: String

**Response:**
- 201: Message sent successfully
- 500: Error sending message

### POST /upload
Uploads a file.

**Headers:**
- `Authorization`: Bearer token

**Body:**
- `file`: File (multipart/form-data)

**Response:**
- 200: `{ filename: String }`
- 400: No file uploaded

### GET /file/:filename
Retrieves a file by filename.

**Headers:**
- `Authorization`: Bearer token

**Response:**
- 200: File content
- 404: File not found

### POST /groups
Creates a new group.

**Headers:**
- `Authorization`: Bearer token

**Body:**
- `name`: String
- `members`: Array of user IDs

**Response:**
- 201: Created group object
- 500: Error creating group

### GET /groups
Retrieves groups for the authenticated user.

**Headers:**
- `Authorization`: Bearer token

**Response:**
- 200: Array of group objects
- 500: Error fetching groups

### POST /groups/:groupId/messages
Sends a message to a group.

**Headers:**
- `Authorization`: Bearer token

**Parameters:**
- `groupId`: String

**Body:**
- `content`: String

**Response:**
- 201: Group message sent successfully
- 404: Group not found
- 500: Error sending group message

## Socket.IO Events

### Connection
Authenticates the socket connection using JWT.

### newMessage
Emitted when a new private message is sent.

### newGroupMessage
Emitted when a new group message is sent.

## Server Initialization

The server listens on the port specified in the environment variables (default: 3000).

```javascript
server.listen(PORT, () => console.log(`Server running on port ${PORT}`));
```

## Project Structure

This file is part of the backend directory in the project structure. It interacts with the frontend Flutter application, particularly with the services defined in `lib/services/`:

- `auth_service.dart`: Likely handles authentication requests to `/register` and `/login`
- `chat_service.dart`: Probably manages message-related API calls to `/messages`
- `websocket_service.dart`: Likely establishes and maintains the Socket.IO connection

The frontend screens in `lib/screens/` would utilize these services to interact with the backend API and real-time events.