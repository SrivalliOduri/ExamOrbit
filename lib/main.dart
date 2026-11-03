import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'services/storage_service.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = StorageService(await SharedPreferences.getInstance());
  final data = storage.load();
  final state = AppState(
    storage: storage,
    subjects: data.subjects,
    settings: data.settings,
  );
  runApp(
    ChangeNotifierProvider<AppState>.value(
      value: state,
      child: const ExamOrbitApp(),
    ),
  );
}
