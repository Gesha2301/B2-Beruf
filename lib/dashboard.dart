import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data.dart';
import 'sound.dart';
import 'game_screen.dart';
import 'lesen_screen.dart';
import 'hoeren_screen.dart';
import 'schreiben_screen.dart';

class MainDashboardScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  const MainDashboardScreen({super.key, required this.isDarkMode, required this.onToggleTheme});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> with SingleTickerProviderStateMixin {
  int _maxCombo = 0;
  int _totalStudied = 0;
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _loadStats();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
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
        builder: (_) => GameScreen(
          selectedCategory: category,
          onStatsUpdated: _loadStats,
        ),
      ),
    );
    _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['Все карточки', ...getUniqueCategories()];
    final counts = getCategoryCounts();

    return Scaffold(
      appBar: AppBar(
        title: const Text('B2 BERUF DMC',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 18)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(DmcAudio.soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded),
            onPressed: () {
              setState(() => DmcAudio.toggleSound());
            },
            tooltip: 'Звуковые эффекты',
          ),
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.wb_sunny_rounded : Icons.nightlight_round),
            onPressed: widget.onToggleTheme,
            tooltip: 'Сменить тему',
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.style_rounded, size: 20), text: 'Карты'),
            Tab(icon: Icon(Icons.menu_book_rounded, size: 20), text: 'Lesen'),
            Tab(icon: Icon(Icons.headphones_rounded, size: 20), text: 'Hören'),
            Tab(icon: Icon(Icons.edit_note_rounded, size: 20), text: 'Schreiben'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          // 1. CARDS TAB
          Padding(
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
                          : [Colors.indigo.shade700, Colors.indigo.shade900],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 12, offset: Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      const Text('РЕКОРДНОЕ КОМБО',
                          style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      const SizedBox(height: 4),
                      Text('$_maxCombo STREAK',
                          style: const TextStyle(color: Colors.amberAccent, fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: 2)),
                      const Divider(color: Colors.white24, height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, color: Colors.white70, size: 18),
                          const SizedBox(width: 8),
                          Text('Пройдено карточек: $_totalStudied',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('ВЫБОР МОДУЛЯ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    Text('Всего: ${initialB2Dataset.length} карт', style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (_, i) {
                      final cat = categories[i];
                      final count = cat == 'Все карточки' ? initialB2Dataset.length : (counts[cat] ?? 0);
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                          title: Text(cat, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          subtitle: Text('$count карточек  ·  Начать раунд', style: const TextStyle(fontSize: 12)),
                          trailing: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: Colors.redAccent.withAlpha(30), shape: BoxShape.circle),
                            child: const Icon(Icons.play_arrow_rounded, size: 24, color: Colors.redAccent),
                          ),
                          onTap: () => _startSession(cat),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 2. LESEN TAB
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.menu_book_rounded, size: 72, color: Colors.purpleAccent),
                  const SizedBox(height: 16),
                  const Text('LESEN: Sprachbausteine',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  const SizedBox(height: 10),
                  const Text(
                    'Тренажер заполнения пропусков из реальных предложений экзамена B2 Beruf с DMC-рангами и комбо.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LesenScreen(onStatsUpdated: _loadStats)),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 28),
                    label: const Text('НАЧАТЬ ТРЕНИРОВКУ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ],
              ),
            ),
          ),

          // 3. HÖREN TAB (Neu)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.headphones_rounded, size: 72, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  const Text('HÖREN: DTB B2 Аудирование',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  const SizedBox(height: 10),
                  const Text(
                    'Аудирование с немецким диктором (TTS de-DE), разбором диалогов, мнений, докладов и заполнением Telefonnotiz.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade900,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => HoerenScreen(onStatsUpdated: _loadStats)),
                    ),
                    icon: const Icon(Icons.hearing_rounded, size: 26),
                    label: const Text('ОТКРЫТЬ АУДИРОВАНИЕ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ],
              ),
            ),
          ),

          // 4. SCHREIBEN TAB
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.edit_note_rounded, size: 72, color: Colors.amberAccent),
                  const SizedBox(height: 16),
                  const Text('SCHREIBEN: B2 Письмо',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  const SizedBox(height: 10),
                  const Text(
                    'Тренировка деловых писем, форумов и служебных заметок с таймером, счетчиком слов и базой 218 Nomen-Verb-Verbindungen.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade800,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SchreibenScreen()),
                    ),
                    icon: const Icon(Icons.create_rounded, size: 24),
                    label: const Text('ОТКРЫТЬ ТРЕНАЖЕР', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
