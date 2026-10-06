import 'package:flutter/material.dart';

class DeviceSelectionScreen extends StatefulWidget {
  final void Function({
    required String deviceId,
    required String deviceModel,
  }) onContinue;

  const DeviceSelectionScreen({
    super.key,
    required this.onContinue,
  });

  @override
  State<DeviceSelectionScreen> createState() => _DeviceSelectionScreenState();
}

class _DeviceSelectionScreenState extends State<DeviceSelectionScreen> {
  String? _selectedDeviceId;

  static const _devices = [
    _StudyDevice(
      id: 'samsung_galaxy_a36',
      model: 'Samsung Galaxy A36',
    ),
    _StudyDevice(
      id: 'google_pixel_10_pro',
      model: 'Google Pixel 10 Pro',
    ),
  ];

  _StudyDevice? get _selectedDevice {
    final selectedId = _selectedDeviceId;

    if (selectedId == null) {
      return null;
    }

    for (final device in _devices) {
      if (device.id == selectedId) {
        return device;
      }
    }

    return null;
  }

  void _continue() {
    final device = _selectedDevice;

    if (device == null) {
      return;
    }

    widget.onContinue(
      deviceId: device.id,
      deviceModel: device.model,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Versuchsleiter-Setup'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.smartphone,
                    size: 64,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Studiengerät auswählen',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Bitte vor jeder Versuchsperson das Smartphone auswählen, '
                    'auf dem die Studie durchgeführt wird. '
                    'Das verwendete Gerät wird zusammen mit den Studiendaten gespeichert.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),

                  ..._devices.map((device) {
                    final isSelected = _selectedDeviceId == device.id;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          setState(() {
                            _selectedDeviceId = device.id;
                          });
                        },
                        child: Card(
                          margin: EdgeInsets.zero,
                          elevation: isSelected ? 3 : 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              width: isSelected ? 2 : 1,
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.outlineVariant,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 18,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_unchecked,
                                  color: isSelected
                                      ? colorScheme.primary
                                      : null,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    device.model,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 54,
                    child: FilledButton(
                      onPressed: _selectedDevice == null ? null : _continue,
                      child: const Text(
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

class _StudyDevice {
  final String id;
  final String model;

  const _StudyDevice({
    required this.id,
    required this.model,
  });
}
