import 'package:flutter/material.dart';

import 'modules/beranda/beranda_page.dart';
import 'modules/challenges/challenges_page.dart';
import 'modules/komunitas/komunitas_page.dart';
import 'modules/profil/profil_page.dart';
import 'modules/profil/profile_dashboard.dart';
import 'modules/tracker/tracker_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const cream = Color(0xFFF1E9D8);
    const surface = Color(0xFFFFFAF0);
    const forest = Color(0xFF14301F);

    return MaterialApp(
      title: 'Carbon Sense',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2C7A4B),
          surface: surface,
          onSurface: forest,
        ),
        scaffoldBackgroundColor: cream,
        appBarTheme: const AppBarTheme(
          backgroundColor: cream,
          foregroundColor: forest,
          surfaceTintColor: Colors.transparent,
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: surface,
          indicatorColor: Color(0xFFD3E86A),
          labelTextStyle: WidgetStatePropertyAll(
            TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      home: const _NavigationShell(),
    );
  }
}

class _NavigationShell extends StatefulWidget {
  const _NavigationShell();

  @override
  State<_NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<_NavigationShell> {
  static const _pages = [
    BerandaPage(),
    TrackerPage(),
    ProfilPage(),
    ChallengesPage(),
    KomunitasPage(),
  ];

  static const _destinations = [
    (Icons.home_outlined, 'Beranda'),
    (Icons.bar_chart, 'Tracker'),
    (Icons.person_outline, 'Profil'),
    (Icons.emoji_events_outlined, 'Challenges'),
    (Icons.groups_outlined, 'Komunitas'),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isProfile = _pages[_selectedIndex] is ProfilPage;

    return Scaffold(
      appBar: isProfile
          ? null
          : AppBar(
              title: const Row(
                children: [
                  Icon(Icons.eco_outlined),
                  SizedBox(width: 8),
                  Text('Carbon Sense'),
                ],
              ),
            ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: isProfile
          ? _profileNavigation()
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) =>
                  setState(() => _selectedIndex = index),
              destinations: [
                for (final (icon, label) in _destinations)
                  NavigationDestination(icon: Icon(icon), label: label),
              ],
            ),
    );
  }

  Widget _profileNavigation() => SafeArea(
    top: false,
    minimum: const EdgeInsets.fromLTRB(16, 6, 16, 12),
    child: Align(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: profileWidth - 32),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: profilePaper,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: profileInk, width: 2),
            boxShadow: const [
              BoxShadow(color: profileInk, offset: Offset(0, 4)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                for (final (index, (icon, label)) in _destinations.indexed)
                  Expanded(
                    child: Semantics(
                      selected: index == _selectedIndex,
                      child: Material(
                        color: index == _selectedIndex
                            ? profileInk
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () => setState(() => _selectedIndex = index),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 7,
                              horizontal: 1,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  icon,
                                  size: 19,
                                  color: index == _selectedIndex
                                      ? profilePaper
                                      : profileInk,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  label,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Figtree',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: index == _selectedIndex
                                        ? profilePaper
                                        : profileInk,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
