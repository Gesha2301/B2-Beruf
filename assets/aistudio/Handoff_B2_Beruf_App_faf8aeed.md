# Передача проекта: приложение «B2 Beruf DMC Flashcards»

Это сводка прошлого чата. Вставьте файл целиком в новый чат и напишите: «Продолжи с раздела "Что делать дальше"».

## 1. Цель
Мобильное приложение на Flutter для подготовки к экзамену B2 Beruf (немецкий). Механика в стиле Devil May Cry: ранги D–SSS, комбо, множитель очков, вспышки экрана, экран STAGE CLEAR. Три режима в одном приложении: **Карточки**, **Lesen**, **Schreiben** (тренировать отдельно). Режим Hören не нужен.

## 2. Как работает пользователь (важно для ассистента)
- Всё делает с телефона (Android), репозиторий на GitHub через мобильный браузер. Компьютера нет.
- Говорит по-русски. Хочет минимум действий: код лучше давать блоками в чате, чтобы копировать. Файлы допустимы, когда он сам просит или когда текста слишком много.
- Бесплатный тариф Claude: лимиты по сессиям, длинные чаты быстро съедают лимит. Лучше короткие ответы и новые чаты по этапам.
- Сборка: GitHub Actions выдаёт APK на каждый коммит (Flutter 3.47.8 stable, Java 17). Ошибки пользователь присылает скриншотами лога шага «Build APK».

## 3. Ловушки, на которые уже наступили
1. **Обрезка при вставке.** Веб-редактор GitHub с телефона обрезает вставленный текст около 540 строк. Файл на 634 строки сломал сборку. Решение: файлы не длиннее ~400 строк. Всегда просить проверить, что последняя строка файла `}`.
2. **Регистр имени файла.** `Data.dart` вместо `data.dart` дало ошибку «No such file» на Linux-сборке. Имена только строчными: `data.dart`, `game_screen.dart`.
3. `withOpacity` в новых Flutter устарел, используем `withAlpha(...)`.
4. `AnimatedBuilder` проверял `isAnimating` контроллера, из-за чего карточка на кадр «откатывалась» в центр. Исправлено флагом `_isAnimating` и одним `setState` после анимации.
5. Копирование между Диском и GitHub пользователь считает слишком долгим.

## 4. Структура репозитория (GitHub: B2-Beruf, пакет `b2_cards`)
```
.github/workflows/...      # сборка APK (flutter create . + flutter build apk)
lib/main.dart              # запуск, тема (светлая/тёмная, SharedPreferences)
lib/data.dart              # Flashcard, Rank, rankFor(), initialB2Dataset (пока 10 карточек)
lib/dashboard.dart         # главный экран: рекорд, список категорий
lib/game_screen.dart       # игра: свайпы, очередь, ранги, STAGE CLEAR
pubspec.yaml               # зависимость shared_preferences
```
Состояние: этот код собирается и работает на телефоне. Реализовано: свайп вправо = ЗНАЮ, влево = НЕ ЗНАЮ (и кнопки), быстрый бросок по скорости, подложка со следующей карточкой, вспышка экрана, «НЕ ЗНАЮ» возвращает карточку в конец очереди, прогресс «выучено / в очереди», рекорд комбо и счётчик карточек в SharedPreferences.

## 5. Исходные материалы пользователя
Архив «App data b2» (1 ГБ+): почти всё это mp3 (папки Hören_Teil_1–4, Lesen_*, Sprech*, Telefonnotiz, Forumsbeitrag, modelltest и др.). Текстовые материалы только три PDF:
1. **Nomen-Verb-Verbindungen (картинка, 12 стр., личные заметки):** ~170 выражений с переводом (смесь русского и украинского) и примерами. Текстового слоя нет, OCR без немецкого языка недоступен, я перенёс вручную.
2. **Nomen-Verb-Verbindungen (4 стр.):** 100 выражений: Bedeutung (немецкий синоним) + пример.
3. **Тематический словарь (75 стр.):** 686 слов и выражений в 59 темах (Auf Geschäftsreise, Auf der Messe, Arbeitsschutz, Besprechungen, Arbeitsvertrag und Kündigung и др.) с русским переводом и примером с переводом.

