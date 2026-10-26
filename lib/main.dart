import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const B2AppRoot());

// ───────────────────────── ROOT / THEME ─────────────────────────

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

// ───────────────────────── DATA ─────────────────────────

class Flashcard {
  final String article, german, russian, explanation, category;
  const Flashcard(this.article, this.german, this.russian, this.explanation, this.category);
}

// Формат: артикль, немецкое слово, перевод, пример, категория
const List<Flashcard> initialB2Dataset = [
  Flashcard('die', 'Stellenausschreibung, -en', 'Объявление о вакансии',
      'Die Stellenausschreibung passt genau zu meinem Profil.', 'Bewerbung'),
  Flashcard('das', 'Anschreiben, -', 'Сопроводительное письмо',
      'Das Anschreiben sollte prägnant und professionell sein.', 'Bewerbung'),
  Flashcard('der', 'Lebenslauf, ¨-e', 'Резюме (CV)',
      'Bitte fügen Sie Ihren aktuellen Lebenslauf bei.', 'Bewerbung'),
  Flashcard('das', 'Vorstellungsgespräch, -e', 'Собеседование',
      'Ich habe morgen ein wichtiges Vorstellungsgespräch.', 'Bewerbung'),
  Flashcard('der', 'Arbeitsvertrag, ¨-e', 'Трудовой договор',
      'Ich habe den Arbeitsvertrag bereits unterschrieben.', 'Vertrag & Recht'),
  Flashcard('die', 'Probezeit, -en', 'Испытательный срок',
      'Während der Probezeit gilt eine verkürzte Kündigungsfrist.', 'Vertrag & Recht'),
  Flashcard('die', 'Kündigungsfrist, -en', 'Срок уведомления об увольнении',
      'Die Kündigungsfrist beträgt drei Monate.', 'Vertrag & Recht'),
  Flashcard('', 'Verhandlungsgeschick haben', 'Обладать навыками ведения переговоров',
      'Für den Vertrieb braucht man Verhandlungsgeschick.', 'Büroalltag'),
  Flashcard('', 'Fristen einhalten', 'Соблюдать сроки / дедлайны',
      'Wir müssen alle Fristen strikt einhalten.', 'Büroalltag'),
  Flashcard('die', 'Rückmeldung, -en', 'Обратная связь / Отклик',
      'Ich warte noch auf eine Rückmeldung vom Team.', 'Büroalltag'),
];

// ───────────────────────── RANKS ─────────────────────────

class Rank {
  final String name;
  final Color color;
  final int mult;
  const Rank(this.name, this.color, this.mult);
}

Rank rankFor(int combo) {
  if (combo >= 15) return const Rank('SSS', Colors.amberAccent, 5);
  if (combo >= 12) return const Rank('SS', Colors.orangeAccent, 4);
  if (combo >= 9) return const Rank('S', Colors.redAccent, 3);
  if (combo >= 6) return const Rank('A', Colors.purpleAccent, 2);
  if (combo >= 4) return const Rank('B', Colors.blueAccent, 2);
  if (combo >= 2) return const Rank('C', Colors.greenAccent, 1);
  if (combo >= 1) return const Rank('D', Colors.grey, 1);
  return const Rank('-', Colors.grey, 1);
}

// ───────────────────────── DASHBOARD ─────────────────────────

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

// ───────────────────────── GAME ─────────────────────────

class DMCGameScreen extends StatefulWidget {
  final String category;
  final VoidCallback onStatsUpdated;

  const DMCGameScreen({super.key, required this.category, required this.onStatsUpdated});

  @override
  State<DMCGameScreen> createState() => _DMCGameScreenState();
}

class _DMCGameScreenState extends State<DMCGameScreen> with SingleTickerProviderStateMixin {
  // «НЕ ЗНАЮ» возвращает карточку в конец очереди, раунд идёт, пока очередь не пуста.
  late List<Flashcard> _queue;
  int _total = 0, _mastered = 0, _combo = 0, _score = 0, _maxCombo = 0;
  bool _showFront = true;
  bool _isAnimating = false;
  Offset _drag = Offset.zero;
  Color? _flash;

  late final AnimationController _ctrl;
  Animation<Offset>? _anim;

  static const double _swipeDistance = 100;
  static const double _swipeVelocity = 700;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
    _resetRound();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _resetRound() {
    final src = widget.category == 'Все карточки'
        ? List<Flashcard>.from(initialB2Dataset)
        : initialB2Dataset.where((c) => c.category == widget.category).toList();
    src.shuffle();
    _queue = src;
    _total = src.length;
    _mastered = 0;
    _combo = 0;
    _score = 0;
    _maxCombo = 0;
    _showFront = true;
    _drag = Offset.zero;
    _isAnimating = false;
    _flash = null;
  }

  void _restart() {
    if (_isAnimating) return;
    setState(_resetRound);
  }

