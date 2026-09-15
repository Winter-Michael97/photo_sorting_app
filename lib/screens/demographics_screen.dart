import 'package:flutter/material.dart';

class DemographicsScreen extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onSubmit;

  const DemographicsScreen({
    super.key,
    required this.onSubmit,
  });

  @override
  State<DemographicsScreen> createState() => _DemographicsScreenState();
}

class _DemographicsScreenState extends State<DemographicsScreen> {
  String? _ageGroup;
  String? _gender;
  String? _smartphoneOs;
  String? _photoSortingFrequency;

  static const List<String> _ageGroups = [
    'Unter 18',
    '18–24',
    '25–34',
    '35–44',
    '45–54',
    '55–64',
    '65 oder älter',
    'Keine Angabe',
  ];

  static const List<String> _genders = [
    'Weiblich',
    'Männlich',
    'Divers',
    'Keine Angabe',
  ];

  static const List<String> _smartphoneSystems = [
    'Android',
    'iOS',
    'Anderes',
    'Keine Angabe',
  ];

  static const List<String> _sortingFrequencies = [
    'Täglich',
    'Mehrmals pro Woche',
    'Mehrmals pro Monat',
    'Seltener',
    'Nie',
    'Keine Angabe',
  ];

  bool get _isComplete =>
      _ageGroup != null &&
      _gender != null &&
      _smartphoneOs != null &&
      _photoSortingFrequency != null;

  void _submit() {
    if (!_isComplete) {
      return;
    }

    widget.onSubmit({
      'ageGroup': _ageGroup,
      'gender': _gender,
      'smartphoneOs': _smartphoneOs,
      'photoSortingFrequency': _photoSortingFrequency,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Abschließende Angaben'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            const Text(
              'Zum Abschluss bitten wir dich noch um einige kurze Angaben. '
              'Sie werden zusammen mit deiner Teilnehmer-ID gespeichert.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bei persönlichen Angaben kannst du jeweils „Keine Angabe“ auswählen.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            _buildDropdown(
              label: 'Altersgruppe',
              value: _ageGroup,
              items: _ageGroups,
              onChanged: (value) => setState(() => _ageGroup = value),
            ),
            const SizedBox(height: 18),
            _buildDropdown(
              label: 'Geschlecht',
              value: _gender,
              items: _genders,
              onChanged: (value) => setState(() => _gender = value),
            ),
            const SizedBox(height: 18),
            _buildDropdown(
              label: 'Welches Smartphone-Betriebssystem nutzt du hauptsächlich?',
              value: _smartphoneOs,
              items: _smartphoneSystems,
              onChanged: (value) => setState(() => _smartphoneOs = value),
            ),
            const SizedBox(height: 18),
            _buildDropdown(
              label: 'Wie häufig sortierst oder löschst du Fotos auf deinem Smartphone?',
              value: _photoSortingFrequency,
              items: _sortingFrequencies,
              onChanged: (value) =>
                  setState(() => _photoSortingFrequency = value),
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
                    ? 'Weiter zum Abschluss'
                    : 'Bitte alle Felder ausfüllen',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      isExpanded: true,
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
