import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data.dart';
import 'sound.dart';

class LesenQuestion {
  final String category, gapSentence, correctWord, russian, explanation;
  final List<String> options;
  const LesenQuestion({
    required this.category,
    required this.gapSentence,
    required this.correctWord,
    required this.options,
    required this.russian,
    required this.explanation,
  });
}

class LesenScreen extends StatefulWidget {
  final VoidCallback onStatsUpdated;
  const LesenScreen({super.key, required this.onStatsUpdated});

  @override
  State<LesenScreen> createState() => _LesenScreenState();
}

class _LesenScreenState extends State<LesenScreen> {
  final List<LesenQuestion> _questions = [];
  int _idx = 0, _score = 0, _combo = 0, _maxCombo = 0, _correctCount = 0;
  String? _selected;
  bool _answered = false;
  Color? _flash;

  @override
  void initState() {
    super.initState();
    _generateQuiz();
  }

  void _generateQuiz() {
    _questions.clear();
    final rng = Random();
    final candidates = initialB2Dataset.where((c) => c.explanation.length > 12).toList()..shuffle();

    for (final card in candidates) {
      if (_questions.length >= 15) break;
      final lines = card.explanation.split('\n');
      final germanSentence = lines[0].trim();
      final russianSentence = lines.length > 1 ? lines[1].trim() : card.russian;

      final words = card.german.replaceAll(RegExp(r',.*$'), '').trim().split(RegExp(r'\s+'));
      String target = '';
      for (final w in words) {
        if (w.length >= 4 && !['oder', 'über', 'nach', 'eine', 'einen'].contains(w.toLowerCase())) {
          if (germanSentence.toLowerCase().contains(w.toLowerCase())) {
            target = w;
            break;
          }
        }
      }
      if (target.isEmpty) continue;

      final regex = RegExp('\\b$target\\b', caseSensitive: false);
      final match = regex.firstMatch(germanSentence);
      if (match == null) continue;
      final actualWord = match.group(0)!;
      final gapSentence = germanSentence.replaceFirst(regex, '[ ___ ]');

      // 3 distractors
      final distractors = initialB2Dataset
          .where((c) => c.german != card.german)
          .map((c) => c.german.split(' ').firstWhere((w) => w.length >= 4, orElse: () => ''))
          .where((w) => w.isNotEmpty && w.toLowerCase() != actualWord.toLowerCase())
          .toSet()
          .toList()
        ..shuffle();

      if (distractors.length < 3) continue;
      final options = [actualWord, ...distractors.take(3)]..shuffle();

      _questions.add(LesenQuestion(
        category: card.category,
        gapSentence: gapSentence,
        correctWord: actualWord,
        options: options,
        russian: russianSentence,
        explanation: card.explanation,
      ));
    }

    setState(() {
      _idx = 0;
      _score = 0;
      _combo = 0;
      _maxCombo = 0;
      _correctCount = 0;
      _selected = null;
      _answered = false;
    });
  }

  void _answer(String opt) {
    if (_answered || _questions.isEmpty) return;
    final q = _questions[_idx];
    final isRight = opt.toLowerCase() == q.correctWord.toLowerCase();

    setState(() {
      _selected = opt;
      _answered = true;
      if (isRight) {
        _combo++;
        _correctCount++;
        _score += 120 * rankFor(_combo).mult;
        if (_combo > _maxCombo) _maxCombo = _combo;
        _flash = rankFor(_combo).color;
        DmcAudio.playCorrect();
        if ([2, 4, 6, 9, 12, 15].contains(_combo)) DmcAudio.playRankUp();
      } else {
        _combo = 0;
        _flash = Colors.red;
        DmcAudio.playWrong();
      }
    });

    Future.delayed(const Duration(milliseconds: 160), () {
      if (mounted) setState(() => _flash = null);
    });

    SharedPreferences.getInstance().then((p) {
      p.setInt('total_cards_studied', (p.getInt('total_cards_studied') ?? 0) + 1);
      if (_maxCombo > (p.getInt('max_combo_record') ?? 0)) {
        p.setInt('max_combo_record', _maxCombo);
      }
      widget.onStatsUpdated();
    });
  }

