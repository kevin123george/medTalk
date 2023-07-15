import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medTalk/screens/speech_to_text_screen.dart'; // Import the widget to be tested

void main() {
  group('SpeechToTextScreen Widget Test', () {
    testWidgets('SpeechToTextScreen initializes correctly', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: SpeechToTextScreen(),
        ),
      );

      // Verify the initial state values
      expect(find.text(''), findsOneWidget); // Verify that the resultText is empty
      expect(find.text(''), findsOneWidget); // Verify that the helperText is empty
      expect(find.text(''), findsNothing); // Verify that the intro_text is not empty
      expect(find.byIcon(Icons.mic_none), findsOneWidget); // Verify that the mic icon is present
      // expect(find.byType(AvatarGlow), findsOneWidget); // Verify that AvatarGlow widget is present
      expect(find.byType(SingleChildScrollView), findsOneWidget); // Verify that SingleChildScrollView is present
      expect(find.byType(Text), findsOneWidget); // Verify that Text widget is present
    });

    testWidgets('SpeechToTextScreen recognizes speech correctly', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: SpeechToTextScreen(),
        ),
      );

      // Tap the mic button to start speech recognition
      await tester.tap(find.byIcon(Icons.mic_none));
      await tester.pumpAndSettle(Duration(milliseconds: 100)); // Wait for the speech recognition to start

      // Simulate speech recognition result
      await tester.pump(Duration(seconds: 1));
      await tester.enterText(find.byType(Text), 'Hello, this is a test.'); // Simulate recognized speech
      await tester.pump(Duration(seconds: 1));

      // Tap the mic button to stop speech recognition
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle(Duration(milliseconds: 100)); // Wait for the speech recognition to stop

      // Verify that the recognized text is displayed in the widget
      expect(find.text('Hello, this is a test.'), findsOneWidget);
    });

    testWidgets('SpeechToTextScreen stops speech recognition on button press', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: SpeechToTextScreen(),
        ),
      );

      // Tap the mic button to start speech recognition
      await tester.tap(find.byIcon(Icons.mic_none));
      await tester.pumpAndSettle(Duration(milliseconds: 100)); // Wait for the speech recognition to start

      // Tap the mic button again to stop speech recognition
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle(Duration(milliseconds: 100)); // Wait for the speech recognition to stop

      // Verify that speech recognition is stopped and no recognized text is displayed
      expect(find.text(''), findsOneWidget);
    });
  });
}
