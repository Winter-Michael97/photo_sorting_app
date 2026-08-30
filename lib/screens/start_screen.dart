import 'package:flutter/material.dart';

class StartScreen extends StatefulWidget {
  final void Function(String participantId) onStartStudy;

  const StartScreen({super.key, required this.onStartStudy});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final TextEditingController _participantIdController =
      TextEditingController();

  String? _errorMessage;

  void _startStudy() {
    final participantId = _participantIdController.text.trim();

    if (participantId.isEmpty) {
      setState(() {
        _errorMessage = 'Bitte eine Teilnehmer-ID eingeben.';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    widget.onStartStudy(participantId);
  }

  @override
  void dispose() {
    _participantIdController.dispose();
    super.dispose();
  }

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
                  const Icon(Icons.photo_library_outlined, size: 64),

                  const SizedBox(height: 24),

                  const Text(
                    'Foto-Aussortierstudie',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 48),

                  const Text(
                    'Teilnehmer-ID',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: _participantIdController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'z. B. P001',
                      border: const OutlineInputBorder(),
                      errorText: _errorMessage,
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _startStudy(),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _startStudy,
                      child: const Text(
                        'Studie starten',
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
