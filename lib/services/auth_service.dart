import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String? phoneNumber;
  final String? profileImageUrl;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.phoneNumber,
    this.profileImageUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      profileImageUrl: json['profileImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
    };
  }
}

class AuthService extends ChangeNotifier {
  static const String baseUrl = 'http://localhost:3000';
  static const String tokenKey = 'auth_token';

  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  get userStream => null;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    final token = await _getToken();
    if (token != null) {
      try {
        final user = await _getUserFromToken(token);
        _currentUser = user;
      } catch (e) {
        await _clearToken();
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<User> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'email': email, 'password': password}),
    );

    if (response.statusCode == 201) {
      return signIn(email, password);
    } else {
      throw Exception('Failed to register user');
    }
  }

  Future<User> signIn(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final token = data['accessToken'];
      await _setToken(token);
      final user = await _getUserFromToken(token);
      _currentUser = user;
      notifyListeners();
      return user;
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<void> signOut() async {
    await _clearToken();
    _currentUser = null;
    notifyListeners();
  }

  Future<User> updateProfile(User updatedUser, File? profileImage) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/user'));
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['username'] = updatedUser.username;
    request.fields['email'] = updatedUser.email;
    if (updatedUser.phoneNumber != null) {
      request.fields['phoneNumber'] = updatedUser.phoneNumber!;
    }

    if (profileImage != null) {
      request.files.add(await http.MultipartFile.fromPath('profileImage', profileImage.path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final updatedUser = User.fromJson(jsonDecode(response.body));
      _currentUser = updatedUser;
      notifyListeners();
      return updatedUser;
    } else {
      throw Exception('Failed to update profile');
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.put(
      Uri.parse('$baseUrl/user/password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to change password');
    }
  }

  Future<User> _getUserFromToken(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get user info');
    }
  }

  Future<void> _setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  Future<User?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    final token = await _getToken();
    if (token != null) {
      try {
        return await _getUserFromToken(token);
      } catch (e) {
        await _clearToken();
      }
    }
    return null;
  }

  Future<void> logout() async {
    await _clearToken();
    _currentUser = null;
    notifyListeners();
  }

  getToken() {}
}