import 'package:flutter/material.dart';

class StudyCompleteScreen extends StatefulWidget {
  final String participantId;
  final int totalConditions;
  final Future<bool> Function() onSave;

  const StudyCompleteScreen({
    super.key,
    required this.participantId,
    required this.totalConditions,
    required this.onSave,
  });

  @override
  State<StudyCompleteScreen> createState() => _StudyCompleteScreenState();
}

class _StudyCompleteScreenState extends State<StudyCompleteScreen> {
  bool _isSaving = true;
  bool? _saveSuccessful;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveData();
    });
  }

  Future<void> _saveData() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = true;
      _saveSuccessful = null;
    });

    final success = await widget.onSave();

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
      _saveSuccessful = success;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isSaving) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 24),
                  Text(
                    'Daten werden gespeichert …',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Bitte die App noch nicht schließen.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_saveSuccessful == false) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.error_outline, size: 72),
                    const SizedBox(height: 20),
                    const Text(
                      'Speichern fehlgeschlagen',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Die Studiendaten konnten noch nicht in Firebase gespeichert werden. '
                      'Bitte prüfe die Internetverbindung und versuche es erneut.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _saveData,
                        icon: const Icon(Icons.refresh),
                        label: const Text(
                          'Erneut versuchen',
                          style: TextStyle(fontSize: 17),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.check_circle_outline, size: 80),
                  const SizedBox(height: 24),
                  const Text(
                    'Studie beendet',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Teilnehmer-ID: ${widget.participantId}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 17),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${widget.totalConditions} von ${widget.totalConditions} Aufgaben abgeschlossen.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 17),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Die Studiendaten wurden erfolgreich gespeichert.\n\n'
                    'Vielen Dank für deine Teilnahme.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
