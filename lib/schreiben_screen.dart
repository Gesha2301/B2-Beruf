import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data.dart';
import 'sound.dart';

class SchreibenScreen extends StatefulWidget {
  const SchreibenScreen({super.key});

  @override
  State<SchreibenScreen> createState() => _SchreibenScreenState();
}

class _SchreibenScreenState extends State<SchreibenScreen> {
  int _selectedTaskIdx = 0;
  final TextEditingController _ctrl = TextEditingController();
  Timer? _timer;
  int _secondsLeft = 25 * 60;
  bool _isRunning = false;
  String _nvvSearch = '';

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _secondsLeft = b2SchreibenTasks[_selectedTaskIdx].minutes * 60;
      _isRunning = false;
    });
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_secondsLeft > 0) {
          setState(() => _secondsLeft--);
        } else {
          t.cancel();
          setState(() => _isRunning = false);
          DmcAudio.playStageClear();
        }
      });
      setState(() => _isRunning = true);
    }
  }

  int get _wordCount {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length;
  }

  void _insertText(String phrase) {
    DmcAudio.playSlash();
    final text = _ctrl.text;
    final sel = _ctrl.selection;
    if (sel.isValid && sel.start >= 0) {
      final newText = text.replaceRange(sel.start, sel.end, ' $phrase ');
      _ctrl.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: sel.start + phrase.length + 2),
      );
    } else {
      _ctrl.text = text.isEmpty ? phrase : '$text $phrase';
    }
    setState(() {});
  }

  void _showNvvSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final nvvList = initialB2Dataset
              .where((c) => c.category == 'Nomen-Verb-Verbindungen')
              .where((c) => c.german.toLowerCase().contains(_nvvSearch.toLowerCase()) || c.russian.toLowerCase().contains(_nvvSearch.toLowerCase()))
              .toList();

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
            child: SizedBox(
              height: 480,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('База 218 Nomen-Verb-Verbindungen', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Поиск выражения или перевода...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onChanged: (v) {
                      setSheetState(() => _nvvSearch = v);
                    },
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: nvvList.length,
                      itemBuilder: (_, i) {
                        final card = nvvList[i];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(card.german, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text(card.russian, style: const TextStyle(fontSize: 12)),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade900, foregroundColor: Colors.white),
                            onPressed: () {
                              _insertText(card.german);
                              Navigator.pop(ctx);
                            },
                            child: const Text('+ Вставить', style: TextStyle(fontSize: 11)),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final task = b2SchreibenTasks[_selectedTaskIdx];
    final minM = _secondsLeft ~/ 60;
    final secS = _secondsLeft % 60;
    final timeStr = '${minM.toString().padLeft(2, '0')}:${secS.toString().padLeft(2, '0')}';
    final progress = (_wordCount / task.minWords).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SCHREIBEN: B2 Тренажер', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: 'Скопировать текст',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _ctrl.text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Текст скопирован в буфер обмена!'), duration: Duration(seconds: 2)),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown task selection
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: _selectedTaskIdx,
                  items: List.generate(
                    b2SchreibenTasks.length,
                    (i) => DropdownMenuItem(value: i, child: Text(b2SchreibenTasks[i].title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                  ),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _selectedTaskIdx = v);
                      _resetTimer();
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Situation card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.situation, style: const TextStyle(fontSize: 13, height: 1.4)),
                    const SizedBox(height: 10),
                    const Text('Обязательные пункты (Leitpunkte):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.amberAccent)),
                    ...task.points.map((p) => Padding(
                          padding: const EdgeInsets.only(top: 3, left: 4),
                          child: Text('• $p', style: const TextStyle(fontSize: 12)),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Timer & Word Counter Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ТАЙМЕР', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                            Text(timeStr, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: _secondsLeft < 180 ? Colors.redAccent : null)),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(_isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.amberAccent),
                              onPressed: _toggleTimer,
                            ),
                            IconButton(icon: const Icon(Icons.refresh_rounded, size: 20), onPressed: _resetTimer),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(14)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('СЛОВА', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                            Text('${(progress * 100).toInt()}%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: progress >= 1 ? Colors.greenAccent : Colors.amberAccent)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('$_wordCount / ${task.minWords}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Quick suggested NVV chips
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Рекомендуемые NVV:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                TextButton(
                  onPressed: _showNvvSheet,
                  child: const Text('Все 218 NVV ↗', style: TextStyle(fontSize: 11, color: Colors.amberAccent)),
                ),
              ],
            ),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: task.suggestedNVV.map((nvv) => ActionChip(
                    label: Text('+ $nvv', style: const TextStyle(fontSize: 11)),
                    backgroundColor: Colors.amber.withAlpha(30),
                    side: BorderSide(color: Colors.amber.withAlpha(70)),
                    onPressed: () => _insertText(nvv),
                  )).toList(),
            ),
            const SizedBox(height: 12),
            // Main Text Editor
            TextField(
              controller: _ctrl,
              maxLines: 12,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Sehr geehrte Damen und Herren,\n\nich beziehe mich auf...\n',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.black26 : Colors.white,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
