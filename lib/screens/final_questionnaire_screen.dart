import 'package:flutter/material.dart';

class FinalQuestionnaireScreen extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onSubmit;

  const FinalQuestionnaireScreen({
    super.key,
    required this.onSubmit,
  });

  @override
  State<FinalQuestionnaireScreen> createState() =>
      _FinalQuestionnaireScreenState();
}

class _FinalQuestionnaireScreenState extends State<FinalQuestionnaireScreen> {
  String? _overallPreference;
  String? _independentPreference;
  String? _seriesPreference;
  String? _perceivedSpeed;
  String? _perceivedControl;
  String? _perceivedEase;
  String? _ownPhotoPreference;

  final TextEditingController _commentController = TextEditingController();

  bool get _isComplete =>
      _overallPreference != null &&
      _independentPreference != null &&
      _seriesPreference != null &&
      _perceivedSpeed != null &&
      _perceivedControl != null &&
      _perceivedEase != null &&
      _ownPhotoPreference != null;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_isComplete) {
      return;
    }

    widget.onSubmit({
      'overallPreference': _overallPreference,
      'independentPreference': _independentPreference,
      'seriesPreference': _seriesPreference,
      'perceivedSpeed': _perceivedSpeed,
      'perceivedControl': _perceivedControl,
      'perceivedEase': _perceivedEase,
      'ownPhotoPreference': _ownPhotoPreference,
      'comment': _commentController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Abschließender Fragebogen'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          children: [
            const Text(
              'Zum Abschluss möchten wir die beiden Bedienformen noch einmal '
              'direkt miteinander vergleichen.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bitte wähle jeweils die Antwort aus, die deinem persönlichen '
              'Eindruck am ehesten entspricht.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),

            _buildQuestion(
              number: 1,
              question: 'Welche Bedienform hast du insgesamt bevorzugt?',
              value: _overallPreference,
              options: const [
                _AnswerOption('swipe', 'Swipe'),
                _AnswerOption('grid', 'Raster'),
                _AnswerOption('no_preference', 'Keine Präferenz'),
              ],
              onChanged: (value) =>
                  setState(() => _overallPreference = value),
            ),

            _buildQuestion(
              number: 2,
              question:
                  'Welche Bedienform würdest du für das Aussortieren einzelner Fotos bevorzugen?',
              value: _independentPreference,
              options: const [
                _AnswerOption('swipe', 'Swipe'),
                _AnswerOption('grid', 'Raster'),
                _AnswerOption('no_preference', 'Keine Präferenz'),
              ],
              onChanged: (value) =>
                  setState(() => _independentPreference = value),
            ),

            _buildQuestion(
              number: 3,
              question:
                  'Welche Bedienform würdest du für die Auswahl aus Fotoserien bevorzugen?',
              value: _seriesPreference,
              options: const [
                _AnswerOption('swipe', 'Swipe'),
                _AnswerOption('grid', 'Raster'),
                _AnswerOption('no_preference', 'Keine Präferenz'),
              ],
              onChanged: (value) =>
                  setState(() => _seriesPreference = value),
            ),

            _buildQuestion(
              number: 4,
              question: 'Welche Bedienform fühlte sich für dich schneller an?',
              value: _perceivedSpeed,
              options: const [
                _AnswerOption('swipe', 'Swipe'),
                _AnswerOption('grid', 'Raster'),
                _AnswerOption('no_difference', 'Kein Unterschied'),
              ],
              onChanged: (value) =>
                  setState(() => _perceivedSpeed = value),
            ),

            _buildQuestion(
              number: 5,
              question:
                  'Bei welcher Bedienform hattest du mehr Kontrolle über deine Entscheidungen?',
              value: _perceivedControl,
              options: const [
                _AnswerOption('swipe', 'Swipe'),
                _AnswerOption('grid', 'Raster'),
                _AnswerOption('no_difference', 'Kein Unterschied'),
              ],
              onChanged: (value) =>
                  setState(() => _perceivedControl = value),
            ),

            _buildQuestion(
              number: 6,
              question:
                  'Welche Bedienform fandest du insgesamt einfacher zu bedienen?',
              value: _perceivedEase,
              options: const [
                _AnswerOption('swipe', 'Swipe'),
                _AnswerOption('grid', 'Raster'),
                _AnswerOption('no_difference', 'Kein Unterschied'),
              ],
              onChanged: (value) =>
                  setState(() => _perceivedEase = value),
            ),

            _buildQuestion(
              number: 7,
              question:
                  'Welche Bedienform würdest du eher zur Verwaltung deiner eigenen Fotos verwenden?',
              value: _ownPhotoPreference,
              options: const [
                _AnswerOption('swipe', 'Swipe'),
                _AnswerOption('grid', 'Raster'),
                _AnswerOption('no_preference', 'Keine Präferenz'),
              ],
              onChanged: (value) =>
                  setState(() => _ownPhotoPreference = value),
            ),

            const SizedBox(height: 8),
            const Text(
              'Optionaler Kommentar',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              minLines: 3,
              maxLines: 5,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText:
                    'Möchtest du noch etwas zu den beiden Bedienformen anmerken?',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isComplete ? _submit : null,
              child: Text(
                _isComplete
                    ? 'Weiter'
                    : 'Bitte alle Fragen beantworten',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestion({
    required int number,
    required String question,
    required String? value,
    required List<_AnswerOption> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '$number. $question',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...options.map(
                (option) => RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  value: option.value,
                  groupValue: value,
                  title: Text(option.label),
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnswerOption {
  final String value;
  final String label;

  const _AnswerOption(this.value, this.label);
}
