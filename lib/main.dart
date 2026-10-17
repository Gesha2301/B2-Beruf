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

class _DMCGameScreenState extends State<DMCGameScreen> with SingleTickerProviderStateMixin {
  List<Flashcard> _deck = [];
  int _currentIndex = 0;
  bool _showFront = true;
  int _comboCount = 0;
  int _score = 0;

  // Swipe Animation Physics
  Offset _cardOffset = Offset.zero;
  double _cardAngle = 0.0;
  Color? _flashColor;
  bool _isAnimatingOut = false;

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
      _isAnimatingOut = false;
    });
  }

  Map<String, dynamic> _getRankData() {
    if (_comboCount >= 15) return {'rank': 'SSS', 'color': Colors.amberAccent, 'multiplier': 5};
    if (_comboCount >= 12) return {'rank': 'SS', 'color': Colors.orangeAccent, 'multiplier': 4};
    if (_comboCount >= 9) return {'rank': 'S', 'color': Colors.redAccent, 'multiplier': 3};
    if (_comboCount >= 6) return {'rank': 'A', 'color': Colors.purpleAccent, 'multiplier': 2};
    if (_comboCount >= 4) return {'rank': 'B', 'color': Colors.blueAccent, 'multiplier': 2};
    if (_comboCount >= 2) return {'rank': 'C', 'color': Colors.greenAccent, 'multiplier': 1};
    if (_comboCount >= 1) return {'rank': 'D', 'color': Colors.grey, 'multiplier': 1};
    return {'rank': '-', 'color': Colors.grey, 'multiplier': 1};
  }

  void _triggerFlyOutAndNext(bool knew) {
    if (_isAnimatingOut) return;
    _isAnimatingOut = true;

    // Магнитная траектория вылета
    final double targetX = knew ? 500.0 : -500.0;
    
    setState(() {
      _cardOffset = Offset(targetX, _cardOffset.dy);
      _cardAngle = targetX / 200;
      _flashColor = knew ? Colors.green.withAlpha(80) : Colors.red.withAlpha(80);
    });

    Timer(const Duration(milliseconds: 200), () async {
      final prefs = await SharedPreferences.getInstance();
      int currentTotal = prefs.getInt('total_cards_studied') ?? 0;
      int maxCombo = prefs.getInt('max_combo_record') ?? 0;

      await prefs.setInt('total_cards_studied', currentTotal + 1);

      if (mounted) {
        setState(() {
          if (knew) {
            _comboCount++;
            final multiplier = _getRankData()['multiplier'] as int;
            _score += 100 * multiplier;

            if (_comboCount > maxCombo) {
              prefs.setInt('max_combo_record', _comboCount);
            }
          } else {
            _comboCount = 0;
          }

          _showFront = true;
          _currentIndex = (_currentIndex + 1) % _deck.length;
          _cardOffset = Offset.zero;
          _cardAngle = 0.0;
          _flashColor = null;
          _isAnimatingOut = false;
        });

        widget.onStatsUpdated();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_deck.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.category)),
        body: const Center(child: Text('Нет карточек в этой категории')),
      );
    }

    final card = _deck[_currentIndex];
    final nextCard = _deck[(_currentIndex + 1) % _deck.length];
    final rankData = _getRankData();
    final Color rankColor = rankData['color'] as Color;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: _shuffleDeck,
            tooltip: 'Перемешать',
          )
        ],
      ),
      body: Stack(
        children: [
          if (_flashColor != null)
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              color: _flashColor,
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                // DMC SCORE BOARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: rankColor.withAlpha(35),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: rankColor, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SCORE: $_score',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            'COMBO: $_comboCount STREAK',
                            style: TextStyle(
                              color: rankColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        rankData['rank'] as String,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          color: rankColor,
                          shadows: [
                            Shadow(
                              color: rankColor,
                              blurRadius: 12,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / _deck.length,
                  color: rankColor,
                ),
                const SizedBox(height: 20),
                // CARD DECK WITH MAGNET & FLY-OFF
                Expanded(
                  child: Stack(
                    children: [
                      // Фоновая следующая карточка
                      Positioned.fill(
                        child: Transform.scale(
                          scale: 0.94,
                          child: Opacity(
                            opacity: 0.6,
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        nextCard.german,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Главная управляемая карточка
                      Positioned.fill(
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            if (_isAnimatingOut) return;
                            setState(() {
                              _cardOffset += details.delta;
                              _cardAngle = _cardOffset.dx / 300;
                            });
                          },
                          onPanEnd: (details) {
                            if (_isAnimatingOut) return;
                            if (_cardOffset.dx > 100) {
                              _triggerFlyOutAndNext(true); // Магнит вправо (Знаю)
                            } else if (_cardOffset.dx < -100) {
                              _triggerFlyOutAndNext(false); // Магнит влево (Не знаю)
                            } else {
                              setState(() {
                                _cardOffset = Offset.zero;
                                _cardAngle = 0.0;
                              });
                            }
                          },
                          onTap: () {
                            if (_isAnimatingOut) return;
                            setState(() {
                              _showFront = !_showFront;
                            });
                          },
                          child: AnimatedContainer(
                            duration: _isAnimatingOut
                                ? const Duration(milliseconds: 200)
                                : Duration.zero,
                            curve: Curves.easeOutCubic,
                            transform: Matrix4.identity()
                              ..translate(_cardOffset.dx, _cardOffset.dy)
                              ..rotateZ(_cardAngle),
                            child: Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: _cardOffset.dx > 40
                                      ? Colors.green
                                      : (_cardOffset.dx < -40 ? Colors.red : Colors.transparent),
                                  width: 3,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: _showFront
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          if (card.article.isNotEmpty)
                                            Text(
                                              card.article,
                                              style: const TextStyle(
                                                  fontSize: 26, fontWeight: FontWeight.bold, color: Colors.redAccent),
                                            ),
                                          const SizedBox(height: 10),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              card.german,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          const SizedBox(height: 30),
                                          const Text(
                                            'Нажмите, чтобы перевернуть | Свайп для ответа',
                                            style: TextStyle(color: Colors.grey, fontSize: 12),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              card.russian,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontSize: 26, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                                            ),
                                          ),
                                          if (card.explanation.isNotEmpty) ...[
                                            const SizedBox(height: 20),
                                            const Divider(),
                                            const SizedBox(height: 10),
                                            Text(
                                              card.explanation,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
                                            ),
                                          ],
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
                const SizedBox(height: 20),
                // CONTROL BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade900,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () => _triggerFlyOutAndNext(false),
                        icon: const Icon(Icons.close),
                        label: const Text('НЕ ЗНАЮ', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade800,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () => _triggerFlyOutAndNext(true),
                        icon: const Icon(Icons.check),
                        label: const Text('ЗНАЮ!', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