## 6. Что сделано с данными (результат: `cards.json`, 904 карточки)
- 218 карточек категории «Nomen-Verb-Verbindungen»: объединены PDF 1 и PDF 2 (дубли склеены, у склеенных в explanation добавлена строка `≈ Bedeutung`), русские переводы нормализованы, опечатки исправлены.
- 686 карточек из тематического словаря с категориями по темам. Артикль (der/die/das) вынесен в отдельное поле. Артефакты извлечения («da s» → «das», «ei ne» → «eine» и т. п.) почищены, но выборочная проверка глазами не помешает.
- Формат записи:
```json
{"article": "die", "german": "Anreise", "russian": "поездка",
 "explanation": "Немецкий пример\nРусский перевод примера", "category": "Auf Geschäftsreise"}
```
Модель `Flashcard` в приложении не менялась: поле `explanation` просто содержит две строки (пример и перевод). Из-за этого `game_screen.dart` менять для показа не нужно.

## 7. Что делать дальше
**Шаг 1. Подключить cards.json (не сделано).**
- Положить файл в `assets/cards.json` в репозитории.
- В `pubspec.yaml` добавить в секцию `flutter:` строки `assets:` и `- assets/cards.json` (с правильными отступами в 2 и 4 пробела).
- В `data.dart`: сделать `List<Flashcard> initialB2Dataset = [];` (не const), добавить `Flashcard.fromJson` и `Future<void> loadCards()` через `rootBundle.loadString('assets/cards.json')`. Оставить 10 старых карточек как запасные, если файл не прочитался.
- В `main.dart`: `Future<void> main() async { WidgetsFlutterBinding.ensureInitialized(); await loadCards(); runApp(const B2AppRoot()); }` и импорт `data.dart`.
- В `dashboard.dart`: список категорий строить из данных (`'Все карточки'` + уникальные `category` по порядку) и показывать количество карточек в подзаголовке.
- В `game_screen.dart` в `_resetRound()` после `src.shuffle();` добавить `if (src.length > 25) src.removeRange(25, src.length);`, иначе раунд из 900 карточек слишком длинный.

**Шаг 2. Меню на три режима** (Карточки / Lesen / Schreiben) на главном экране.

**Шаг 3. Lesen.** Готовых заданий нет, материалы только карточки. Предложение: упражнения с пропуском (как Sprachbausteine) из примеров в `cards.json`: предложение с пропущенным выражением, выбор из 3–4 вариантов, счёт.

**Шаг 4. Schreiben.** Задания пишет ассистент (форумный пост, деловое письмо, Telefonnotiz), в приложении таймер, счётчик слов, поле для текста и список подходящих Nomen-Verb-Verbindungen как подсказка. Проверки текста в приложении нет.

**Идеи на потом:** интервальное повторение (запоминать выученные слова), озвучка `flutter_tts`, режим «перевод → слово», иконка и название приложения.

## 8. Текущий код

### lib/main.dart
```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';

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

```

### lib/data.dart
```dart
import 'package:flutter/material.dart';

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

```

### lib/dashboard.dart
```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_screen.dart';

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

```

### lib/game_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data.dart';

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
                        onPressed: () => _answer(true),
                        icon: const Icon(Icons.check),
                        label: const Text('ЗНАЮ!', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // ВСПЫШКА ЭКРАНА
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                color: _flash?.withAlpha(70) ?? Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('STAGE CLEAR!',
                  style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: Colors.amberAccent)),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.shade900.withAlpha(51),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.redAccent, width: 2),
                ),
                child: Column(
                  children: [
                    Text('ФИНАЛЬНЫЙ СЧЕТ: $_score',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text('МАКС. КОМБО: $_maxCombo STREAK',
                        style: const TextStyle(
                            fontSize: 18, color: Colors.amberAccent, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                onPressed: _restart,
                icon: const Icon(Icons.refresh),
                label: const Text('ПРОЙТИ СНОВА',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('В ГЛАВНОЕ МЕНЮ', style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```
