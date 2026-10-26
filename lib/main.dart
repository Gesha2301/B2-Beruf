import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';

void main() => runApp(const B2AppRoot());

class B2AppRoot extends StatefulWidget {
  const B2AppRoot({super.key});

  @override
  State<B2AppRoot> createState() => _B2AppRootState();
}

class _B2AppRootState extends State<B2AppRoot> {
  bool _isDark = true;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      if (mounted) setState(() => _isDark = p.getBool('is_dark_mode') ?? true);
    });
  }

  Future<void> _toggleTheme() async {
    setState(() => _isDark = !_isDark);
    final p = await SharedPreferences.getInstance();
    await p.setBool('is_dark_mode', _isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'B2 Beruf DMC Flashcards',
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF2F4F7),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.redAccent,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: MainDashboardScreen(isDarkMode: _isDark, onToggleTheme: _toggleTheme),
    );
  }
}
