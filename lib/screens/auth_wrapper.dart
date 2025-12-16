import 'package:easy_task_flow/screens/main_layout.dart';
import 'package:easy_task_flow/screens/welcome_screen.dart';
import 'package:easy_task_flow/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap AuthService instantiation in try-catch to be safe
    AuthService? authService;
    try {
      authService = AuthService();
    } catch (e) {
      debugPrint('AuthWrapper: Error initializing AuthService: $e');
      return Scaffold(
        body: Center(
          child: Text('Authentication Error: $e'),
        ),
      );
    }

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint('AuthWrapper: Stream Error: ${snapshot.error}');
          return Scaffold(
            body: Center(
              child: Text('Connection Error: ${snapshot.error}'),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user == null) {
            return const WelcomeScreen();
          } else {
            return const MainLayout();
          }
        }

        // Loading state
        return const Scaffold(
          backgroundColor: Color(0xFF101922),
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
