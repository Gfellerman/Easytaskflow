import 'package:easy_task_flow/screens/signup_screen.dart';
import 'package:easy_task_flow/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Mock AuthService for testing purposes
class MockAuthService extends Mock implements AuthService {}

void main() {
  group('SignUpScreen', () {
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
    });

    testWidgets('shows loading indicator and signs up successfully',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(MaterialApp(
        home: SignUpScreen(),
      ));

      // Mock the signUpWithEmailAndPassword method to return a user
      when(mockAuthService.signUpWithEmailAndPassword(
        any,
        any,
        any,
        any,
      )).thenAnswer((_) async => MockUser());

      // Fill out the form
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(find.byType(TextFormField).at(1), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password');
      await tester.enterText(find.byType(TextFormField).at(3), '1234567890');

      // Tap the sign up button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(); // Start the animation

      // Verify that the loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle(); // Wait for the async call to complete

      // The widget should be gone, and navigation handled by AuthWrapper
      // so we just verify the loading indicator is gone.
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows error message when sign up fails',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(MaterialApp(
        home: SignUpScreen(),
      ));

      // Mock the signUpWithEmailAndPassword method to throw an exception
      when(mockAuthService.signUpWithEmailAndPassword(
        any,
        any,
        any,
        any,
      )).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      // Fill out the form
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(find.byType(TextFormField).at(1), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password');
      await tester.enterText(find.byType(TextFormField).at(3), '1234567890');
      
      // Tap the sign up button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(); // Start the animation

      // Verify that the loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle(); // Wait for the async call to complete

      // Verify that the loading indicator is gone
      expect(find.byType(CircularProgressIndicator), findsNothing);
      
      // Verify that the error message is shown
      expect(find.text('An account already exists for that email.'), findsOneWidget);
    });
  });
}

// Mock User for testing purposes
class MockUser extends Mock implements User {}
