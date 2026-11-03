import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'routes/app_routes.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

/// Root widget. Rebuilds the theme when the dark mode setting changes.
class ExamOrbitApp extends StatelessWidget {
  const ExamOrbitApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.select<AppState, bool>((state) => state.settings.isDarkMode);
    return MaterialApp(
      title: 'ExamOrbit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
