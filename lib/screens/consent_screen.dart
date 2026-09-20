import 'package:flutter/material.dart';

class ConsentScreen extends StatefulWidget {
  final Future<void> Function({
    required bool audioConsentAccepted,
  }) onAccept;

  final VoidCallback onBack;

  const ConsentScreen({
    super.key,
    required this.onAccept,
    required this.onBack,
  });

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _studyConsentAccepted = false;
  bool _audioConsentAccepted = false;
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
      await widget.onAccept(
        audioConsentAccepted: _audioConsentAccepted,
      );
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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: _isSubmitting ? null : widget.onBack,
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Zurück',
        ),
        title: const Text('Einwilligung'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          children: [
            const Text(
              'Bitte lies die Studieninformationen vollständig durch. '
              'Die Teilnahme ist freiwillig und kann jederzeit beendet werden.',
              style: TextStyle(fontSize: 16, height: 1.4),
            ),

            const SizedBox(height: 20),

            _buildDocumentPage('assets/consent/consent_page_1.png'),

            const SizedBox(height: 16),

            _buildDocumentPage('assets/consent/consent_page_2.png'),

            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    CheckboxListTile(
                      value: _studyConsentAccepted,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Ich habe die Informationen zur Studie gelesen und '
                        'verstanden. Ich willige freiwillig in die Teilnahme '
                        'und in die beschriebene Verarbeitung meiner '
                        'Studiendaten ein.',
                      ),
                      onChanged: _isSubmitting
                          ? null
                          : (value) {
                              setState(() {
                                _studyConsentAccepted = value ?? false;
                              });
                            },
                    ),

                    const Divider(),

                    CheckboxListTile(
                      value: _audioConsentAccepted,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Ich bin zusätzlich mit der Audioaufnahme des kurzen '
                        'Abschlussinterviews einverstanden.',
                      ),
                      subtitle: const Text(
                        'Optional - die Teilnahme an der Studie ist auch ohne '
                        'Audioaufnahme möglich.',
                      ),
                      onChanged: _isSubmitting
                          ? null
                          : (value) {
                              setState(() {
                                _audioConsentAccepted = value ?? false;
                              });
                            },
                    ),
                  ],
                ),
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
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
    );
  }

  Widget _buildDocumentPage(String assetPath) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: Image.asset(
        assetPath,
        fit: BoxFit.fitWidth,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
