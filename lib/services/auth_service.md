# AuthService Documentation

## Overview

The `auth_service.dart` file is a crucial component of the authentication system in this Flutter application. It provides a service class `AuthService` that manages user authentication, registration, and profile management. The file also defines a `User` model class to represent user data.

This service interacts with a backend API (presumably running on `http://localhost:3000`) to perform various authentication-related operations. It uses the `http` package for API requests and `shared_preferences` for local token storage.

## Classes

### User

A model class representing a user in the application.

#### Properties

- `id` (String): Unique identifier for the user
- `username` (String): User's username
- `email` (String): User's email address
- `phoneNumber` (String?): User's phone number (optional)
- `profileImageUrl` (String?): URL of the user's profile image (optional)

#### Methods

- `User.fromJson(Map<String, dynamic> json)`: Factory constructor to create a User instance from JSON data
- `Map<String, dynamic> toJson()`: Converts the User instance to a JSON-compatible Map

### AuthService

A service class that extends `ChangeNotifier` to manage authentication state and operations.

#### Properties

- `currentUser` (User?): The currently authenticated user (null if not authenticated)
- `isLoading` (bool): Indicates whether the service is currently performing an operation

#### Methods

##### `Future<void> initialize()`

Initializes the auth service by checking for an existing auth token and fetching the user's data if available.

##### `Future<User> register(String username, String email, String password)`

Registers a new user with the provided credentials.

- Parameters:
  - `username`: The desired username
  - `email`: The user's email address
  - `password`: The user's password
- Returns: A `User` object representing the newly registered user

##### `Future<User> signIn(String email, String password)`

Signs in a user with the provided credentials.

- Parameters:
  - `email`: The user's email address
  - `password`: The user's password
- Returns: A `User` object representing the authenticated user

##### `Future<void> signOut()`

Signs out the currently authenticated user.

##### `Future<User> updateProfile(User updatedUser, File? profileImage)`

Updates the user's profile information and optionally uploads a new profile image.

- Parameters:
  - `updatedUser`: A `User` object containing the updated information
  - `profileImage`: An optional `File` object representing the new profile image
- Returns: A `User` object with the updated information

##### `Future<void> changePassword(String currentPassword, String newPassword)`

Changes the user's password.

- Parameters:
  - `currentPassword`: The user's current password
  - `newPassword`: The desired new password

##### `Future<User?> getCurrentUser()`

Retrieves the current user's information, either from memory or by fetching from the server.

- Returns: A `User` object if authenticated, or `null` if not authenticated

##### `Future<void> logout()`

Logs out the current user and clears the authentication token.

## Usage Examples

```dart
// Initialize the auth service
final authService = AuthService();
await authService.initialize();

// Register a new user
try {
  final newUser = await authService.register('johndoe', 'john@example.com', 'password123');
  print('Registered user: ${newUser.username}');
} catch (e) {
  print('Registration failed: $e');
}

// Sign in a user
try {
  final user = await authService.signIn('john@example.com', 'password123');
  print('Signed in as: ${user.username}');
} catch (e) {
  print('Sign in failed: $e');
}

// Update user profile
final updatedUser = User(
  id: authService.currentUser!.id,
  username: 'johndoe_updated',
  email: 'john_new@example.com',
  phoneNumber: '1234567890'
);
try {
  final result = await authService.updateProfile(updatedUser, null);
  print('Profile updated: ${result.username}');
} catch (e) {
  print('Profile update failed: $e');
}

// Change password
try {
  await authService.changePassword('oldpassword', 'newpassword123');
  print('Password changed successfully');
} catch (e) {
  print('Password change failed: $e');
}

// Sign out
await authService.signOut();
print('Signed out');
```

## Project Context

This `AuthService` is a core component of the application's authentication system. It is likely used by various screens in the `lib/screens` directory, particularly `auth_screen.dart` and `profile_screen.dart`, to manage user authentication and profile information. The service interacts with the backend API (defined in the `backend` directory) to perform its operations.

The `AuthService` class extends `ChangeNotifier`, which suggests that it's probably used in conjunction with Flutter's `Provider` package for state management throughout the app.