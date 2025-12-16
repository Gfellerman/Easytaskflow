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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.appAttest,
      webProvider: ReCaptchaV3Provider('6LfaESksAAAAANFC2czdzWOXkPMeMaYnXe59xGOa'),
    );
    if (!kIsWeb) {
      MobileAds.instance.initialize();
    }
    runApp(const MyApp());
  } catch (e, stack) {
    debugPrint('Initialization Error: $e');
    debugPrintStack(stackTrace: stack);
    runApp(MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF101922),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Application Failed to Start',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$e',
                    style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontFamily: 'monospace'),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
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
