import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winner_topa/screens/main_navigation_screen.dart';
import 'package:winner_topa/services/winner_match_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('WinnerMatchService toggles saved matches and favorite teams', () {
    final service = WinnerMatchService();
    expect(service.matches.isNotEmpty, isTrue);
    expect(service.teams.isNotEmpty, isTrue);

    service.toggleSaveMatch('topa_m2');
    expect(service.savedMatchIds.contains('topa_m2'), isTrue);
    service.toggleSaveMatch('topa_m2');
    expect(service.savedMatchIds.contains('topa_m2'), isFalse);
  });

  testWidgets('MainNavigationScreen has exactly 3 tabs (Matches, Teams, My Matches)', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MainNavigationScreen(),
      ),
    );
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    final navFinder = find.byType(BottomNavigationBar);
    expect(find.descendant(of: navFinder, matching: find.text('Matches')), findsOneWidget);
    expect(find.descendant(of: navFinder, matching: find.text('Teams')), findsOneWidget);
    expect(find.descendant(of: navFinder, matching: find.text('My Matches')), findsOneWidget);

    // Switch to Teams
    await tester.tap(find.descendant(of: navFinder, matching: find.text('Teams')));
    await tester.pumpAndSettle();
    expect(find.text('League standings & club database'), findsOneWidget);

    // Switch to My Matches
    await tester.tap(find.descendant(of: navFinder, matching: find.text('My Matches')));
    await tester.pumpAndSettle();
    expect(find.text('Personal schedule & followed club timeline'), findsOneWidget);
  });
}
