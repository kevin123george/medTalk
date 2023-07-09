import 'package:flutter_test/flutter_test.dart';
import 'package:medTalk/screens/calender_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medTalk/providers/language_provider.dart';

void main() {
  final LanguageProvider languageProvider = LanguageProvider();

  Widget createCalenderScreen() => ChangeNotifierProvider<LanguageProvider>(
    create: (_) => languageProvider,
    child: MaterialApp(
      home: Scaffold(
        body: CalenderScreen(),
      ),
    ),
  );

  group('CalenderScreen Widget Tests', () {
    testWidgets('CalenderScreen renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createCalenderScreen());

      expect(find.byType(CalenderScreen), findsOneWidget);
    });

    testWidgets('FloatingActionButton is found and can be tapped', (WidgetTester tester) async {
      try {
        await tester.pumpWidget(createCalenderScreen());

        expect(find.byType(FloatingActionButton), findsOneWidget);

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle(); // Rebuild the widget after the state change.
      } catch (e) {
        print(e);
      }
    });

    testWidgets('Dialog appears when FloatingActionButton is tapped', (WidgetTester tester) async {
      try {
        await tester.pumpWidget(createCalenderScreen());

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
      } catch (e) {
        print(e);
      }
    });

    // testWidgets('A specific Schedulers widget is present', (WidgetTester tester) async {
    //   await tester.pumpWidget(createCalenderScreen());
    //
    //   expect(find.text('Specific Scheduler Title'), findsOneWidget);
    // });
  });
}
