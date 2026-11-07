import 'dart:math';
import 'package:flutter/material.dart';
import 'data.dart';
import 'sound.dart';
import 'card_face.dart';
import 'score_bar.dart';

class CardsTab extends StatefulWidget {
  final int maxCombo;
  final Function(int combo, int delta) onStatsUpdated;

  const CardsTab({super.key, required this.maxCombo, required this.onStatsUpdated});

  @override
  State<CardsTab> createState() => _CardsTabState();
}

class _CardsTabState extends State<CardsTab> with SingleTickerProviderStateMixin {
  String _selectedCategory = 'Все карточки';
  int _cardLimit = 25;
  List<Flashcard> _deck = [];
  final List<Flashcard> _queue = [];
  int _total = 0;
  int _mastered = 0;
  int _combo = 0;
  int _score = 0;
  bool _showFront = true;

  Offset _drag = Offset.zero;
  late AnimationController _animCtrl;
  Animation<Offset>? _flyAnim;
  Color? _flashColor;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _animCtrl.addListener(() => setState(() {}));
    _initDeck();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _initDeck() {
    List<Flashcard> pool = initialB2Dataset;
    if (_selectedCategory != 'Все карточки') {
      pool = pool.where((c) => c.category == _selectedCategory).toList();
    }
    final copy = List<Flashcard>.from(pool)..shuffle(Random());
    final count = (_cardLimit == -1 || _cardLimit > copy.length) ? copy.length : _cardLimit;
    _deck = copy.take(count).toList();

    _queue.clear();
    _queue.addAll(_deck);
    _total = _deck.length;
    _mastered = 0;
    _combo = 0;
    _showFront = true;
    _drag = Offset.zero;
    setState(() {});
  }

  void _onAnswer(bool known) {
    if (_queue.isEmpty || _animCtrl.isAnimating) return;
    final card = _queue.removeAt(0);

    setState(() {
      _showFront = true;
      _flashColor = known ? Colors.greenAccent : Colors.redAccent;
      if (known) {
        _mastered++;
        _combo++;
        final rank = rankFor(_combo);
        _score += 100 * rank.mult;
        widget.onStatsUpdated(_combo, 1);
        if (_combo == 2 || _combo == 4 || _combo == 6 || _combo == 9 || _combo == 12 || _combo == 15) {
          DmcAudio.playRankUp();
        } else {
          DmcAudio.playCorrect();
        }
        if (_combo % 5 == 0) DmcAudio.playStageClear();
      } else {
        _combo = 0;
        _queue.add(card);
        DmcAudio.playWrong();
        widget.onStatsUpdated(0, 1);
      }
    });

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _flashColor = null);
    });
  }

  void _swipeFly(bool right) {
    if (_animCtrl.isAnimating) return;
    final target = Offset(right ? 500 : -500, _drag.dy);
    _flyAnim = Tween<Offset>(begin: _drag, end: target).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
    );
    _animCtrl.forward(from: 0).then((_) {
      _drag = Offset.zero;
      _onAnswer(right);
    });
  }

  void _showCategoryPicker() {
    final categories = ['Все карточки', ...getUniqueCategories()];
    final counts = getCategoryCounts();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('ВЫБОР МОДУЛЯ / ТЕМЫ', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.white)),
                  IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (_, i) {
                  final cat = categories[i];
                  final cnt = cat == 'Все карточки' ? initialB2Dataset.length : (counts[cat] ?? 0);
                  final isSel = cat == _selectedCategory;
                  return ListTile(
                    tileColor: isSel ? Colors.redAccent.withAlpha(40) : null,
                    title: Text(cat, style: TextStyle(color: isSel ? Colors.redAccent : Colors.white, fontWeight: FontWeight.bold)),
                    trailing: Text('$cnt карт', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() => _selectedCategory = cat);
                      _initDeck();
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final rank = rankFor(_combo);
    final card = _queue.isNotEmpty ? _queue.first : null;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              // 1. MODULE & LIMIT CONTROL BAR (Screenshot 2 exact match)
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: InkWell(
                      onTap: _showCategoryPicker,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF1E293B)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('МОДУЛЬ / ТЕМА',
                                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey)),
                                  const SizedBox(height: 2),
                                  Text(
                                    _selectedCategory,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.filter_alt_outlined, size: 18, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF1E293B)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _cardLimit,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF0F172A),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          items: const [
                            DropdownMenuItem(value: 10, child: Text('10 карт')),
                            DropdownMenuItem(value: 25, child: Text('25 карт (стандарт)')),
                            DropdownMenuItem(value: 50, child: Text('50 карт')),
                            DropdownMenuItem(value: -1, child: Text('Все карты')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _cardLimit = val);
                              _initDeck();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  InkWell(
                    onTap: _initDeck,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF1E293B)),
                      ),
                      child: const Icon(Icons.shuffle_rounded, size: 18, color: Colors.white70),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 2. DMC SCORE BOARD (Screenshot 2 exact match)
              DmcScoreBar(
                score: _score,
                combo: _combo,
                mastered: _mastered,
                total: _total,
                queueLength: _queue.length,
                rank: rank,
              ),
              const SizedBox(height: 12),

              // 3. FLASHCARD DISPLAY
              Expanded(
                child: card == null
                    ? Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(color: const Color(0xFF0B132B), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.greenAccent)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.emoji_events_rounded, size: 64, color: Colors.amberAccent),
                            const SizedBox(height: 12),
                            const Text('РАУНД ЗАВЕРШЕН!', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFBE123C), foregroundColor: Colors.white),
                              onPressed: _initDeck,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('ПРОЙТИ СНОВА'),
                            ),
                          ],
                        ),
                      )
                    : GestureDetector(
                        onPanUpdate: (d) {
                          if (!_animCtrl.isAnimating) setState(() => _drag += d.delta);
                        },
                        onPanEnd: (d) {
                          if (_drag.dx > 90) {
                            _swipeFly(true);
                          } else if (_drag.dx < -90) {
                            _swipeFly(false);
                          } else {
                            setState(() => _drag = Offset.zero);
                          }
                        },
                        onTap: () {
                          DmcAudio.playSlash();
                          setState(() => _showFront = !_showFront);
                        },
                        child: Transform.translate(
                          offset: _animCtrl.isAnimating && _flyAnim != null ? _flyAnim!.value : _drag,
                          child: Transform.rotate(
                            angle: _drag.dx / 350,
                            child: CardFaceWidget(card: card, showFront: _showFront),
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 12),

              // 4. BOTTOM 3 BUTTONS (Screenshot 2 exact match)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFBE123C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                      onPressed: () {
                        DmcAudio.playSlash();
                        _swipeFly(false);
                      },
                      icon: const Icon(Icons.close_rounded, size: 20),
                      label: const Text('НЕ ЗНАЮ', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                    ),
                  ),
                  const SizedBox(width: 8),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      side: const BorderSide(color: Color(0xFF334155)),
                      elevation: 2,
                    ),
                    onPressed: () {
                      DmcAudio.playSlash();
                      setState(() => _showFront = !_showFront);
                    },
                    icon: const Icon(Icons.refresh_rounded, color: Colors.amberAccent, size: 20),
                    label: const Text('ОБОРОТ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  const SizedBox(width: 8),

                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                      onPressed: () {
                        DmcAudio.playSlash();
                        _swipeFly(true);
                      },
                      icon: const Icon(Icons.check_rounded, size: 20),
                      label: const Text('ЗНАЮ!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),

        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              color: _flashColor?.withAlpha(70) ?? Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }
}
