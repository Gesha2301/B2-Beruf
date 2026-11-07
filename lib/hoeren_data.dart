class HoerenTask {
  final String id;
  final int teil;
  final String title;
  final String situation;
  final String transcript;
  final String question;
  final bool isMultipleChoice;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String? caller;
  final String? company;
  final String? phone;
  final String? reason;
  final String? action;

  const HoerenTask({
    required this.id,
    required this.teil,
    required this.title,
    required this.situation,
    required this.transcript,
    required this.question,
    required this.isMultipleChoice,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    this.caller,
    this.company,
    this.phone,
    this.reason,
    this.action,
  });
}

final List<HoerenTask> b2HoerenTasks = [
  const HoerenTask(
    id: 'h1',
    teil: 1,
    title: 'Teil 1: Dienstplanänderung im Team',
    situation: 'Sie hören ein Gespräch über den Dienstplan für das Wochenende.',
    transcript: 'Guten Morgen Herr Zarif! Kollege Becker ist krank. Können Sie am Samstag in der Frühschicht von 6 bis 14 Uhr einspringen? Dafür bekommen Sie Montag und Dienstag frei. - Guten Morgen Frau Lehmann. Am Samstagvormittag habe ich einen Termin in der Autowerkstatt. Ich könnte ab 14 Uhr die Spätschicht übernehmen. - Perfekt, Frau Bauer übernimmt früh und Sie spät.',
    question: 'Herr Zarif kann früh nicht arbeiten wegen eines Werkstatttermins.',
    isMultipleChoice: false,
    options: ['Richtig', 'Falsch'],
    correctAnswer: 'Richtig',
    explanation: 'Herr Zarif hat am Vormittag einen vereinbarten Werkstatttermin.',
  ),
  const HoerenTask(
    id: 'h2',
    teil: 1,
    title: 'Teil 1: Glastüren im Konferenzraum',
    situation: 'Gespräch zwischen Frau Li und dem Techniker Herrn Vogel.',
    transcript: 'Herr Vogel, die neuen Glasschiebetüren im Konferenzraum schließen nicht richtig. - Die Laufschiene hat sich verschoben, das repariere ich gleich. Ich empfehle zudem mattierte Sichtschutzstreifen auf Augenhöhe laut Arbeitsschutzverordnung.',
    question: 'Was empfiehlt Herr Vogel aus Arbeitsschutzgründen?',
    isMultipleChoice: true,
    options: [
      'A) Mattierte Sichtschutzstreifen auf den Glastüren.',
      'B) Kompletter Austausch gegen Holztüren.',
      'C) Den Raum zwei Wochen sperren.',
    ],
    correctAnswer: 'A) Mattierte Sichtschutzstreifen auf den Glastüren.',
    explanation: 'Sichtschutzstreifen auf Augenhöhe verhindern Unfälle.',
  ),
  const HoerenTask(
    id: 'h3',
    teil: 2,
    title: 'Teil 2: Diensthandy nach Feierabend',
    situation: 'Meinung einer Vertriebsleiterin zur ständigen Erreichbarkeit.',
    transcript: 'Im Vertrieb erwarten Kunden schnelle Antworten. Trotzdem schalte ich mein Diensthandy ab 18:30 Uhr und am Wochenende konsequent stumm. Ständige Alarmbereitschaft führt unweigerlich zu Erschöpfung und Burnout.',
    question: 'Welche Haltung vertritt die Sprecherin?',
    isMultipleChoice: true,
    options: [
      'A) Man muss 24 Stunden erreichbar sein.',
      'B) Feste Abschaltzeiten schützen vor Überlastung.',
      'C) Diensthandys sollten verboten werden.',
    ],
    correctAnswer: 'B) Feste Abschaltzeiten schützen vor Überlastung.',
    explanation: 'Feste Ruhezeiten sind essenziell gegen Burnout.',
  ),
  const HoerenTask(
    id: 'h4',
    teil: 3,
    title: 'Teil 3: Betriebliche Ersthelfer',
    situation: 'Informationsvortrag des Sicherheitsbeauftragten Murat Yilmaz.',
    transcript: 'Mindestens zehn Prozent der Mitarbeiter müssen als Ersthelfer geschult sein. Wir bieten im November zwei Termine für die zweitägige Schulung an. Das Unternehmen übernimmt sämtliche Kosten, und die Zeit gilt als Arbeitszeit. Das Zertifikat gilt zwei Jahre.',
    question: 'Wer bezahlt die Kosten der Ersthelferschulung?',
    isMultipleChoice: true,
    options: [
      'A) Die Mitarbeiter zahlen 50 Prozent.',
      'B) Das Unternehmen übernimmt die vollen Kosten.',
      'C) Die Krankenkasse.',
    ],
    correctAnswer: 'B) Das Unternehmen übernimmt die vollen Kosten.',
    explanation: 'Der Betrieb übernimmt alle Kosten vollumfänglich.',
  ),
  const HoerenTask(
    id: 'h5',
    teil: 4,
    title: 'Teil 4: Mailbox von Frau Plassberg',
    situation: 'Nachricht von Metallbau Weber auf Ihrer Mailbox.',
    transcript: 'Guten Tag, Andrea Plassberg von Metallbau Weber. Wegen Materialengpass verzögert sich die Lieferung der Profile um vier Werktage auf Dienstag. Bitte rufen Sie mich bis 16 Uhr unter 089 5432-118 zurück.',
    question: 'Warum ruft Frau Plassberg an?',
    isMultipleChoice: true,
    options: [
      'A) Die Ware verspätet sich um vier Werktage.',
      'B) Der Auftrag wurde storniert.',
      'C) Die Rechnung fehlt.',
    ],
    correctAnswer: 'A) Die Ware verspätet sich um vier Werktage.',
    explanation: 'Lieferverzögerung um 4 Werktage wegen Materialmangel.',
  ),
  const HoerenTask(
    id: 'h6',
    teil: 5,
    title: 'Teil 5: Telefonnotiz Autovermietung',
    situation: 'Voicemail auf dem Firmenanrufbeantworter für Frau Sommer.',
    transcript: 'Guten Tag, Thomas Schmid von Autovermietung Schmid in Nürnberg, Tel 0911 8842-300 für Frau Sommer. Der reservierte Transporter hat einen Getriebeschaden. Wir bieten einen 7,5t ohne Aufpreis. Bitte dringend bis 17 Uhr zurückrufen.',
    question: 'Füllen Sie die Telefonnotiz anhand der Voicemail aus.',
    isMultipleChoice: false,
    options: ['Notiz vollständig ausfüllen'],
    correctAnswer: 'Notiz vollständig ausfüllen',
    explanation: 'Anrufer: Thomas Schmid, Firma: Schmid Nürnberg, Tel: 0911 8842-300, Grund: Getriebeschaden Transporter.',
    caller: 'Thomas Schmid',
    company: 'Autovermietung Schmid & Partner (Nürnberg)',
    phone: '0911 8842-300',
    reason: 'Getriebeschaden am reservierten Transporter. Alternative 7,5t ohne Aufpreis.',
    action: 'Dringender Rückruf vor 17:00 Uhr!',
  ),
];
