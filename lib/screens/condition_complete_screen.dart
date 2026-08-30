import 'package:flutter/material.dart';

class ConditionCompleteScreen extends StatelessWidget {
  final int completedCondition;
  final int totalConditions;
  final VoidCallback onContinue;

  const ConditionCompleteScreen({
    super.key,
    required this.completedCondition,
    required this.totalConditions,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 400,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 80,
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Aufgabe beendet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    '$completedCondition von $totalConditions Aufgaben abgeschlossen.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Deine Antworten wurden gespeichert.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: onContinue,
                      child: const Text(
                        'Weiter',
                        style: TextStyle(
                          fontSize: 17,
                        ),
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