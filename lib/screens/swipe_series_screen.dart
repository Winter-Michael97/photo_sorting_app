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
  int _candidateIndex = 1;
  late PhotoItem _favorite;

  double _dragX = 0;

  static const double _swipeThreshold = 90;
  static const double _velocityThreshold = 800;

  @override
  void initState() {
    super.initState();

    if (widget.photos.isEmpty) {
      throw ArgumentError('SwipeSeriesScreen braucht mindestens ein Foto.');
    }

    _favorite = widget.photos.first;
  }

  PhotoItem get _currentCandidate => widget.photos[_candidateIndex];

  bool get _hasCandidate => _candidateIndex < widget.photos.length;

  double get _progress {
    if (widget.photos.length <= 1) {
      return 1.0;
    }

    return _candidateIndex / widget.photos.length;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragX += details.delta.dx;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;

    final discard = _dragX < -_swipeThreshold || velocity < -_velocityThreshold;
    final choose = _dragX > _swipeThreshold || velocity > _velocityThreshold;

    setState(() {
      _dragX = 0;
    });

    if (discard) {
      _discardCandidate();
    } else if (choose) {
      _chooseCandidateAsFavorite();
    }
  }

  void _discardCandidate() {
    _goToNextCandidate();
  }

  void _chooseCandidateAsFavorite() {
    setState(() {
      _favorite = _currentCandidate;
    });

    _goToNextCandidate();
  }

  void _goToNextCandidate() {
    final nextIndex = _candidateIndex + 1;

    if (nextIndex < widget.photos.length) {
      setState(() {
        _candidateIndex = nextIndex;
      });
    } else {
      widget.onSeriesCompleted(widget.seriesId, _favorite);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasCandidate) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Text(
              'Ausgewähltes Foto: ${_favorite.id}',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final candidate = _currentCandidate;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ---------- Fortschritt ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Serie ${widget.currentSeriesIndex} / ${widget.totalSeriesCount}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Vergleich ${_candidateIndex + 1} / ${widget.photos.length}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              LinearProgressIndicator(value: _progress),

              const SizedBox(height: 20),

              // ---------- Aktueller Favorit ----------
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        _favorite.assetPath,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Aktueller Favorit',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            _favorite.id,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ---------- Vergleichsfoto ----------
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
                          maxHeight: 600,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          candidate.assetPath,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Vergleichsfoto: ${candidate.id}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 20),

              // ---------- Swipe Erklärung ----------
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: const [
                        Icon(Icons.arrow_back, size: 32),
                        SizedBox(height: 6),
                        Text(
                          'Vergleichsfoto aussortieren',
                          textAlign: TextAlign.center,
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
                        Icon(Icons.arrow_forward, size: 32),
                        SizedBox(height: 6),
                        Text(
                          'Als neuen Favoriten wählen',
                          textAlign: TextAlign.center,
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