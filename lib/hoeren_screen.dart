import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'hoeren_data.dart';
import 'sound.dart';

class HoerenScreen extends StatefulWidget {
  final VoidCallback? onStatsUpdated;
  const HoerenScreen({super.key, this.onStatsUpdated});

  @override
  State<HoerenScreen> createState() => _HoerenScreenState();
}

class _HoerenScreenState extends State<HoerenScreen> {
  final FlutterTts _tts = FlutterTts();
  int _currentIndex = 0;
  int _selectedTeil = 0;
  int _combo = 0;
  int _score = 0;
  bool _isPlaying = false;
  bool _showTranscript = false;
  String? _selectedOption;
  bool _isAnswerChecked = false;
  bool _isCorrect = false;

  final TextEditingController _callerCtrl = TextEditingController();
  final TextEditingController _companyCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _reasonCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('de-DE');
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);
      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _isPlaying = false);
      });
      _tts.setErrorHandler((_) {
        if (mounted) setState(() => _isPlaying = false);
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _tts.stop();
    _callerCtrl.dispose();
    _companyCtrl.dispose();
    _phoneCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  List<HoerenTask> get _filteredTasks {
    if (_selectedTeil == 0) return b2HoerenTasks;
    return b2HoerenTasks.where((t) => t.teil == _selectedTeil).toList();
  }

  HoerenTask get _currentTask => _filteredTasks[_currentIndex];

  String get _rankName {
    if (_combo >= 15) return 'SSS';
    if (_combo >= 11) return 'SS';
    if (_combo >= 8) return 'S';
    if (_combo >= 6) return 'A';
    if (_combo >= 4) return 'B';
    if (_combo >= 2) return 'C';
    return 'D';
  }

  Color get _rankColor {
    if (_combo >= 15) return Colors.purpleAccent;
    if (_combo >= 8) return Colors.amberAccent;
    if (_combo >= 6) return Colors.greenAccent;
    if (_combo >= 4) return Colors.cyanAccent;
    return Colors.grey.shade400;
  }

  Future<void> _toggleAudio() async {
    DmcAudio.playSlash();
    if (_isPlaying) {
      await _tts.stop();
      setState(() => _isPlaying = false);
    } else {
      setState(() => _isPlaying = true);
      final text = '${_currentTask.situation} ... ${_currentTask.transcript}';
      await _tts.speak(text);
    }
  }

  void _checkAnswer() {
    if (_isAnswerChecked) return;
    bool correct = false;
    if (_currentTask.teil == 5) {
      correct = _callerCtrl.text.trim().isNotEmpty || _companyCtrl.text.trim().isNotEmpty;
    } else {
      correct = _selectedOption == _currentTask.correctAnswer;
    }

    setState(() {
      _isAnswerChecked = true;
      _isCorrect = correct;
      if (correct) {
        _combo++;
        final mult = _combo >= 8 ? 4 : (_combo >= 4 ? 2 : 1);
        _score += 100 * mult;
        if (_combo == 4 || _combo == 8 || _combo == 15) {
          DmcAudio.playRankUp();
        } else {
          DmcAudio.playCorrect();
        }
        if (_combo % 5 == 0) DmcAudio.playStageClear();
      } else {
        _combo = 0;
        DmcAudio.playWrong();
      }
    });
  }

  void _nextTask() {
    _tts.stop();
    DmcAudio.playSlash();
    setState(() {
      _isPlaying = false;
      _selectedOption = null;
      _isAnswerChecked = false;
      _isCorrect = false;
      _showTranscript = false;
      _callerCtrl.clear();
      _companyCtrl.clear();
      _phoneCtrl.clear();
      _reasonCtrl.clear();
      if (_currentIndex + 1 < _filteredTasks.length) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final task = _currentTask;

    return Scaffold(
      appBar: AppBar(
        title: const Text('HÖREN: DTB B2', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        backgroundColor: Colors.red.shade900,
        actions: [
          IconButton(
            icon: Icon(DmcAudio.soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded),
            onPressed: () {
              setState(() => DmcAudio.toggleSound());
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // DMC SCORE BAR
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.black, const Color(0xFF450A0A)]),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.red.shade800),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SCORE: $_score', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('STREAK: $_combo COMBO', style: TextStyle(color: _rankColor, fontWeight: FontWeight.w900, fontSize: 18)),
                    ],
                  ),
                  Text(_rankName, style: TextStyle(color: _rankColor, fontSize: 32, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // TEIL FILTER CHIPS
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [0, 1, 2, 3, 4, 5].map((t) {
                  final label = t == 0 ? 'Alle' : 'Teil $t';
                  final isSel = _selectedTeil == t;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(label, style: TextStyle(color: isSel ? Colors.white : Colors.grey, fontSize: 12)),
                      selected: isSel,
                      selectedColor: Colors.red.shade800,
                      onSelected: (_) {
                        setState(() {
                          _selectedTeil = t;
                          _currentIndex = 0;
                          _isAnswerChecked = false;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // TASK CARD
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    const SizedBox(height: 6),
                    Text('Situation: ${task.situation}', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13, color: Colors.grey)),
                    const Divider(height: 20),

                    // AUDIO CONTROLLER BUTTON
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isPlaying ? Colors.amber.shade800 : Colors.red.shade800,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _toggleAudio,
                      icon: Icon(_isPlaying ? Icons.pause_circle_rounded : Icons.play_circle_fill_rounded, size: 26),
                      label: Text(_isPlaying ? 'PAUSE / STOPP' : 'HÖRTEXT ABSPIELEN (DEUTSCH)'),
                    ),
                    const SizedBox(height: 8),

                    // TRANSCRIPT EXPAND
                    TextButton(
                      onPressed: () => setState(() => _showTranscript = !_showTranscript),
                      child: Text(_showTranscript ? 'Transkript verbergen ▲' : 'Transkript anzeigen ▼', style: const TextStyle(fontSize: 12)),
                    ),
                    if (_showTranscript)
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
                        child: Text(task.transcript, style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
                      ),

                    // QUESTION OR PHONE NOTE
                    if (task.teil == 5) ...[
                      const Text('📝 TELEFONNOTIZ AUSFÜLLEN:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      TextField(controller: _callerCtrl, decoration: const InputDecoration(labelText: 'Name des Anrufers', border: OutlineInputBorder())),
                      const SizedBox(height: 8),
                      TextField(controller: _companyCtrl, decoration: const InputDecoration(labelText: 'Firma / Betrieb', border: OutlineInputBorder())),
                      const SizedBox(height: 8),
                      TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Telefonnummer', border: OutlineInputBorder())),
                      const SizedBox(height: 8),
                      TextField(controller: _reasonCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Grund des Anrufs / Notiz', border: OutlineInputBorder())),
                      if (_isAnswerChecked && task.caller != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.green.shade900.withAlpha(80), borderRadius: BorderRadius.circular(10)),
                          child: Text('Musterlösung:\nAnrufer: ${task.caller}\nFirma: ${task.company}\nTel: ${task.phone}\nGrund: ${task.reason}', style: const TextStyle(fontSize: 12, color: Colors.white)),
                        ),
                      ],
                    ] else ...[
                      Text(task.question, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 10),
                      ...task.options.map((opt) {
                        final isSel = _selectedOption == opt;
                        Color? btnColor;
                        if (_isAnswerChecked) {
                          if (opt == task.correctAnswer) btnColor = Colors.green.shade700;
                          else if (isSel) btnColor = Colors.red.shade700;
                        } else if (isSel) {
                          btnColor = Colors.red.shade900;
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: btnColor,
                              foregroundColor: btnColor != null ? Colors.white : null,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _isAnswerChecked ? null : () => setState(() => _selectedOption = opt),
                            child: Align(alignment: Alignment.centerLeft, child: Text(opt, style: const TextStyle(fontSize: 13))),
                          ),
                        );
                      }),
                      if (_isAnswerChecked)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text('Erklärung: ${task.explanation}', style: TextStyle(color: _isCorrect ? Colors.greenAccent : Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                    ],

                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (!_isAnswerChecked)
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                              onPressed: _checkAnswer,
                              child: const Text('ANTWORT PRÜFEN', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          )
                        else
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                              onPressed: _nextTask,
                              child: const Text('NÄCHSTE AUFGABE ➔', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
