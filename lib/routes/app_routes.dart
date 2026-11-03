import 'package:flutter/material.dart';

import '../screens/home_shell.dart';
import '../screens/splash_screen.dart';
import '../screens/subject_detail_screen.dart';
import '../screens/subject_form_screen.dart';

/// Central route table. Detail and edit routes expect a subject id as their argument.
abstract final class AppRoutes {
  static const splash = '/';
  static const home = '/home';
  static const subjectDetail = '/subjects/detail';
  static const subjectForm = '/subjects/form';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final arguments = settings.arguments;
    final Widget page = switch (settings.name) {
      AppRoutes.home => const HomeShell(),
      AppRoutes.subjectDetail => SubjectDetailScreen(subjectId: arguments as String),
      AppRoutes.subjectForm => SubjectFormScreen(subjectId: arguments as String?),
      _ => const SplashScreen(),
    };

    return PageRouteBuilder<dynamic>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
