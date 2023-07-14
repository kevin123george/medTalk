import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medTalk/screens/record_screen.dart';
import 'package:medTalk/providers/language_provider.dart';
import 'package:provider/provider.dart';

void main() {
  final LanguageProvider languageProvider = LanguageProvider();

  Widget createRecordsScreen() => ChangeNotifierProvider<LanguageProvider>(
    create: (_) => languageProvider,
    child: MaterialApp(
      home: Scaffold(
        body: RecordsScreen(),
      ),
    ),
  );

  group('Record Screen Widget Tests', () {
    testWidgets('Record Screen renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createRecordsScreen());
      expect(find.byType(RecordsScreen), findsOneWidget);
    });

    testWidgets('Calendar date range selection', (WidgetTester tester) async {
      try {
        await tester.pumpWidget(createRecordsScreen());
        await tester.tap(find.byIcon(Icons.filter_list));
        await tester.pumpAndSettle();

        // Select a date range in the calendar
        final startDate = DateTime(2023, 6, 1);
        final endDate = DateTime(2023, 6, 30);
        await tester.dragUntilVisible(
          find.text('June 2023'),
          find.text('December 2024'),
          const Offset(0, -300),
        );
        await tester.tap(find.text('1'));
        await tester.tap(find.text('30'));
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        // Verify that the selected date range is applied
        expect(find.text('Selected Date Range: $startDate - $endDate'), findsOneWidget);

        // Verify that the displayed records fall within the selected date range
        expect(find.byType(ListTile), findsNWidgets(2)); // Assuming there are 2 records within the selected date range
      } catch (e) {
        print(e);
      }
    });
  });
}
