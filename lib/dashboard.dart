import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data.dart';
import 'sound.dart';
import 'cards_tab.dart';
import 'lesen_screen.dart';
import 'hoeren_screen.dart';
import 'schreiben_screen.dart';

class MainDashboardScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const MainDashboardScreen({super.key, required this.isDarkMode, required this.onToggleTheme});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> with SingleTickerProviderStateMixin {
  int _maxCombo = 0;
  int _totalStudied = 0;
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _loadStats();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _maxCombo = p.getInt('max_combo_record') ?? 0;
      _totalStudied = p.getInt('total_cards_studied') ?? 0;
    });
  }

  Future<void> _handleStatsUpdated(int combo, int delta) async {
    final nextTotal = _totalStudied + delta;
    int nextCombo = _maxCombo;
    if (combo > _maxCombo) {
      nextCombo = combo;
    }
    setState(() {
      _totalStudied = nextTotal;
      _maxCombo = nextCombo;
    });
    final p = await SharedPreferences.getInstance();
    await p.setInt('total_cards_studied', nextTotal);
    if (combo > (p.getInt('max_combo_record') ?? 0)) {
      await p.setInt('max_combo_record', combo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: dark ? const Color(0xFF0F172A) : Colors.white,
        foregroundColor: dark ? Colors.white : const Color(0xFF0F172A),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.deepOrange, Colors.amber]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.local_fire_department_rounded, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'B2 BERUF DMC',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    fontSize: 16,
                    color: dark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Экзаменационный тренажер B2',
                  style: TextStyle(
                    fontSize: 10,
                    color: dark ? Colors.grey : const Color(0xFF64748B),
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              DmcAudio.soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: dark ? Colors.white : const Color(0xFF0F172A),
            ),
            onPressed: () => setState(() => DmcAudio.toggleSound()),
            tooltip: 'Звуковые эффекты',
          ),
          IconButton(
            icon: Icon(
              dark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
              color: dark ? Colors.amberAccent : const Color(0xFF475569),
            ),
            onPressed: widget.onToggleTheme,
            tooltip: 'Сменить тему',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(74),
          child: Column(
            children: [
              TabBar(
                controller: _tabCtrl,
                isScrollable: true,
                indicatorColor: dark ? Colors.redAccent : const Color(0xFFDC2626),
                indicatorWeight: 3,
                labelColor: dark ? Colors.white : const Color(0xFFDC2626),
                unselectedLabelColor: dark ? Colors.grey.shade400 : const Color(0xFF64748B),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(icon: Icon(Icons.style_rounded, size: 18), text: 'Карты'),
                  Tab(icon: Icon(Icons.menu_book_rounded, size: 18), text: 'Lesen'),
                  Tab(icon: Icon(Icons.headphones_rounded, size: 18), text: 'Hören'),
                  Tab(icon: Icon(Icons.edit_note_rounded, size: 18), text: 'Schreiben'),
                ],
              ),
              // Streak record banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                color: dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          size: 14,
                          color: dark ? Colors.amberAccent : const Color(0xFFD97706),
                        ),
                        Text(
                          ' STREAK РЕКОРД: ',
                          style: TextStyle(
                            color: dark ? Colors.amberAccent : const Color(0xFFB45309),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          '$_maxCombo',
                          style: TextStyle(
                            color: dark ? Colors.white : const Color(0xFF0F172A),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${initialB2Dataset.length} карточки B2 Beruf · 59 тем',
                      style: TextStyle(
                        color: dark ? Colors.grey : const Color(0xFF475569),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        physics: const NeverScrollableScrollPhysics(), // Disables swipe conflict between tabs
        children: [
          // 1. CARDS TAB
          CardsTab(
            maxCombo: _maxCombo,
            onStatsUpdated: _handleStatsUpdated,
            isDarkMode: dark,
          ),
          // 2. LESEN TAB
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.menu_book_rounded, size: 72, color: Colors.purpleAccent),
                  const SizedBox(height: 16),
                  Text(
                    'LESEN: Sprachbausteine',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: dark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Заполнение пропусков по официальному формату DTB B2 с DMC-комбо и стилями.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: dark ? Colors.grey : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    ),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LesenScreen(onStatsUpdated: _loadStats))),
                    icon: const Icon(Icons.play_arrow_rounded, size: 26),
                    label: const Text('ОТКРЫТЬ LESEN', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
          // 3. HÖREN TAB
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.headphones_rounded, size: 72, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text(
                    'HÖREN: DTB B2 Аудирование',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: dark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Немецкая речь (TTS de-DE), диалоги, доклады, сообщения автоответчика и Telefonnotiz.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: dark ? Colors.grey : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade900,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    ),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HoerenScreen(onStatsUpdated: _loadStats))),
                    icon: const Icon(Icons.hearing_rounded, size: 26),
                    label: const Text('ОТКРЫТЬ HÖREN', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
          // 4. SCHREIBEN TAB
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.edit_note_rounded, size: 72, color: Colors.amberAccent),
                  const SizedBox(height: 16),
                  Text(
                    'SCHREIBEN: B2 Письмо',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: dark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Деловые письма, жалобы, служебные записки с базой 218 Nomen-Verb-Verbindungen.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: dark ? Colors.grey : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade800,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    ),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SchreibenScreen())),
                    icon: const Icon(Icons.create_rounded, size: 24),
                    label: const Text('ОТКРЫТЬ SCHREIBEN', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
