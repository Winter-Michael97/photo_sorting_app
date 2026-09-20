import 'package:flutter/material.dart';

import '../models/photo_item.dart';

class SwipeSeriesScreen extends StatefulWidget {
  final String seriesId;
  final List<PhotoItem> photos;

  final int currentSeriesIndex;
  final int totalSeriesCount;

  final void Function(String seriesId, PhotoItem selectedPhoto)
      onSeriesCompleted;

  const SwipeSeriesScreen({
    super.key,
    required this.seriesId,
    required this.photos,
    required this.currentSeriesIndex,
    required this.totalSeriesCount,
    required this.onSeriesCompleted,
  });

  @override
  State<SwipeSeriesScreen> createState() => _SwipeSeriesScreenState();
}

class _SwipeSeriesScreenState extends State<SwipeSeriesScreen> {
  late List<PhotoItem> _roundPhotos;
  final List<PhotoItem> _keptForNextRound = [];

  int _photoIndex = 0;
  int _roundNumber = 1;

  double _dragX = 0;

  static const double _swipeThreshold = 90;
  static const double _velocityThreshold = 800;

  @override
  void initState() {
    super.initState();

    if (widget.photos.isEmpty) {
      throw ArgumentError('SwipeSeriesScreen braucht mindestens ein Foto.');
    }

    _roundPhotos = List<PhotoItem>.from(widget.photos);

    // Falls eine Serie ausnahmsweise nur ein Foto enthält, ist die Auswahl
    // bereits eindeutig.
    if (_roundPhotos.length == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        widget.onSeriesCompleted(widget.seriesId, _roundPhotos.first);
      });
    }
  }

  PhotoItem get _currentPhoto => _roundPhotos[_photoIndex];

  int get _remainingInRound => _roundPhotos.length - _photoIndex;

  double get _progress {
    if (_roundPhotos.isEmpty) {
      return 1.0;
    }

    return (_photoIndex + 1) / _roundPhotos.length;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragX += details.delta.dx;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final dragX = _dragX;

    // WICHTIG:
    // Zuerst entscheidet die tatsächliche Wischrichtung über den Weg.
    // Die Geschwindigkeit wird nur verwendet, wenn die Strecke noch nicht
    // eindeutig genug war. Dadurch kann ein Rechts-Swipe nicht versehentlich
    // als "Aussortieren" gewertet werden, nur weil die Endgeschwindigkeit
    // kurz in die Gegenrichtung zeigt.
    bool discard = false;
    bool keep = false;

    if (dragX <= -_swipeThreshold) {
      discard = true;
    } else if (dragX >= _swipeThreshold) {
      keep = true;
    } else if (velocity <= -_velocityThreshold) {
      discard = true;
    } else if (velocity >= _velocityThreshold) {
      keep = true;
    }

    setState(() {
      _dragX = 0;
    });

    if (discard) {
      _discardCurrentPhoto();
    } else if (keep) {
      _keepCurrentPhoto();
    }
  }

  void _discardCurrentPhoto() {
    // Das letzte noch mögliche Foto darf nicht ebenfalls aussortiert werden.
    // Beispiel: In dieser Runde wurde bisher kein Foto behalten und nur das
    // aktuelle Foto ist noch übrig.
    if (_keptForNextRound.isEmpty && _remainingInRound == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Mindestens ein Foto muss übrig bleiben. '
            'Behalte dieses Foto für die nächste Runde.',
          ),
        ),
      );
      return;
    }

    _advanceAfterDecision();
  }

  void _keepCurrentPhoto() {
    _keptForNextRound.add(_currentPhoto);
    _advanceAfterDecision();
  }

  void _advanceAfterDecision() {
    final isLastPhotoInRound = _photoIndex == _roundPhotos.length - 1;

    if (!isLastPhotoInRound) {
      setState(() {
        _photoIndex++;
      });
      return;
    }

    _finishRound();
  }

  void _finishRound() {
    if (_keptForNextRound.isEmpty) {
      // Sollte durch die Sperre in _discardCurrentPhoto nicht vorkommen.
      return;
    }

    if (_keptForNextRound.length == 1) {
      final selectedPhoto = _keptForNextRound.first;
      widget.onSeriesCompleted(widget.seriesId, selectedPhoto);
      return;
    }

    // Wenn alle aktuell verbliebenen Fotos erneut behalten wurden, gab es
    // in dieser Runde keine Eingrenzung. Dann bleiben wir bewusst bei
    // derselben Serie und verlangen mindestens eine Aussortierung.
    //
    // Beispiel: Es sind noch 3 Fotos im Rennen und alle 3 werden wieder
    // behalten -> NICHT zur nächsten Serie springen und auch keine neue
    // "identische" Runde erzeugen.
    if (_keptForNextRound.length == _roundPhotos.length) {
      setState(() {
        _keptForNextRound.clear();
        _photoIndex = 0;
        _dragX = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Du hast alle verbliebenen Fotos behalten. '
            'Bitte sortiere in dieser Runde mindestens ein Foto aus.',
          ),
          duration: Duration(milliseconds: 1800),
        ),
      );
      return;
    }

    final nextRoundPhotos = List<PhotoItem>.from(_keptForNextRound);

    setState(() {
      _roundPhotos = nextRoundPhotos;
      _keptForNextRound.clear();
      _photoIndex = 0;
      _roundNumber++;
      _dragX = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${nextRoundPhotos.length} Fotos sind noch im Rennen. '
          'Vergleiche sie erneut.',
        ),
        duration: const Duration(milliseconds: 1400),
      ),
    );
  }

  Color? get _swipeHintColor {
    if (_dragX <= -_swipeThreshold * 0.45) {
      return Colors.red.withValues(alpha: 0.08);
    }

    if (_dragX >= _swipeThreshold * 0.45) {
      return Colors.green.withValues(alpha: 0.08);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_roundPhotos.length == 1) {
      return const Scaffold(
        body: SafeArea(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    final photo = _currentPhoto;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ---------- Serie / Runde ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Serie ${widget.currentSeriesIndex} / '
                    '${widget.totalSeriesCount}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Runde $_roundNumber',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Foto ${_photoIndex + 1} / ${_roundPhotos.length}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    '${_keptForNextRound.length} behalten',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              LinearProgressIndicator(value: _progress),

              const SizedBox(height: 14),

              Text(
                _roundNumber == 1
                    ? 'Behalte alle Fotos, die als möglicher Favorit '
                        'weiter im Rennen bleiben sollen.'
                    : 'Vergleiche die verbliebenen Fotos erneut und '
                        'sortiere weitere aus.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 18),

              // ---------- Aktuelles Foto ----------
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onHorizontalDragUpdate: _handleDragUpdate,
                    onHorizontalDragEnd: _handleDragEnd,
                    child: Transform.translate(
                      offset: Offset(_dragX, 0),
                      child: Container(
                        constraints: const BoxConstraints(
                          maxWidth: 500,
                          maxHeight: 640,
                        ),
                        decoration: BoxDecoration(
                          color: _swipeHintColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          photo.assetPath,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Noch ${_remainingInRound - 1} Foto(s) danach in dieser Runde',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 18),

              // ---------- Swipe Erklärung ----------
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: const [
                        Icon(
                          Icons.arrow_back,
                          size: 32,
                          color: Colors.redAccent,
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Aussortieren',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Swipe links',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    height: 60,
                    width: 1,
                    color: Colors.grey.shade300,
                  ),

                  Expanded(
                    child: Column(
                      children: const [
                        Icon(
                          Icons.arrow_forward,
                          size: 32,
                          color: Colors.green,
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Behalten',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Swipe rechts',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
