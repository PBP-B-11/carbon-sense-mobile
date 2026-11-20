import 'package:flutter/material.dart';

import 'modules/beranda/beranda_page.dart';
import 'modules/challenges/challenges_page.dart';
import 'modules/komunitas/komunitas_page.dart';
import 'modules/profil/profil_page.dart';
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

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.eco_outlined),
            SizedBox(width: 8),
            Text('Carbon Sense'),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Beranda',
          ),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Tracker'),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            label: 'Challenges',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            label: 'Komunitas',
          ),
        ],
      ),
    );
  }
}
