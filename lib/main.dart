import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const FlashcardApp());
}

class FlashcardApp extends StatelessWidget {
  const FlashcardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'B2 Beruf Flashcards',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      home: const FlashcardScreen(),
    );
  }
}

class Flashcard {
  final String article;
  final String german;
  final String russian;
  final String explanation;

  Flashcard({
    required this.article,
    required this.german,
    required this.russian,
    required this.explanation,
  });

  Map<String, dynamic> toJson() => {
        'article': article,
        'german': german,
        'russian': russian,
        'explanation': explanation,
      };

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
        article: json['article'] ?? '',
        german: json['german'] ?? '',
        russian: json['russian'] ?? '',
        explanation: json['explanation'] ?? '',
      );
}

// Готовая начальная база B2 Beruf
final List<Flashcard> initialB2Cards = [
  Flashcard(
    article: 'die',
    german: 'Stellenausschreibung, -en',
    russian: 'Объявление о вакансии',
    explanation: 'Официальное публикация о поиске сотрудника. Пример: Die Stellenausschreibung passt genau zu meinem Profil.',
  ),
  Flashcard(
    article: 'das',
    german: 'Anschreiben, -',
    russian: 'Сопроводительное письмо',
    explanation: 'Главное письмо в резюме (Bewerbung). Пример: Das Anschreiben sollte prägnant und professionell sein.',
  ),
  Flashcard(
    article: '',
    german: 'Verhandlungsgeschick haben',
    russian: 'Обладать навыками ведения переговоров',
    explanation: 'Умение договариваться на выгодных условиях. Пример: Für den Vertrieb braucht man Verhandlungsgeschick.',
  ),
  Flashcard(
    article: 'die',
    german: 'Einarbeitungsphase, -n',
    russian: 'Период ввода в должность',
    explanation: 'Первое время на работе, когда вас обучают процессам. Пример: In der Einarbeitungsphase hilft mir ein Kollege.',
  ),
  Flashcard(
    article: '',
    german: 'Fristen einhalten (hielt ein, hat eingehalten)',
    russian: 'Соблюдать дедлайны / сроки',
    explanation: 'Выполнять работу точно вовремя. Пример: Wir müssen alle Fristen strikt einhalten.',
  ),
  Flashcard(
    article: 'die',
    german: 'Betriebsratssitzung, -en',
    russian: 'Заседание производственного совета',
    explanation: 'Встреча представителей работников с руководством. Пример: Die Betriebsratssitzung ist morgen Früh.',
  ),
  Flashcard(
    article: 'der',
    german: 'Arbeitsvertrag, -¨e',
    russian: 'Трудовой договор',
    explanation: 'Юридический документ между работодателем и работником. Пример: Ich habe den Arbeitsvertrag bereits unterschrieben.',
  ),
  Flashcard(
    article: 'die',
    german: 'Kündigungsfrist, -en',
    russian: 'Срок уведомления об увольнении',
    explanation: 'Время, которое нужно отработать после подачи заявления. Пример: Die Kündigungsfrist beträgt drei Monate.',
  ),
];

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  List<Flashcard> _cards = [];
  int _currentIndex = 0;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString('custom_b2_cards');

    if (savedData != null) {
      final List decoded = jsonDecode(savedData);
      setState(() {
        _cards = decoded.map((item) => Flashcard.fromJson(item)).toList();
      });
    } else {
      setState(() {
        _cards = List.from(initialB2Cards);
      });
    }
  }

  Future<void> _saveCards() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(_cards.map((c) => c.toJson()).toList());
    await prefs.setString('custom_b2_cards', encodedData);
  }

  void _nextCard() {
    if (_cards.isEmpty) return;
    setState(() {
      _showFront = true;
      _currentIndex = (_currentIndex + 1) % _cards.length;
    });
  }

  void _previousCard() {
    if (_cards.isEmpty) return;
    setState(() {
      _showFront = true;
      _currentIndex = (_currentIndex - 1 + _cards.length) % _cards.length;
    });
  }

  void _flipCard() {
    setState(() {
      _showFront = !_showFront;
    });
  }

  void _showAddCardDialog() {
    final articleController = TextEditingController();
    final germanController = TextEditingController();
    final russianController = TextEditingController();
    final explanationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить карточку'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: articleController,
                decoration: const InputDecoration(
                  labelText: 'Артикль (der / die / das или пусто)',
                ),
              ),
              TextField(
                controller: germanController,
                decoration: const InputDecoration(
                  labelText: 'Слово / Фраза (DE)*',
                ),
              ),
              TextField(
                controller: russianController,
                decoration: const InputDecoration(
                  labelText: 'Перевод (RU)*',
                ),
              ),
              TextField(
                controller: explanationController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Пояснение / Пример контекста',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              if (germanController.text.trim().isEmpty ||
                  russianController.text.trim().isEmpty) {
                return;
              }
              final newCard = Flashcard(
                article: articleController.text.trim(),
                german: germanController.text.trim(),
                russian: russianController.text.trim(),
                explanation: explanationController.text.trim(),
              );
              setState(() {
                _cards.add(newCard);
                _saveCards();
              });
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cards.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final card = _cards[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('B2 Beruf — Карточки'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCardDialog,
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _cards.length,
              backgroundColor: Colors.grey.shade300,
              color: Colors.indigo,
            ),
            const SizedBox(height: 12),
            Text(
              '${_currentIndex + 1} / ${_cards.length}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: GestureDetector(
                onTap: _flipCard,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, animation) {
                    final rotate = Tween(begin: pi, end: 0.0).animate(animation);
                    return AnimatedBuilder(
                      animation: rotate,
                      child: child,
                      builder: (context, child) {
                        final isUnder = (ValueKey(_showFront) != child?.key);
                        var tilt = (animation.value - 0.5).abs() - 0.5;
                        tilt *= -0.003;
                        final value =
                            isUnder ? min(rotate.value, pi / 2) : rotate.value;
                        return Transform(
                          transform: Matrix4.rotationY(value)..setEntry(3, 2, tilt),
                          alignment: Alignment.center,
                          child: child,
                        );
                      },
                    );
                  },
                  child: _showFront
                      ? _buildFrontCard(card, key: const ValueKey(true))
                      : _buildBackCard(card, key: const ValueKey(false)),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton.filledTonal(
                  onPressed: _previousCard,
                  icon: const Icon(Icons.arrow_back),
                  iconSize: 32,
                ),
                IconButton.filledTonal(
                  onPressed: _nextCard,
                  icon: const Icon(Icons.arrow_forward),
                  iconSize: 32,
                ),
              ],
            ),
            const SizedBox(height: 70), // Отступ под плавающую кнопку
          ],
        ),
      ),
    );
  }

  Widget _buildFrontCard(Flashcard card, {required Key key}) {
    return Card(
      key: key,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (card.article.isNotEmpty)
              Text(
                card.article,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: card.article == 'der'
                      ? Colors.blue.shade700
                      : card.article == 'die'
                          ? Colors.red.shade700
                          : Colors.green.shade700,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              card.german,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            Text(
              'Нажмите, чтобы перевернуть',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackCard(Flashcard card, {required Key key}) {
    return Card(
      key: key,
      elevation: 4,
      color: Colors.indigo.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              card.russian,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            if (card.explanation.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                'Пояснение / Пример:',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                card.explanation,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
