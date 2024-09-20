import 'package:flutter/material.dart';
import 'package:messenger/screens/home_screen.dart';
import 'package:messenger/screens/chat_screen.dart';
import 'package:messenger/screens/profile_screen.dart';
import 'package:messenger/screens/auth_screen.dart';
import 'package:messenger/services/auth_service.dart';
import 'package:messenger/services/chat_service.dart';
import 'package:messenger/services/websocket_service.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ProxyProvider<AuthService, ChatService>(
          update: (_, authService, __) => ChatService(authService, WebSocketService()),
        ),
        ProxyProvider<AuthService, WebSocketService>(
          update: (_, authService, __) => WebSocketService(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Messenger Clone',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: const AuthWrapper(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/chat': (context) => ChatScreen(user: Provider.of<AuthService>(context, listen: false).currentUser!),
        '/profile': (context) => ProfileScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final chatService = Provider.of<ChatService>(context);
    final webSocketService = Provider.of<WebSocketService>(context);

    return FutureBuilder(
      future: Future.wait([
        authService.initialize(),
        chatService.initialize(),
        webSocketService.connect(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          return StreamBuilder<User?>(
            stream: authService.userStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return const HomeScreen();
              } else {
                return const AuthScreen();
              }
            },
          );
        }
      },
    );
  }
}