  void _next() {
    if (_idx + 1 >= _questions.length) {
      DmcAudio.playStageClear();
      setState(() => _idx++);
    } else {
      DmcAudio.playSlash();
      setState(() {
        _idx++;
        _selected = null;
        _answered = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final rank = rankFor(_combo);

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('LESEN')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_idx >= _questions.length) {
      final acc = ((_correctCount / _questions.length) * 100).round();
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.menu_book_rounded, size: 64, color: Colors.purpleAccent),
                const SizedBox(height: 12),
                const Text('STAGE CLEAR!',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.purpleAccent, letterSpacing: 2)),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.purple.withAlpha(40),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.purpleAccent),
                  ),
                  child: Column(
                    children: [
                      Text('СЧЕТ: $_score', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('ТОЧНОСТЬ: $acc% ($_correctCount из ${_questions.length})',
                          style: const TextStyle(fontSize: 16, color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('МАКС. КОМБО: $_maxCombo STREAK',
                          style: const TextStyle(fontSize: 16, color: Colors.amberAccent, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _generateQuiz,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('НОВЫЙ ТЕСТ', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('В МЕНЮ')),
              ],
            ),
          ),
        ),
      );
    }

    final q = _questions[_idx];

    return Scaffold(
      appBar: AppBar(
        title: const Text('LESEN: Sprachbausteine', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(
            icon: Icon(DmcAudio.soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded),
            onPressed: () => setState(() => DmcAudio.toggleSound()),
          ),
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _generateQuiz),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                // Top DMC Mini Meter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: rank.color.withAlpha(35),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: rank.color, width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('SCORE: $_score', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('${_idx + 1} / ${_questions.length}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(rank.name, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: rank.color)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Question Box
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: Colors.purple.withAlpha(40), borderRadius: BorderRadius.circular(8)),
                          child: Text(q.category, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.purpleAccent)),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _answered ? q.gapSentence.replaceAll('[ ___ ]', '[ ${q.correctWord} ]') : q.gapSentence,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                            color: _answered ? Colors.greenAccent : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 10),
                        Text('«${q.russian}»', style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // 4 Options
                Expanded(
                  child: ListView.builder(
                    itemCount: q.options.length,
                    itemBuilder: (_, i) {
                      final opt = q.options[i];
                      final isCorrect = opt.toLowerCase() == q.correctWord.toLowerCase();
                      final isChosen = _selected == opt;

                      Color bg = dark ? Colors.white10 : Colors.grey.shade200;
                      Color textCol = dark ? Colors.white : Colors.black87;
                      BorderSide side = BorderSide.none;

                      if (_answered) {
                        if (isCorrect) {
                          bg = Colors.green.shade800;
                          textCol = Colors.white;
                          side = const BorderSide(color: Colors.greenAccent, width: 2);
                        } else if (isChosen) {
                          bg = Colors.red.shade900;
                          textCol = Colors.white;
                          side = const BorderSide(color: Colors.redAccent, width: 2);
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Material(
                          color: bg,
                          borderRadius: BorderRadius.circular(14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: side),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: _answered ? null : () => _answer(opt),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.black26,
                                    child: Text(String.fromCharCode(65 + i), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(child: Text(opt, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textCol))),
                                  if (_answered && isCorrect) const Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
                                  if (_answered && isChosen && !isCorrect) const Icon(Icons.cancel_rounded, color: Colors.redAccent),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_answered)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _next,
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: Text(_idx + 1 >= _questions.length ? 'ЗАВЕРШИТЬ ТЕСТ' : 'СЛЕДУЮЩИЙ ВОПРОС',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                color: _flash?.withAlpha(75) ?? Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
