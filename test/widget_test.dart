import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unitify/app.dart';
import 'package:unitify/providers/app_state.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pumpApp(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    final state = AppState();
    await state.initialize();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(value: state, child: const UnitifyApp()),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('first launch presents onboarding and skip opens the app', (
    tester,
  ) async {
    final state = AppState();
    await state.initialize();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(value: state, child: const UnitifyApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Every conversion,\nright at hand'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Convert Anything'), findsOneWidget);
    expect(state.hasCompletedOnboarding, isTrue);
    expect(
      (await SharedPreferences.getInstance()).getBool('onboarding_complete'),
      isTrue,
    );
  });

  testWidgets('onboarding pages progress to the final call to action', (
    tester,
  ) async {
    final state = AppState();
    await state.initialize();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(value: state, child: const UnitifyApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('onboarding-primary-button')));
    await tester.pumpAndSettle();
    expect(find.text('Save the pairs\nyou use most'), findsOneWidget);

    await tester.tap(find.byKey(const Key('onboarding-primary-button')));
    await tester.pumpAndSettle();
    expect(find.text('Start converting'), findsOneWidget);
  });

  testWidgets('home dashboard exposes converters and navigation', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('Convert Anything'), findsOneWidget);
    expect(find.text('Length'), findsOneWidget);
    expect(find.text('Favorites'), findsWidgets);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('smart search finds categories through unit names', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.enterText(find.byType(TextField).first, 'Kelvin');
    await tester.pump();
    expect(find.text('Temperature'), findsOneWidget);
    expect(find.text('Length'), findsNothing);
  });

  testWidgets('category opens instant conversion calculator', (tester) async {
    await pumpApp(tester);
    await tester.ensureVisible(find.text('Length'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Length'));
    await tester.pumpAndSettle();
    expect(find.text('Amount'), findsOneWidget);
    expect(find.text('RESULT'), findsOneWidget);
    expect(find.text('Swap'), findsOneWidget);
  });
}
