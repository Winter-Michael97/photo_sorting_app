import 'package:flutter/material.dart';

class ConsentScreen extends StatefulWidget {
  final Future<void> Function() onAccept;

  const ConsentScreen({
    super.key,
    required this.onAccept,
  });

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _studyConsentAccepted = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  Future<void> _accept() async {
    if (!_studyConsentAccepted || _isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await widget.onAccept();
    } catch (error) {
      debugPrint('Fehler beim Start nach Einwilligung: $error');

      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
        _errorMessage =
            'Die Studie konnte nicht gestartet werden. Bitte erneut versuchen.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Einwilligung zur Studienteilnahme'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Einverständniserklärung zur Studienteilnahme',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 24),

                    const _BodyText(
                      'Sie sind eingeladen, an der Anwenderstudie '
                      '„Nutzerstudie zur Interaktion beim mobilen Foto-Aussortieren“ '
                      'teilzunehmen. Die Studie wird von Ludwig Engl, Michael Winter '
                      'und Martin Horsch durchgeführt und von Raphael Wimmer an der '
                      'Universität Regensburg betreut. Wir rechnen mit etwa 20 '
                      'Teilnehmenden. Die Datenerhebung ist bis 12.10.2026 geplant.',
                    ),

                    const SizedBox(height: 24),
                    const _SectionTitle('Wichtige Hinweise'),
                    const SizedBox(height: 8),

                    const _BulletText(
                      'Die Teilnahme ist freiwillig. Sie können die Teilnahme jederzeit '
                      'ohne Nachteile und ohne Angabe von Gründen beenden.',
                    ),
                    const _BulletText(
                      'Eine Sitzung dauert ungefähr 20-30 Minuten.',
                    ),
                    const _BulletText(
                      'Für die Teilnahme ist keine Vergütung vorgesehen.',
                    ),
                    const _BulletText(
                      'Wir erheben demografische Angaben (z. B. Altersgruppe und '
                      'Geschlecht) sowie Ihre Eingaben in der Studien-App.',
                    ),
                    const _BulletText(
                      'Erfasst werden insbesondere Ihre Fotoentscheidungen, '
                      'Bearbeitungszeiten und Antworten in den Fragebögen.',
                    ),
                    const _BulletText(
                      'Es werden keine Audio- oder Videoaufnahmen angefertigt.',
                    ),
                    const _BulletText(
                      'Die Forschungsdaten werden unter einer Teilnehmenden-ID '
                      'pseudonymisiert gespeichert und nur in zusammengefasster Form '
                      'veröffentlicht.',
                    ),

                    const SizedBox(height: 10),
                    const _BodyText(
                      'Wenn Sie Fragen zur Studie, zum Einwilligungsprozess oder zu '
                      'Ihren Rechten als teilnehmende Person haben, wenden Sie sich '
                      'bitte an Raphael Wimmer oder an das Forschungsteam.',
                    ),

                    const SizedBox(height: 28),
                    const _SectionTitle('1. Zweck und Ziel dieser Forschung'),
                    const SizedBox(height: 8),
                    const _BodyText(
                      'Ziel dieser Studie ist es zu untersuchen, wie unterschiedliche '
                      'mobile Interaktionsformen Nutzerinnen und Nutzer bei der Auswahl '
                      'und beim Aussortieren von Fotos unterstützen. Dabei werden ein '
                      'Swipe-basiertes und ein Raster-basiertes Bedienkonzept bei '
                      'verschiedenen Fotoaufgaben miteinander verglichen. Untersucht '
                      'werden unter anderem Bearbeitungszeit, Genauigkeit und die '
                      'subjektive Wahrnehmung der Bedienung.',
                    ),

                    const SizedBox(height: 28),
                    const _SectionTitle('2. Studienteilnahme'),
                    const SizedBox(height: 8),
                    const _BodyText(
                      'Ihre Teilnahme ist freiwillig. Sie können die Teilnahme jederzeit '
                      'ohne Nachteile und ohne Angabe von Gründen beenden. Eine '
                      'wiederholte Teilnahme an dieser Studie ist nicht vorgesehen. '
                      'Während der Teilnahme gelten die üblichen Haus- und '
                      'Sicherheitsregeln der Universität Regensburg.',
                    ),

                    const SizedBox(height: 28),
                    const _SectionTitle('3. Studienablauf'),
                    const SizedBox(height: 8),
                    const _NumberedText(
                      number: 1,
                      text:
                          'Zu Beginn lesen Sie diese Studieninformationen und bestätigen '
                          'Ihre freiwillige Einwilligung digital in der App.',
                    ),
                    const _NumberedText(
                      number: 2,
                      text:
                          'Sie bearbeiten vier Aufgaben zur Auswahl und zum Aussortieren '
                          'von Fotos auf einem Smartphone. Dabei verwenden Sie Swipe- und '
                          'Rasteransichten. Die Reihenfolge der Aufgaben kann zwischen '
                          'den Teilnehmenden variieren.',
                    ),
                    const _NumberedText(
                      number: 3,
                      text:
                          'Nach jeder Aufgabe beantworten Sie einige kurze '
                          'Bewertungsfragen zur Bedienung, zum Kontrollgefühl, zur '
                          'Sicherheit Ihrer Entscheidungen und zur wahrgenommenen '
                          'Anstrengung.',
                    ),
                    const _NumberedText(
                      number: 4,
                      text:
                          'Nach Abschluss aller vier Aufgaben beantworten Sie einen '
                          'kurzen Abschlussfragebogen sowie einige demografische Fragen.',
                    ),
                    const _NumberedText(
                      number: 5,
                      text:
                          'Danach ist die Studie beendet. Insgesamt dauert die Teilnahme '
                          'ungefähr 20-30 Minuten.',
                    ),

                    const SizedBox(height: 28),
                    const _SectionTitle('4. Risiken und Nutzen'),
                    const SizedBox(height: 8),
                    const _BodyText(
                      'Nach aktuellem Kenntnisstand sind mit dieser Anwenderstudie keine '
                      'Risiken verbunden, die über alltägliche Aktivitäten hinausgehen. '
                      'Einzelne Fragen oder Aufgaben können als unangenehm empfunden '
                      'werden. Sie können die Teilnahme jederzeit beenden. Sie erhalten '
                      'voraussichtlich keinen direkten persönlichen Nutzen; Ihre '
                      'Teilnahme unterstützt jedoch die Forschung zur '
                      'Mensch-Computer-Interaktion.',
                    ),

                    const SizedBox(height: 28),
                    const _SectionTitle('5. Datenschutz und Vertraulichkeit'),
                    const SizedBox(height: 8),
                    const _BodyText(
                      'Für die Auswertung werden keine Namen oder Kontaktdaten benötigt. '
                      'Die App vergibt automatisch eine Teilnehmenden-ID (z. B. P001). '
                      'Unter dieser ID werden Ihre Fotoentscheidungen, Bearbeitungszeiten, '
                      'Fragebogenantworten und demografischen Angaben gespeichert. Die '
                      'Verarbeitung erfolgt auf Grundlage Ihrer Einwilligung und gemäß '
                      'der Datenschutz-Grundverordnung (DSGVO).',
                    ),
                    const SizedBox(height: 12),
                    const _BodyText(
                      'Während der Auswertung haben nur die Forschenden und autorisierte '
                      'Projektmitarbeitende Zugriff auf die Rohdaten. Ergebnisse der '
                      'Studie können in wissenschaftlichen Veröffentlichungen, '
                      'Abschlussarbeiten oder Forschungsberichten veröffentlicht werden. '
                      'Dabei werden nur zusammengefasste oder anderweitig so aufbereitete '
                      'Daten verwendet, dass keine unmittelbaren Rückschlüsse auf '
                      'einzelne Personen möglich sind.',
                    ),
                    const SizedBox(height: 12),
                    const _BodyText(
                      'Da keine Kontaktdaten erhoben werden, können wir Sie im Anschluss '
                      'nicht aktiv kontaktieren. Solange Ihre Daten noch anhand der '
                      'Teilnehmenden-ID zugeordnet werden können, können Sie sich an das '
                      'Forschungsteam wenden. Sobald Daten nur noch in nicht mehr '
                      'personenbezogen zuordenbarer Form vorliegen oder veröffentlicht '
                      'wurden, kann ein späterer Widerruf dieser Nutzung eingeschränkt '
                      'oder nicht mehr möglich sein.',
                    ),

                    const SizedBox(height: 28),
                    const _SectionTitle('6. Nennung der Untersuchenden'),
                    const SizedBox(height: 10),

                    const Text(
                      'Versuchsdurchführung',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const _BodyText(
                      'Ludwig Engl (Ludwig.Engl@stud.uni-regensburg.de)\n'
                      'Michael Winter (Michael1.Winter@stud.uni-regensburg.de)\n'
                      'Martin Horsch (Martin.Horsch@stud.uni-regensburg.de)\n'
                      'Universität Regensburg',
                    ),

                    const SizedBox(height: 18),
                    const Text(
                      'Versuchsleitung',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const _BodyText(
                      'Raphael Wimmer\n'
                      'raphael.wimmer@ur.de\n'
                      'Universität Regensburg\n'
                      'Universitätsstr. 31\n'
                      '93053 Regensburg, Germany',
                    ),

                    const SizedBox(height: 28),
                    const _SectionTitle(
                      '7. Einverständniserklärung und Einwilligung',
                    ),
                    const SizedBox(height: 8),
                    const _BodyText(
                      'Ich habe die Informationen zu dieser Anwenderstudie gelesen und '
                      'verstanden. Ich weiß, dass meine Teilnahme freiwillig ist und '
                      'dass ich die Teilnahme jederzeit ohne Nachteile beenden kann. '
                      'Ich willige in die Erhebung und Verarbeitung der oben '
                      'beschriebenen Studiendaten ein.',
                    ),

                    const SizedBox(height: 24),

                    Card(
                      color: colorScheme.surfaceContainerHighest,
                      child: CheckboxListTile(
                        value: _studyConsentAccepted,
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        title: const Text(
                          'Ich habe die Informationen zur Studie gelesen und verstanden. '
                          'Ich willige freiwillig in die Teilnahme und in die beschriebene '
                          'Verarbeitung meiner Studiendaten ein.',
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.35,
                          ),
                        ),
                        onChanged: _isSubmitting
                            ? null
                            : (value) {
                                setState(() {
                                  _studyConsentAccepted = value ?? false;
                                });
                              },
                      ),
                    ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colorScheme.error,
                          fontSize: 15,
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Material(
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 54,
              child: FilledButton(
                onPressed:
                    _studyConsentAccepted && !_isSubmitting ? _accept : null,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Einwilligen und Studie starten',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        height: 1.25,
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  final String text;

  const _BodyText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        height: 1.5,
      ),
    );
  }
}

class _BulletText extends StatelessWidget {
  final String text;

  const _BulletText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Text(
              '•',
              style: TextStyle(
                fontSize: 18,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 17,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberedText extends StatelessWidget {
  final int number;
  final String text;

  const _NumberedText({
    required this.number,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$number.',
              style: const TextStyle(
                fontSize: 17,
                height: 1.45,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 17,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
