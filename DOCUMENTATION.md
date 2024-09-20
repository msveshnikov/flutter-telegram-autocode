# Messenger Clone Project Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Module Interactions](#module-interactions)
4. [Features](#features)
5. [Installation and Setup](#installation-and-setup)
6. [Usage Instructions](#usage-instructions)
7. [Development Roadmap](#development-roadmap)
8. [Contributing](#contributing)

## Project Overview

This project is a messenger application inspired by Telegram, designed to provide real-time communication capabilities across multiple platforms. The application consists of a Flutter-based frontend for cross-platform mobile support and an Express.js backend with WebSocket integration for real-time messaging.

### Tech Stack
- Frontend: Flutter (Dart)
- Backend: Express.js, Node.js (ES6 imports)
- Database: MongoDB
- Real-time Communication: WebSockets (Socket.io)
- Authentication: JWT (JSON Web Tokens)
- File Storage: Local server storage in /content folder

## Architecture

The application follows a client-server architecture with the following main components:

1. **Flutter Frontend**: 
   - Handles user interface and interaction
   - Manages local state and caching
   - Communicates with the backend via HTTP and WebSockets

2. **Express.js Backend**:
   - Provides RESTful API endpoints for non-real-time operations
   - Manages WebSocket connections for real-time messaging
   - Handles authentication and authorization
   - Interacts with the database and file storage

3. **MongoDB Database**:
   - Stores user information, chat history, and other persistent data

4. **WebSocket Server (Socket.io)**:
   - Manages real-time connections between clients and the server
   - Handles message broadcasting and real-time updates

## Module Interactions

1. **Authentication Flow**:
   - Frontend sends login/register request to backend
   - Backend validates credentials and issues JWT
   - Frontend stores JWT for subsequent requests

2. **Messaging Flow**:
   - User sends message through Flutter UI
   - Message is sent to backend via WebSocket
   - Backend processes message, stores in database
   - Backend broadcasts message to recipient(s) via WebSocket
   - Recipient's Flutter app receives and displays the message

3. **File Sharing**:
   - User selects file in Flutter app
   - File is uploaded to backend via HTTP
   - Backend stores file in /content folder
   - File metadata is stored in database
   - File reference is sent as a message through WebSocket

## Features

1. Real-time messaging using WebSockets
2. User authentication and authorization
3. Group chat functionality
4. File and media sharing
5. Push notifications for new messages
6. Message search and filtering
7. User profile management
8. End-to-end encryption (planned)

## Installation and Setup

### Prerequisites
- Flutter SDK
- Node.js and npm
- MongoDB

### Frontend Setup
1. Clone the repository
2. Navigate to the project root
3. Run `flutter pub get` to install dependencies
4. Configure the backend URL in `lib/services/websocket_service.dart`

### Backend Setup
1. Navigate to the `backend` folder
2. Run `npm install` to install dependencies
3. Create a `.env` file with necessary environment variables (e.g., MongoDB URI, JWT secret)
4. Run `npm start` to start the backend server

## Usage Instructions

1. **Running the App**:
   - For development: `flutter run`
   - For production build: `flutter build apk` (Android) or `flutter build ios` (iOS)

2. **Authentication**:
   - Launch the app and navigate to the login/register screen
   - Create an account or log in with existing credentials

3. **Messaging**:
   - After authentication, you'll be directed to the home screen
   - Select a contact or group to start a conversation
   - Type messages in the input field and send

4. **File Sharing**:
   - In a chat, tap the attachment button
   - Select the file you want to share
   - The file will be uploaded and shared in the conversation

5. **Profile Management**:
   - Navigate to the profile screen
   - Update your profile picture, name, or other settings

## Development Roadmap

1. Set up basic Flutter app structure (Completed)
2. Implement user interface for chat screens (In Progress)
3. Develop Express.js backend with WebSocket support
4. Integrate authentication system
5. Implement real-time messaging functionality
6. Add file sharing and media support
7. Implement end-to-end encryption
8. Develop group chat features
9. Add push notifications
10. Implement message search and filtering
11. Optimize performance and user experience

## Contributing

Contributions to the project are welcome. Please follow these steps:

1. Fork the repository
2. Create a new branch for your feature
3. Commit your changes
4. Push to your branch
5. Create a pull request

Please ensure your code adheres to the project's coding standards and include tests for new features.

---

This documentation provides a comprehensive overview of the Messenger Clone project. As the project evolves, remember to update this documentation to reflect any significant changes or new features.