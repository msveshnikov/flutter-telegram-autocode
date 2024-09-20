# Messenger Clone of Telegram with Express.js Backend and WebSockets

## Project Overview

This project aims to create a messenger application inspired by Telegram, utilizing Express.js for the backend and WebSockets for real-time communication. The frontend is built using Flutter, providing a cross-platform mobile application.

## Features

-   Real-time messaging using WebSockets
-   User authentication and authorization
-   Group chat functionality
-   File and media sharing
-   Push notifications for new messages
-   Message search and filtering
-   User profile management

## Tech Stack

-   Backend: Express.js, Node.js, use ES6 imports
-   Frontend: Flutter (Dart)
-   Database: MongoDB
-   WebSockets: Socket.io
-   Authentication: JWT (JSON Web Tokens)
-   File Storage: local on server in /content folder

## Project Structure

The project follows a standard Flutter application structure with additional backend components:

-   `lib/`: Contains the main Dart code for the Flutter application
-   `android/`: Android-specific configuration and native code
-   `backend/`: Express.js server and WebSocket implementation (to be added)

## Getting Started

1. Clone the repository
2. Set up the Flutter development environment
3. Install dependencies: `flutter pub get`
4. Run the application: `flutter run`

## Development Roadmap

1. Set up basic Flutter app structure
2. Implement user interface for chat screens
3. Develop Express.js backend with WebSocket support
4. Integrate authentication system
5. Implement real-time messaging functionality
6. Add file sharing and media support
7. Implement end-to-end encryption
8. Develop group chat features
9. Add push notifications
10. Implement message search and filtering
11. Optimize performance and user experience

# TODO

-   fix references/bugs:
[{
	"resource": "/C:/My-progs/Dart/messenger/lib/main.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "not_enough_positional_arguments",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/not_enough_positional_arguments",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "2 positional arguments expected by 'ChatService.new', but 0 found.\nTry adding the missing arguments.",
	"source": "dart",
	"startLineNumber": 16,
	"startColumn": 45,
	"endLineNumber": 16,
	"endColumn": 46
},{
	"resource": "/C:/My-progs/Dart/messenger/lib/main.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "undefined_identifier",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_identifier",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "Undefined name 'ciurr'.\nTry correcting the name to one that is defined, or defining the name.",
	"source": "dart",
	"startLineNumber": 39,
	"startColumn": 54,
	"endLineNumber": 39,
	"endColumn": 59
},{
	"resource": "/C:/My-progs/Dart/messenger/lib/main.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": "invalid_constant",
	"severity": 8,
	"message": "Invalid constant value.",
	"source": "dart",
	"startLineNumber": 39,
	"startColumn": 54,
	"endLineNumber": 39,
	"endColumn": 59
},{
	"resource": "/C:/My-progs/Dart/messenger/lib/main.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "missing_required_argument",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/missing_required_argument",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "The named parameter 'user' is required, but there's no corresponding argument.\nTry adding the required argument.",
	"source": "dart",
	"startLineNumber": 40,
	"startColumn": 40,
	"endLineNumber": 40,
	"endColumn": 53
},{
	"resource": "/C:/My-progs/Dart/messenger/lib/main.dart",
	"owner": "_generated_diagnostic_collection_name_#3",
	"code": {
		"value": "undefined_method",
		"target": {
			"$mid": 1,
			"path": "/diagnostics/undefined_method",
			"scheme": "https",
			"authority": "dart.dev"
		}
	},
	"severity": 8,
	"message": "The method 'authStateChanges' isn't defined for the type 'AuthService'.\nTry correcting the name to the name of an existing method, or defining a method named 'authStateChanges'.",
	"source": "dart",
	"startLineNumber": 68,
	"startColumn": 33,
	"endLineNumber": 68,
	"endColumn": 49
}]