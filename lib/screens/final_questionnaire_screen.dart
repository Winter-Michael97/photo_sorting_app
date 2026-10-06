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
  double? _overallPreference;
  double? _independentPreference;
  double? _seriesPreference;
  double? _perceivedSpeed;
  double? _perceivedControl;
  double? _perceivedEase;
  double? _ownPhotoPreference;

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
      // Einheitliche bipolare Skala:
      // -3 = starke Tendenz zu Swipe
      //  0 = keine Präferenz / kein Unterschied
      // +3 = starke Tendenz zu Raster
      'scaleMin': -3,
      'scaleMax': 3,
      'scaleLeft': 'Swipe',
      'scaleCenter': 'Keine Präferenz / kein Unterschied',
      'scaleRight': 'Raster',

      'overallPreference': _overallPreference!.round(),
      'independentPreference': _independentPreference!.round(),
      'seriesPreference': _seriesPreference!.round(),
      'perceivedSpeed': _perceivedSpeed!.round(),
      'perceivedControl': _perceivedControl!.round(),
      'perceivedEase': _perceivedEase!.round(),
      'ownPhotoPreference': _ownPhotoPreference!.round(),

      'comment': _commentController.text.trim(),
    });
  }

  String _valueLabel(double? value, String centerLabel) {
    if (value == null) {
      return 'Noch nicht beantwortet';
    }

    switch (value.round()) {
      case -3:
        return 'Stark Swipe';
      case -2:
        return 'Swipe';
      case -1:
        return 'Eher Swipe';
      case 0:
        return centerLabel;
      case 1:
        return 'Eher Raster';
      case 2:
        return 'Raster';
      case 3:
        return 'Stark Raster';
      default:
        return '';
    }
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
              'Verschiebe den Regler für jede Frage in Richtung Swipe oder Raster. '
              'Die Mitte bedeutet keine Präferenz beziehungsweise keinen Unterschied.',
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 24),

            _buildScaleQuestion(
              number: 1,
              question: 'Welche Bedienform hast du insgesamt bevorzugt?',
              value: _overallPreference,
              centerLabel: 'Keine Präferenz',
              onChanged: (value) =>
                  setState(() => _overallPreference = value),
            ),

            _buildScaleQuestion(
              number: 2,
              question:
                  'Welche Bedienform würdest du für das Aussortieren einzelner Fotos bevorzugen?',
              value: _independentPreference,
              centerLabel: 'Keine Präferenz',
              onChanged: (value) =>
                  setState(() => _independentPreference = value),
            ),

            _buildScaleQuestion(
              number: 3,
              question:
                  'Welche Bedienform würdest du für die Auswahl aus Fotoserien bevorzugen?',
              value: _seriesPreference,
              centerLabel: 'Keine Präferenz',
              onChanged: (value) =>
                  setState(() => _seriesPreference = value),
            ),

            _buildScaleQuestion(
              number: 4,
              question: 'Welche Bedienform fühlte sich für dich schneller an?',
              value: _perceivedSpeed,
              centerLabel: 'Kein Unterschied',
              onChanged: (value) =>
                  setState(() => _perceivedSpeed = value),
            ),

            _buildScaleQuestion(
              number: 5,
              question:
                  'Bei welcher Bedienform hattest du mehr Kontrolle über deine Entscheidungen?',
              value: _perceivedControl,
              centerLabel: 'Kein Unterschied',
              onChanged: (value) =>
                  setState(() => _perceivedControl = value),
            ),

            _buildScaleQuestion(
              number: 6,
              question:
                  'Welche Bedienform fandest du insgesamt einfacher zu bedienen?',
              value: _perceivedEase,
              centerLabel: 'Kein Unterschied',
              onChanged: (value) =>
                  setState(() => _perceivedEase = value),
            ),

            _buildScaleQuestion(
              number: 7,
              question:
                  'Welche Bedienform würdest du eher zur Verwaltung deiner eigenen Fotos verwenden?',
              value: _ownPhotoPreference,
              centerLabel: 'Keine Präferenz',
              onChanged: (value) =>
                  setState(() => _ownPhotoPreference = value),
            ),

            const SizedBox(height: 8),
            const Text(
              'Optionaler Kommentar',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
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

  Widget _buildScaleQuestion({
    required int number,
    required String question,
    required double? value,
    required String centerLabel,
    required ValueChanged<double> onChanged,
  }) {
    final sliderValue = value ?? 0.0;
    final answerLabel = _valueLabel(value, centerLabel);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '$number. $question',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: const [
                  Expanded(
                    child: Text(
                      'Swipe',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    'gleich',
                    style: TextStyle(fontSize: 13),
                  ),
                  Expanded(
                    child: Text(
                      'Raster',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              Slider(
                value: sliderValue,
                min: -3,
                max: 3,
                divisions: 6,
                label: value == null ? null : answerLabel,
                onChanged: onChanged,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('-3', style: TextStyle(fontSize: 12)),
                  Text('0', style: TextStyle(fontSize: 12)),
                  Text('+3', style: TextStyle(fontSize: 12)),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                answerLabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: value == null
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
