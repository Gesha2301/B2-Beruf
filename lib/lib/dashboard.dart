import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_screen.dart';

class MainDashboardScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const MainDashboardScreen({super.key, required this.isDarkMode, required this.onToggleTheme});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _maxCombo = 0;
  int _totalStudied = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _maxCombo = p.getInt('max_combo_record') ?? 0;
      _totalStudied = p.getInt('total_cards_studied') ?? 0;
    });
  }

  Future<void> _startSession(String category) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DMCGameScreen(category: category, onStatsUpdated: _loadStats),
      ),
    );
    _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    const categories = ['Все карточки', 'Bewerbung', 'Vertrag & Recht', 'Büroalltag'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('🔥 B2 BERUF DMC',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.isDarkMode
                      ? [Colors.red.shade900, Colors.black]
                      : [Colors.indigo.shade600, Colors.indigo.shade900],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 10)],
              ),
              child: Column(
                children: [
                  const Text('РЕКОРДНОЕ КОМБО',
                      style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('$_maxCombo STREAK',
                      style: const TextStyle(
                          color: Colors.amberAccent,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2)),
                  const Divider(color: Colors.white24, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.style, color: Colors.white70, size: 18),
                      const SizedBox(width: 8),
                      Text('Пройдено карточек: $_totalStudied',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('ВЫБОР МОДУЛЯ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (_, i) => Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    title: Text(categories[i],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: const Text('Нажмите, чтобы начать раунд'),
                    trailing: const Icon(Icons.play_arrow_rounded, size: 32, color: Colors.redAccent),
                    onTap: () => _startSession(categories[i]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
