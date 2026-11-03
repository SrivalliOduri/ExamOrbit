import 'package:examorbit/models/app_settings.dart';
import 'package:examorbit/screens/subject_form_screen.dart';
import 'package:examorbit/services/storage_service.dart';
import 'package:examorbit/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppState> _buildState(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = (await tester.runAsync(SharedPreferences.getInstance))!;
  return AppState(
    storage: StorageService(prefs),
    subjects: const [],
    settings: const AppSettings.defaults(),
  );
}

Future<void> _pumpForm(WidgetTester tester, AppState state) {
  return tester.pumpWidget(
    ChangeNotifierProvider<AppState>.value(
      value: state,
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: const SubjectFormScreen(),
      ),
    ),
  );
}

Future<void> _tapSave(WidgetTester tester) async {
  final saveButton = find.widgetWithText(FilledButton, 'Save subject');
  await tester.ensureVisible(saveButton);
  await tester.tap(saveButton);
  await tester.pump();
}

void main() {
  testWidgets('shows inline errors when required fields are empty', (tester) async {
    final state = await _buildState(tester);
    await _pumpForm(tester, state);

    await _tapSave(tester);

    expect(find.text('Enter a subject name'), findsOneWidget);
    expect(find.text('Pick an exam date'), findsOneWidget);
    expect(find.text('Enter a whole number'), findsOneWidget);
    expect(state.subjects, isEmpty);
  });

  testWidgets('rejects zero units with a clear message', (tester) async {
    final state = await _buildState(tester);
    await _pumpForm(tester, state);

    final unitsField = find.widgetWithText(TextFormField, 'Number of units');
    await tester.ensureVisible(unitsField);
    await tester.enterText(unitsField, '0');
    await _tapSave(tester);

    expect(find.text('Use at least 1 unit'), findsOneWidget);
  });

  testWidgets('shows the new subject title when no subject is selected', (tester) async {
    final state = await _buildState(tester);
    await _pumpForm(tester, state);

    expect(find.text('New subject'), findsOneWidget);
  });
}
