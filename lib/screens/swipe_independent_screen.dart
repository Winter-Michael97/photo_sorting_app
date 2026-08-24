import 'package:flutter/material.dart';

class SwipeIndependentScreen extends StatefulWidget {
  final String photoId;
  final String photoAssetPath;

  final int currentIndex;
  final int totalCount;

  final ValueChanged<String> onKeep;
  final ValueChanged<String> onDiscard;
  final VoidCallback onUndo;

  final bool canUndo;

  const SwipeIndependentScreen({
    super.key,
    required this.photoId,
    required this.photoAssetPath,
    required this.currentIndex,
    required this.totalCount,
    required this.onKeep,
    required this.onDiscard,
    required this.onUndo,
    this.canUndo = false,
  });

  @override
  State<SwipeIndependentScreen> createState() => _SwipeIndependentScreenState();
}

class _SwipeIndependentScreenState extends State<SwipeIndependentScreen> {
  double _dragX = 0;

  static const double _swipeThreshold = 90;
  static const double _velocityThreshold = 800;

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragX += details.delta.dx;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;

    final discard = _dragX < -_swipeThreshold || velocity < -_velocityThreshold;

    final keep = _dragX > _swipeThreshold || velocity > _velocityThreshold;

    // Foto zunächst wieder in Ausgangsposition setzen.
    setState(() {
      _dragX = 0;
    });

    if (discard) {
      widget.onDiscard(widget.photoId);
    } else if (keep) {
      widget.onKeep(widget.photoId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.totalCount == 0
        ? 0.0
        : widget.currentIndex / widget.totalCount;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Fortschritt........

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Foto ${widget.currentIndex} / ${widget.totalCount}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text('${(progress * 100).round()} %'),
                ],
              ),

              const SizedBox(height: 10),

              LinearProgressIndicator(value: progress),

              const SizedBox(height: 32),

              // ---------- Foto ----------
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
                          widget.photoAssetPath,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ---------- Swipe Erklärung ----------
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: const [
                        Icon(Icons.arrow_back, size: 32),
                        SizedBox(height: 6),
                        Text('Aussortieren', textAlign: TextAlign.center),
                        Text('Swipe links', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),

                  Container(height: 55, width: 1, color: Colors.grey.shade300),

                  Expanded(
                    child: Column(
                      children: const [
                        Icon(Icons.arrow_forward, size: 32),
                        SizedBox(height: 6),
                        Text('Behalten', textAlign: TextAlign.center),
                        Text('Swipe rechts', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ---------- Undo ----------
              TextButton.icon(
                onPressed: widget.canUndo ? widget.onUndo : null,
                icon: const Icon(Icons.undo),
                label: const Text('Undo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
