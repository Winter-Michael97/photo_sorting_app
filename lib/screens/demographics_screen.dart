import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final TextEditingController _ageController = TextEditingController();

  bool _ageNotProvided = false;
  String? _gender;
  String? _smartphoneOs;
  String? _photoSortingFrequency;

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

  int? get _age {
    if (_ageNotProvided) {
      return null;
    }

    return int.tryParse(_ageController.text.trim());
  }

  bool get _ageIsValid {
    if (_ageNotProvided) {
      return true;
    }

    final age = _age;
    return age != null && age >= 1 && age <= 120;
  }

  bool get _isComplete =>
      _ageIsValid &&
      _gender != null &&
      _smartphoneOs != null &&
      _photoSortingFrequency != null;

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_isComplete) {
      return;
    }

    widget.onSubmit({
      'age': _ageNotProvided ? null : _age,
      'ageNotProvided': _ageNotProvided,
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

            const Text(
              'Wie alt bist du?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _ageController,
              enabled: !_ageNotProvided,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Alter in Jahren, z. B. 24',
                border: const OutlineInputBorder(),
                errorText: !_ageNotProvided &&
                        _ageController.text.isNotEmpty &&
                        !_ageIsValid
                    ? 'Bitte ein gültiges Alter zwischen 1 und 120 eingeben.'
                    : null,
              ),
            ),

            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _ageNotProvided,
              title: const Text('Keine Angabe'),
              onChanged: (value) {
                setState(() {
                  _ageNotProvided = value ?? false;

                  if (_ageNotProvided) {
                    _ageController.clear();
                  }
                });
              },
            ),

            const SizedBox(height: 18),

            _buildDropdown(
              label: 'Geschlecht',
              value: _gender,
              items: _genders,
              onChanged: (value) => setState(() => _gender = value),
            ),

            const SizedBox(height: 22),

            _buildDropdown(
              label:
                  'Welches Smartphone-Betriebssystem nutzt du hauptsächlich?',
              value: _smartphoneOs,
              items: _smartphoneSystems,
              onChanged: (value) => setState(() => _smartphoneOs = value),
            ),

            const SizedBox(height: 22),

            _buildDropdown(
              label:
                  'Wie häufig sortierst oder löschst du Fotos auf deinem Smartphone?',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          hint: const Text('Bitte auswählen'),
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
