import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data.dart';
import 'sound.dart';

// ───────────────────────── DMC GAME SCREEN ─────────────────────────

class DMCGameScreen extends StatefulWidget {
  final String category;
  final VoidCallback onStatsUpdated;

  const DMCGameScreen({super.key, required this.category, required this.onStatsUpdated});

  @override
  State<DMCGameScreen> createState() => _DMCGameScreenState();
}

class _DMCGameScreenState extends State<DMCGameScreen> with SingleTickerProviderStateMixin {
  late List<Flashcard> _queue;
  int _total = 0, _mastered = 0, _combo = 0, _score = 0, _maxCombo = 0;
  bool _showFront = true, _isAnimating = false;
  Offset _drag = Offset.zero;
  Color? _flash;

  late final AnimationController _ctrl;
  Animation<Offset>? _anim;

  static const double _swipeDist = 100, _swipeVelo = 700;

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
    if (src.length > 25) src.removeRange(25, src.length);
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

    DmcAudio.playSlash();
    final width = MediaQuery.of(context).size.width;
    final target = Offset((knew ? 1 : -1) * width * 1.5, _drag.dy);

    setState(() {
      _isAnimating = true;
      _anim = Tween<Offset>(begin: _drag, end: target).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    });

    await _ctrl.forward(from: 0);
    if (!mounted) return;

    final card = _queue.removeAt(0);
    if (knew) {
      _combo++;
      _score += 100 * rankFor(_combo).mult;
      _mastered++;
      if (_combo > _maxCombo) _maxCombo = _combo;
      _flash = rankFor(_combo).color;
      DmcAudio.playCorrect();
      if ([2, 4, 6, 9, 12, 15].contains(_combo)) DmcAudio.playRankUp();
    } else {
      _combo = 0;
      _queue.add(card);
      _flash = Colors.red;
      DmcAudio.playWrong();
    }

    if (_queue.isEmpty) DmcAudio.playStageClear();

    setState(() {
      _showFront = true;
      _drag = Offset.zero;
      _isAnimating = false;
    });
    _ctrl.reset();

    Future.delayed(const Duration(milliseconds: 160), () {
      if (mounted) setState(() => _flash = null);
    });

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
    if (_drag.dx > _swipeDist || vx > _swipeVelo) {
      _answer(true);
    } else if (_drag.dx < -_swipeDist || vx < -_swipeVelo) {
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: border, width: 3)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: dark ? Colors.white12 : Colors.black12, borderRadius: BorderRadius.circular(8)),
                  child: Text(card.category, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                Text(front ? 'Лицевая' : 'Перевод', style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
            Expanded(
              child: Center(
                child: front
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (card.article.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.red.withAlpha(40),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.redAccent.withAlpha(120)),
                              ),
                              child: Text(card.article, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.redAccent)),
                            ),
                            const SizedBox(height: 10),
                          ],
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(card.german, textAlign: TextAlign.center, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                          ),
                          if (hint) ...[
                            const SizedBox(height: 20),
                            const Text('Нажмите для оборота · Свайп для ответа', style: TextStyle(color: Colors.grey, fontSize: 11)),
                          ],
                        ],
                      )
                    : SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(card.russian, textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: accent)),
                            if (card.explanation.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              const Divider(height: 1),
                              const SizedBox(height: 10),
                              Text(card.explanation, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, height: 1.4, fontStyle: FontStyle.italic)),
                            ],
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_total == 0) return Scaffold(appBar: AppBar(title: Text(widget.category)), body: const Center(child: Text('Нет карточек')));
    if (_queue.isEmpty) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events_rounded, size: 64, color: Colors.amberAccent),
                const SizedBox(height: 10),
                const Text('STAGE CLEAR!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.amberAccent)),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: Colors.red.shade900.withAlpha(45), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.redAccent)),
                  child: Column(
                    children: [
                      Text('СЧЕТ: $_score', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('МАКС. КОМБО: $_maxCombo STREAK', style: const TextStyle(fontSize: 16, color: Colors.amberAccent, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                  onPressed: _restart,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('ПРОЙТИ СНОВА', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('В ГЛАВНОЕ МЕНЮ')),
              ],
            ),
          ),
        ),
      );
    }

    final card = _queue.first;
    final rank = rankFor(_combo);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(
            icon: Icon(DmcAudio.soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded),
            onPressed: () => setState(() => DmcAudio.toggleSound()),
          ),
          IconButton(icon: const Icon(Icons.shuffle_rounded), onPressed: _restart),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // DMC SCORE BOARD WITH NEON GLOW & MULTIPLIER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                  decoration: BoxDecoration(
                    color: rank.color.withAlpha(35),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: rank.color, width: 2),
                    boxShadow: [BoxShadow(color: rank.color.withAlpha(40), blurRadius: 14)],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('SCORE ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                              Text('$_score', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                            ],
                          ),
                          Row(
                            children: [
                              Text('$_combo STREAK', style: TextStyle(color: rank.color, fontWeight: FontWeight.w900, fontSize: 14)),
                              if (rank.mult > 1) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(color: Colors.amberAccent.withAlpha(50), borderRadius: BorderRadius.circular(4)),
                                  child: Text('x${rank.mult}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      Text(rank.name, style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: rank.color)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: _mastered / _total, color: rank.color, minHeight: 5, borderRadius: BorderRadius.circular(4)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Выучено: $_mastered / $_total', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('В очереди: ${_queue.length}', style: const TextStyle(fontSize: 10, color: Colors.amberAccent, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _ctrl,
                    builder: (context, _) {
                      final off = (_isAnimating && _anim != null) ? _anim!.value : _drag;
                      final progress = (off.dx.abs() / 120).clamp(0.0, 1.0);
                      final border = off.dx > 40 ? Colors.greenAccent : (off.dx < -40 ? Colors.redAccent : Colors.transparent);

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          if (_queue.length > 1)
                            Transform.scale(
                              scale: 0.94 + 0.06 * progress,
                              child: Opacity(opacity: 0.5 + 0.5 * progress, child: _cardFace(_queue[1], front: true, border: Colors.transparent)),
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
                              child: Transform.rotate(angle: off.dx / 320, child: _cardFace(card, front: _showFront, border: border, hint: true)),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade900, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                        onPressed: () => _answer(false),
                        icon: const Icon(Icons.close_rounded, size: 20),
                        label: const Text('НЕ ЗНАЮ', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      style: IconButton.styleFrom(backgroundColor: Colors.white12, padding: const EdgeInsets.all(12)),
                      onPressed: () => setState(() => _showFront = !_showFront),
                      icon: const Icon(Icons.flip_rounded, color: Colors.amberAccent),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade800, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                        onPressed: () => _answer(true),
                        icon: const Icon(Icons.check_rounded, size: 20),
                        label: const Text('ЗНАЮ!', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
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
