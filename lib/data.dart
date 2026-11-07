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

// Запасные карточки на случай ошибки чтения файла
const List<Flashcard> fallbackB2Dataset = [
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

// ───────────────────────── SCHREIBEN PROMPTS ─────────────────────────

class SchreibenTask {
  final String title, subtitle, situation;
  final List<String> points, suggestedNVV;
  final int minWords, minutes;
  const SchreibenTask({
    required this.title,
    required this.subtitle,
    required this.situation,
    required this.points,
    required this.suggestedNVV,
    required this.minWords,
    required this.minutes,
  });
}

const List<SchreibenTask> b2SchreibenTasks = [
  SchreibenTask(
    title: 'Reklamation: Mangelhafte Warenlieferung',
    subtitle: 'Деловое письмо-жалоба поставщику',
    situation:
        'Sie arbeiten im Einkauf der Firma «Bavaria Office GmbH». Vor drei Tagen erhielten Sie eine Lieferung von 20 Bürostühlen von der Firma «Ergoflex GmbH» (Bestellnr. EF-8842). 8 Stühle weisen erhebliche Mängel auf, und die Lieferung kam mit 10 Tagen Verspätung an.',
    points: [
      'Grund des Schreibens und Bezugnahme auf die Bestellung',
      'Genaue Beschreibung der Mängel (z. B. defekte Rollen)',
      'Forderung nach kostenloser Ersatzlieferung bis zu einer Frist',
      'Eventuelle Konsequenzen bei Nichteinhaltung der Frist',
    ],
    suggestedNVV: [
      'Bezug nehmen auf',
      'eine Forderung stellen',
      'Fristen einhalten',
      'in Rechnung stellen',
      'zur Verfügung stellen',
    ],
    minWords: 150,
    minutes: 25,
  ),
  SchreibenTask(
    title: 'Forumsbeitrag: Desk-Sharing und Homeoffice',
    subtitle: 'Высказывание на внутрикорпоративном форуме',
    situation:
        'Die Geschäftsführung plant, feste Arbeitsplätze abzuschaffen und durch Desk-Sharing in Kombination mit 3 Tagen Homeoffice zu ersetzen. In der Belegschaft gibt es geteilte Meinungen.',
    points: [
      'Persönliche Meinung zum Modell begründen',
      'Vor- und Nachteile für das Team abwägen',
      'Eigene Erfahrungen mit mobilem Arbeiten schildern',
      'Einen konkreten Kompromissvorschlag formulieren',
    ],
    suggestedNVV: [
      'der Meinung sein',
      'einen Vorschlag unterbreiten',
      'Rücksicht nehmen auf',
      'eine Rolle spielen',
      'im Vordergrund stehen',
    ],
    minWords: 120,
    minutes: 20,
  ),
  SchreibenTask(
    title: 'Telefonnotiz: Dringender Kundenanruf',
    subtitle: 'Служебная записка для руководителя',
    situation:
        'Während der Abwesenheit von Herrn Dr. Weber rief um 10:15 Uhr Frau Keller von «NordLogistik» an. Sie war verärgert über eine fehlerhafte Zollrechnung zum Projekt «TransEuro 24».',
    points: [
      'Name der Anruferin, Firma, Datum und Uhrzeit',
      'Kern des Anliegens und Auftragsnummer',
      'Frist für den Rückruf (heute bis 14:00 Uhr)',
      'Vorbereitete Unterlagen / nächste Schritte',
    ],
    suggestedNVV: [
      'Bescheid geben',
      'Kontakt aufnehmen mit',
      'in Kenntnis setzen von',
      'einen Fehler beheben',
    ],
    minWords: 70,
    minutes: 12,
  ),
  SchreibenTask(
    title: 'Schreiben an den Betriebsrat: Überstunden',
    subtitle: 'Обращение в производственный совет компании',
    situation:
        'In Ihrer Abteilung kommt es seit drei Monaten wegen Personalmangels zu massiven Überstunden (über 50 Std./Woche). Gesetzliche Ruhezeiten werden oft nicht eingehalten.',
    points: [
      'Schilderung der aktuellen Belastung mit Beispielen',
      'Gefährdung der Gesundheit der Mitarbeitenden',
      'Bitte um Vermittlung bei der Geschäftsführung',
      'Vorschlag für Sofortmaßnahmen (z. B. Zeitarbeit)',
    ],
    suggestedNVV: [
      'unter Druck stehen',
      'Verantwortung übernehmen für',
      'zu einer Einigung kommen',
      'Maßnahmen ergreifen für',
    ],
    minWords: 140,
    minutes: 25,
  ),
];
