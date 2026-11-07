import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

// ───────────────────────── FLASHCARD MODEL ─────────────────────────
class Flashcard {
  final String article, german, russian, explanation, category;
  const Flashcard(this.article, this.german, this.russian, this.explanation, this.category);

  factory Flashcard.fromJson(Map<String, dynamic> j) {
    return Flashcard(
      j['article'] as String? ?? '',
      j['german'] as String? ?? '',
      j['russian'] as String? ?? '',
      j['explanation'] as String? ?? '',
      j['category'] as String? ?? 'Allgemein',
    );
  }
}

// Fallback Dataset
const List<Flashcard> fallbackB2Dataset = [
  Flashcard('die', 'Stellenausschreibung, -en', 'Объявление о вакансии',
      'Die Stellenausschreibung passt genau zu meinem Profil.', 'Bewerbung'),
  Flashcard('das', 'Anschreiben, -', 'Сопроводительное письмо',
      'Das Anschreiben sollte prägnant und professionell sein.', 'Bewerbung'),
  Flashcard('der', 'Lebenslauf, ¨-e', 'Резюме (CV)',
      'Bitte fügen Sie Ihren aktuellen Lebenslauf bei.', 'Bewerbung'),
  Flashcard('das', 'Vorstellungsgespräch, -e', 'Собеседование',
      'Ich habe morgen ein wichtiges Vorstellungsgespräch.', 'Bewerbung'),
];

List<Flashcard> initialB2Dataset = List<Flashcard>.from(fallbackB2Dataset);

Future<void> loadCards() async {
  try {
    final raw = await rootBundle.loadString('assets/cards.json');
    final List<dynamic> list = json.decode(raw) as List<dynamic>;
    final parsed = list.map((e) => Flashcard.fromJson(e as Map<String, dynamic>)).toList();
    if (parsed.isNotEmpty) {
      initialB2Dataset = parsed;
    }
  } catch (e) {
    debugPrint('Ошибка загрузки assets/cards.json: $e');
  }
}

List<String> getUniqueCategories() {
  final set = <String>{};
  for (final c in initialB2Dataset) {
    set.add(c.category);
  }
  return set.toList();
}

Map<String, int> getCategoryCounts() {
  final counts = <String, int>{};
  for (final c in initialB2Dataset) {
    counts[c.category] = (counts[c.category] ?? 0) + 1;
  }
  return counts;
}

// ───────────────────────── DMC RANKS ─────────────────────────
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
