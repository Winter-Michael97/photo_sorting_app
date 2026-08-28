import 'package:flutter/material.dart';

class StudyCompleteScreen extends StatelessWidget {
  final String participantId;
  final int totalConditions;
  final VoidCallback onExport;

  const StudyCompleteScreen({
    super.key,
    required this.participantId,
    required this.totalConditions,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.emoji_events_outlined, size: 80),

                  const SizedBox(height: 24),

                  const Text(
                    'Studie beendet',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Participant ID: $participantId',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 17),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    '$totalConditions von $totalConditions Aufgaben abgeschlossen.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 17),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Vielen Dank für deine Teilnahme.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: onExport,
                      icon: const Icon(Icons.download_outlined),
                      label: const Text(
                        'Daten exportieren',
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
}