  Future<void> _answer(bool knew) async {
    if (_isAnimating || _queue.isEmpty) return;

    final width = MediaQuery.of(context).size.width;
    final target = Offset((knew ? 1 : -1) * width * 1.5, _drag.dy);

    setState(() {
      _isAnimating = true;
      _anim = Tween<Offset>(begin: _drag, end: target)
          .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    });

    await _ctrl.forward(from: 0);
    if (!mounted) return;

    // Состояние меняем в ОДНОМ setState, чтобы не было кадра с «откатом» карточки.
    setState(() {
      final card = _queue.removeAt(0);
      if (knew) {
        _combo++;
        _score += 100 * rankFor(_combo).mult;
        _mastered++;
        if (_combo > _maxCombo) _maxCombo = _combo;
      } else {
        _combo = 0;
        _queue.add(card);
      }
      _flash = knew ? rankFor(_combo).color : Colors.red;
      _showFront = true;
      _drag = Offset.zero;
      _isAnimating = false;
    });
    _ctrl.reset();

    Future.delayed(const Duration(milliseconds: 160), () {
      if (mounted) setState(() => _flash = null);
    });

    // Сохранение статистики — уже после обновления интерфейса.
    final p = await SharedPreferences.getInstance();
    await p.setInt('total_cards_studied', (p.getInt('total_cards_studied') ?? 0) + 1);
    if (_maxCombo > (p.getInt('max_combo_record') ?? 0)) {
      await p.setInt('max_combo_record', _maxCombo);
    }
    widget.onStatsUpdated();
  }

  void _onPanEnd(DragEndDetails d) {
    if (_isAnimating) return;
    final vx = d.velocity.pixelsPerSecond.dx;
    if (_drag.dx > _swipeDistance || vx > _swipeVelocity) {
      _answer(true);
    } else if (_drag.dx < -_swipeDistance || vx < -_swipeVelocity) {
      _answer(false);
    } else {
      setState(() => _drag = Offset.zero);
    }
  }

  Widget _cardFace(Flashcard card, {required bool front, required Color border, bool hint = false}) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = dark ? Colors.amberAccent : Colors.deepOrange;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: border, width: 3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: front
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (card.article.isNotEmpty)
                      Text(card.article,
                          style: const TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                    const SizedBox(height: 10),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(card.german,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    ),
                    if (hint) ...[
                      const SizedBox(height: 30),
                      const Text('Нажмите, чтобы перевернуть | Свайп для ответа',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(card.russian,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: accent)),
                    ),
                    if (card.explanation.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 10),
                      Text(card.explanation,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic)),
                    ],
                  ],
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_total == 0) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.category)),
        body: const Center(child: Text('Нет карточек в этой категории')),
      );
    }
    if (_queue.isEmpty) return _buildResultScreen();

    final card = _queue.first;
    final rank = rankFor(_combo);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        actions: [
          IconButton(icon: const Icon(Icons.shuffle), tooltip: 'Начать заново', onPressed: _restart),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                // DMC SCORE BOARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: rank.color.withAlpha(38),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: rank.color, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SCORE: $_score',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('COMBO: $_combo STREAK',
                              style: TextStyle(
                                  color: rank.color, fontWeight: FontWeight.w900, fontSize: 16)),
                        ],
                      ),
                      Text(rank.name,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            color: rank.color,
                            shadows: [Shadow(color: rank.color, blurRadius: 12)],
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: _mastered / _total, color: rank.color),
                const SizedBox(height: 6),
                Text('Выучено $_mastered / $_total  ·  в очереди ${_queue.length}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 14),

                // КАРТОЧКА: подложка + активная карта
                Expanded(
                  child: AnimatedBuilder(
                    animation: _ctrl,
                    builder: (context, _) {
                      final off = (_isAnimating && _anim != null) ? _anim!.value : _drag;
                      final progress = (off.dx.abs() / 120).clamp(0.0, 1.0);
                      final border = off.dx > 40
                          ? Colors.green
                          : (off.dx < -40 ? Colors.red : Colors.transparent);

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          if (_queue.length > 1)
                            Transform.scale(
                              scale: 0.93 + 0.07 * progress,
                              child: Opacity(
                                opacity: 0.6 + 0.4 * progress,
                                child: _cardFace(_queue[1], front: true, border: Colors.transparent),
                              ),
                            ),
                          GestureDetector(
                            onPanUpdate: (d) {
                              if (_isAnimating) return;
                              setState(() => _drag += d.delta);
                            },
                            onPanEnd: _onPanEnd,
                            onTap: () {
                              if (_isAnimating) return;
                              setState(() => _showFront = !_showFront);
                            },
                            child: Transform.translate(
                              offset: off,
                              child: Transform.rotate(
                                angle: off.dx / 350,
                                child: _cardFace(card, front: _showFront, border: border, hint: true),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // КНОПКИ
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade900,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () => _answer(false),
                        icon: 
