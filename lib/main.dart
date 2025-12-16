import 'dart:async';
import 'package:easy_task_flow/firebase_options.dart';
import 'package:easy_task_flow/screens/auth_wrapper.dart';
import 'package:easy_task_flow/screens/login_screen.dart';
import 'package:easy_task_flow/screens/main_layout.dart';
import 'package:easy_task_flow/screens/signup_screen.dart';
import 'package:easy_task_flow/screens/welcome_screen.dart';
import 'package:easy_task_flow/utils/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('EasyTaskFlow: WidgetsFlutterBinding initialized');

    // Set up global error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      // Only show error app for fatal errors that crash the widget tree root
      // runApp(ErrorApp(message: details.exception.toString(), stackTrace: details.stack));
    };

    try {
      debugPrint('EasyTaskFlow: Initializing Firebase...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('EasyTaskFlow: Firebase initialized');

      try {
        debugPrint('EasyTaskFlow: Activating Firebase App Check...');
        await FirebaseAppCheck.instance.activate(
          androidProvider: AndroidProvider.playIntegrity,
          appleProvider: AppleProvider.appAttest,
          webProvider: ReCaptchaV3Provider('6LfaESksAAAAANFC2czdzWOXkPMeMaYnXe59xGOa'),
        );
        debugPrint('EasyTaskFlow: Firebase App Check activated');
      } catch (e, stack) {
        // App Check failure should not crash the app, but might affect requests
        debugPrint('EasyTaskFlow: Warning - Firebase App Check failed: $e');
        debugPrint(stack.toString());
      }

      if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) {
        try {
          debugPrint('EasyTaskFlow: Initializing Mobile Ads...');
          MobileAds.instance.initialize();
          debugPrint('EasyTaskFlow: Mobile Ads initialized');
        } catch (e) {
          debugPrint('EasyTaskFlow: Warning - Mobile Ads failed: $e');
        }
      }

      debugPrint('EasyTaskFlow: Running App...');
      runApp(const MyApp());
    } catch (e, stack) {
      debugPrint('EasyTaskFlow: Fatal Initialization Error: $e');
      runApp(ErrorApp(message: e.toString(), stackTrace: stack));
    }
  }, (error, stack) {
    debugPrint('EasyTaskFlow: Zone Error: $error');
    // If the app hasn't started yet, show the error screen
    // But if it's a runtime error later, maybe just log it?
    // For now, we want to see it.
    // runApp(ErrorApp(message: error.toString(), stackTrace: stack));
  });
}

class ErrorApp extends StatelessWidget {
  final String message;
  final StackTrace? stackTrace;

  const ErrorApp({super.key, required this.message, this.stackTrace});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF101922),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Application Error',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SelectableText(
                    message,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontFamily: 'monospace'),
                    textAlign: TextAlign.center,
                  ),
                  if (stackTrace != null) ...[
                     const SizedBox(height: 16),
                     Container(
                       padding: const EdgeInsets.all(8),
                       color: Colors.black26,
                       child: SelectableText(
                         stackTrace.toString(),
                         style: const TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'monospace'),
                       ),
                     ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyTaskFlow',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AuthWrapper(),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const MainLayout(),
      },
    );
  }
}
