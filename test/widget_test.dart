import 'package:easy_task_flow/main.dart';
import 'package:easy_task_flow/screens/auth_wrapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App starts with AuthWrapper', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that AuthWrapper is the first widget.
    expect(find.byType(AuthWrapper), findsOneWidget);
  });
}
