import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'focus_timer_screen.dart';
import 'settings_screen.dart';
import 'subjects_screen.dart';

/// Main container: bottom bar on phones, side rail on wider screens.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const double _railBreakpoint = 600;

  static const List<_NavItem> _items = [
    _NavItem('Dashboard', Icons.dashboard_outlined, Icons.dashboard_rounded),
    _NavItem('Subjects', Icons.menu_book_outlined, Icons.menu_book_rounded),
    _NavItem('Focus', Icons.timer_outlined, Icons.timer_rounded),
    _NavItem('Settings', Icons.settings_outlined, Icons.settings_rounded),
  ];

  static const List<Widget> _screens = [
    DashboardScreen(),
    SubjectsScreen(),
    FocusTimerScreen(),
    SettingsScreen(),
  ];

  int _index = 0;

  void _select(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final body = IndexedStack(index: _index, children: _screens);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _railBreakpoint) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: _select,
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final item in _items)
                      NavigationRailDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.selectedIcon),
                        label: Text(item.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            ),
          );
        }
        return Scaffold(
          body: body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: _select,
            destinations: [
              for (final item in _items)
                NavigationDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon),
                  label: item.label,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
