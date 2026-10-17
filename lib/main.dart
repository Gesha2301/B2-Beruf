import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const B2AppRoot());
}

class B2AppRoot extends StatefulWidget {
  const B2AppRoot({super.key});

  @override
  State<B2AppRoot> createState() => _B2AppRootState();
}

class _B2AppRootState extends State<B2AppRoot> {
  bool _isDarkMode = true;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('is_dark_mode') ?? true;
    });
  }

  void _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    await prefs.setBool('is_dark_mode', _isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'B2 Beruf DMC Flashcards',
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
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
      home: MainDashboardScreen(
        isDarkMode: _isDarkMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class Flashcard {
  final String article;
  final String german;
  final String russian;
  final String explanation;
  final String category;

  Flashcard({
    required this.article,
    required this.german,
    required this.russian,
    required this.explanation,
    required this.category,
  });
}

final List<Flashcard> initialB2Dataset = [
  Flashcard(
    article: 'die',
    german: 'Stellenausschreibung, -en',
    russian: 'Объявление о вакансии',
    explanation: 'Die Stellenausschreibung passt genau zu meinem Profil.',
    category: 'Bewerbung',
  ),
  Flashcard(
    article: 'das',
    german: 'Anschreiben, -',
    russian: 'Сопроводительное письмо',
    explanation: 'Das Anschreiben sollte prägnant und professionell sein.',
    category: 'Bewerbung',
  ),
  Flashcard(
    article: 'der',
    german: 'Lebenslauf, -¨e',
    russian: 'Резюме (CV)',
    explanation: 'Bitte fügen Sie Ihren aktuellen Lebenslauf bei.',
    category: 'Bewerbung',
  ),
  Flashcard(
    article: 'das',
    german: 'Vorstellungsgespräch, -e',
    russian: 'Собеседование',
    explanation: 'Ich habe morgen ein wichtiges Vorstellungsgespräch.',
    category: 'Bewerbung',
  ),
  Flashcard(
    article: 'der',
    german: 'Arbeitsvertrag, -¨e',
    russian: 'Трудовой договор',
    explanation: 'Ich habe den Arbeitsvertrag bereits unterschrieben.',
    category: 'Vertrag & Recht',
  ),
  Flashcard(
    article: 'die',
    german: 'Probezeit, -en',
    russian: 'Испытательный срок',
    explanation: 'Während der Probezeit gilt eine verkürzte Kündigungsfrist.',
    category: 'Vertrag & Recht',
  ),
  Flashcard(
    article: 'die',
    german: 'Kündigungsfrist, -en',
    russian: 'Срок уведомления об увольнении',
    explanation: 'Die Kündigungsfrist beträgt drei Monate.',
    category: 'Vertrag & Recht',
  ),
  Flashcard(
    article: '',
    german: 'Verhandlungsgeschick haben',
    russian: 'Обладать навыками ведения переговоров',
    explanation: 'Für den Vertrieb braucht man Verhandlungsgeschick.',
    category: 'Büroalltag',
  ),
  Flashcard(
    article: '',
    german: 'Fristen einhalten',
    russian: 'Соблюдать сроки / дедлайны',
    explanation: 'Wir müssen alle Fristen strikt einhalten.',
    category: 'Büroalltag',
  ),
  Flashcard(
    article: 'die',
    german: 'Rückmeldung, -en',
    russian: 'Обратная связь / Отклик',
    explanation: 'Ich warte noch auf eine Rückmeldung vom Team.',
    category: 'Büroalltag',
  ),
];

class MainDashboardScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const MainDashboardScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _maxComboRecord = 0;
  int _totalCardsStudied = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _maxComboRecord = prefs.getInt('max_combo_record') ?? 0;
      _totalCardsStudied = prefs.getInt('total_cards_studied') ?? 0;
    });
  }

  void _startSession(String category) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DMCGameScreen(
          category: category,
          onStatsUpdated: _loadStats,
        ),
      ),
    );
    _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['Все карточки', 'Bewerbung', 'Vertrag & Recht', 'Büroalltag'];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🔥 B2 BERUF DMC',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                  const Text(
                    'РЕКОРДНОЕ КОМБО',
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_maxComboRecord STREAK',
                    style: const TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const Divider(color: Colors.white24, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.style, color: Colors.white70, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Пройдено карточек: $_totalCardsStudied',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'ВЫБОР МОДУЛЯ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      title: Text(
                        cat,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: const Text('Нажмите, чтобы начать раунд'),
                      trailing: const Icon(Icons.play_arrow_rounded, size: 32, color: Colors.redAccent),
                      onTap: () => _startSession(cat),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DMCGameScreen extends StatefulWidget {
  final String category;
  final VoidCallback onStatsUpdated;

  const DMCGameScreen({
    super.key,
    required this.category,
    required this.onStatsUpdated,
  });

  @override
  State<DMCGameScreen> createState() => _DMCGameScreenState();
}

class _DMCGameScreenState extends State<DMCGameScreen> {
  List<Flashcard> _deck = [];
  int _currentIndex = 0;
  bool _showFront = true;
  int _comboCount = 0;
  int _score = 0;

  Offset _cardOffset = Offset.zero;
  double _cardAngle = 0.0;
  Color? _flashColor;

  @override
  void initState() {
    super.initState();
    _initDeck();
  }

  void _initDeck() {
    if (widget.category == 'Все карточки') {
      _deck = List.from(initialB2Dataset);
    } else {
      _deck = initialB2Dataset.where((c) => c.category == widget.category).toList();
    }
    _deck.shuffle();
  }

  void _shuffleDeck() {
    setState(() {
      _deck.shuffle();
      _currentIndex = 0;
      _showFront = true;
      _cardOffset = Offset.zero;
      _cardAngle = 0.0;
    });
  }

  Map<String, dynamic> _getRankData() {
    if (_comboCount >= 15) return {'rank': 'SSS', 'color': Colors.amberAccent, 'multiplier': 5};
    if (_comboCount >= 12) return {'rank': 'SS', 'color': Colors.orangeAccent, 'multiplier': 4};
    if (_comboCount >= 9) return {'rank': 'S', 'color': Colors.redAccent, 'multiplier': 3};
    if (_comboCount >= 6) return {'rank
