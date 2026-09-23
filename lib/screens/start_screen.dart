import 'package:flutter/material.dart';

class StartScreen extends StatefulWidget {
  final Future<void> Function({
    required String deviceId,
    required String testerId,
  }) onContinueToConsent;

  const StartScreen({
    super.key,
    required this.onContinueToConsent,
  });

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  String _selectedDeviceId = 'phone_1';
  String _selectedTesterId = 'michael';

  bool _isContinuing = false;
  String? _errorMessage;

  Future<void> _continue() async {
    if (_isContinuing) {
      return;
    }

    setState(() {
      _isContinuing = true;
      _errorMessage = null;
    });

    try {
      await widget.onContinueToConsent(
        deviceId: _selectedDeviceId,
        testerId: _selectedTesterId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isContinuing = false;
      });
    } catch (error) {
      debugPrint('Fehler beim Öffnen der Einwilligung: $error');

      if (!mounted) {
        return;
      }

      setState(() {
        _isContinuing = false;
        _errorMessage =
            'Die Einwilligung konnte nicht geöffnet werden. Bitte erneut versuchen.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.photo_library_outlined, size: 64),

                  const SizedBox(height: 24),

                  const Text(
                    'Foto-Aussortierstudie',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Versuchsleiter-Setup',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 36),

                  const Text(
                    'Gerät',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedDeviceId,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'phone_1',
                        child: Text('phone_1'),
                      ),
                      DropdownMenuItem(
                        value: 'phone_2',
                        child: Text('phone_2'),
                      ),
                    ],
                    onChanged: _isContinuing
                        ? null
                        : (value) {
                            if (value == null) {
                              return;
                            }

                            setState(() {
                              _selectedDeviceId = value;
                            });
                          },
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Versuchsleiter',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedTesterId,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'michael',
                        child: Text('Michael'),
                      ),
                      DropdownMenuItem(
                        value: 'ludwig',
                        child: Text('Ludwig'),
                      ),
                    ],
                    onChanged: _isContinuing
                        ? null
                        : (value) {
                            if (value == null) {
                              return;
                            }

                            setState(() {
                              _selectedTesterId = value;
                            });
                          },
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isContinuing ? null : _continue,
                      child: _isContinuing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Weiter zur Einwilligung',
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
