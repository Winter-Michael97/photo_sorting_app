import 'package:flutter/material.dart';

/// Beschreibt ein einzelnes Fragebogen-Item.
///
/// Die ID wird später zum Speichern der Antwort verwendet.
/// Der Text ist das, was der Versuchsperson angezeigt wird.
class RatingQuestion {
  final String id;
  final String text;

  const RatingQuestion({required this.id, required this.text});
}

class SubjectiveRatingScreen extends StatefulWidget {
  /// Die Fragen, die für diese Condition angezeigt werden sollen.
  final List<RatingQuestion> questions;

  /// Wird ausgelöst, sobald alle Fragen beantwortet
  /// und mit "Weiter" bestätigt wurden.
  ///
  /// Beispiel:
  /// {
  ///   'ease': 6,
  ///   'control': 5,
  ///   'confidence': 6,
  /// }
  final ValueChanged<Map<String, int>> onSubmit;

  const SubjectiveRatingScreen({
    super.key,
    required this.questions,
    required this.onSubmit,
  });

  @override
  State<SubjectiveRatingScreen> createState() => _SubjectiveRatingScreenState();
}

class _SubjectiveRatingScreenState extends State<SubjectiveRatingScreen> {
  /// Speichert die aktuell ausgewählten Antworten.
  ///
  /// Beispiel:
  /// {
  ///   'ease': 6,
  ///   'control': 5,
  /// }
  final Map<String, int> _answers = {};

  void _selectAnswer(String questionId, int value) {
    setState(() {
      _answers[questionId] = value;
    });
  }

  /// Prüft, ob wirklich jede Frage beantwortet wurde.
  bool get _allAnswered {
    if (widget.questions.isEmpty) {
      return false;
    }

    return widget.questions.every(
      (question) => _answers.containsKey(question.id),
    );
  }

  void _submit() {
    if (!_allAnswered) {
      return;
    }

    /// Wir geben eine unveränderbare Kopie zurück,
    /// damit der Screen seine Daten anschließend
    /// nicht versehentlich verändern kann.
    widget.onSubmit(Map<String, int>.unmodifiable(_answers));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Kurze Bewertung'),
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            const Text(
              'Bitte bewerte die gerade abgeschlossene Aufgabe.',
              style: TextStyle(fontSize: 17),
            ),

            const SizedBox(height: 8),

            const Text(
              '1 = stimme gar nicht zu\n'
              '7 = stimme voll zu',
              style: TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 24),

            /// Für jede Frage wird automatisch
            /// ein eigenes Rating-Element erzeugt.
            ...widget.questions.map((question) => _buildQuestionCard(question)),
          ],
        ),
      ),

      /// Der Weiter-Button bleibt immer unten sichtbar.
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              /// null bedeutet in Flutter:
              /// Button ist deaktiviert.
              onPressed: _allAnswered ? _submit : null,
              child: Text(
                _allAnswered ? 'Weiter' : 'Bitte alle Fragen beantworten',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(RatingQuestion question) {
    final selectedValue = _answers[question.id];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              question.text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 16),

            /// Die sieben Likert-Stufen.
            Row(
              children: List.generate(7, (index) {
                final value = index + 1;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: _buildScaleButton(
                      questionId: question.id,
                      value: value,
                      isSelected: selectedValue == value,
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 8),

            const Row(
              children: [
                Expanded(
                  child: Text(
                    'stimme gar\nnicht zu',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
                Expanded(
                  child: Text(
                    'stimme voll\nzu',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScaleButton({
    required String questionId,
    required int value,
    required bool isSelected,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return OutlinedButton(
      onPressed: () {
        _selectAnswer(questionId, value);
      },
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 44),
        visualDensity: VisualDensity.compact,

        backgroundColor: isSelected ? colorScheme.primaryContainer : null,

        foregroundColor: isSelected
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurface,
      ),
      child: Text(
        '$value',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
