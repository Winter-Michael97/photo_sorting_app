import 'package:flutter/material.dart';

class StartScreen extends StatefulWidget {
  final Future<void> Function({
    required String deviceId,
    required String testerId,
  }) onStartStudy;

  const StartScreen({
    super.key,
    required this.onStartStudy,
  });

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  String _selectedDeviceId = 'phone_1';
  String _selectedTesterId = 'michael';

  bool _isStarting = false;
  String? _errorMessage;

  Future<void> _startStudy() async {
    if (_isStarting) {
      return;
    }

    setState(() {
      _isStarting = true;
      _errorMessage = null;
    });

    try {
      await widget.onStartStudy(
        deviceId: _selectedDeviceId,
        testerId: _selectedTesterId,
      );
    } catch (error) {
      debugPrint('Fehler beim Studienstart: $error');

      if (!mounted) {
        return;
      }

      setState(() {
        _isStarting = false;
        _errorMessage =
            'Studie konnte nicht gestartet werden. Bitte erneut versuchen.';
      });
    }
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
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 40),

                  const Text(
                    'Gerät',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    value: _selectedDeviceId,
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
                    onChanged: _isStarting
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
                    value: _selectedTesterId,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'michael',
                        child: Text('Michael'),
                      ),
                      DropdownMenuItem(
                        value: 'kollege',
                        child: Text('Kollege'),
                      ),
                    ],
                    onChanged: _isStarting
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
                      onPressed: _isStarting ? null : _startStudy,
                      child: _isStarting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
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
