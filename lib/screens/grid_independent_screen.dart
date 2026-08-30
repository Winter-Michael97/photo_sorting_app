import 'package:flutter/material.dart';

import '../models/photo_item.dart';
import '../models/sorting_decision.dart';

class GridIndependentScreen extends StatefulWidget {
  final List<PhotoItem> photos;

  final void Function(
    String photoId,
    SortingAction? previousDecision,
    SortingAction newDecision,
  )
  onDecisionChanged;

  final void Function(Map<String, SortingAction> decisions) onConfirm;

  const GridIndependentScreen({
    super.key,
    required this.photos,
    required this.onDecisionChanged,
    required this.onConfirm,
  });

  @override
  State<GridIndependentScreen> createState() => _GridIndependentScreenState();
}

class _GridIndependentScreenState extends State<GridIndependentScreen> {
  late Map<String, SortingAction?> _decisions;

  @override
  void initState() {
    super.initState();

    _decisions = {
      for (final photo in widget.photos) photo.id: null,
    };
  }

  void _setDecision(String photoId, SortingAction newDecision) {
    final previousDecision = _decisions[photoId];

    if (previousDecision == newDecision) {
      return;
    }

    setState(() {
      _decisions[photoId] = newDecision;
    });

    widget.onDecisionChanged(photoId, previousDecision, newDecision);
  }

  int get _decidedCount {
    return _decisions.values.where((decision) => decision != null).length;
  }

  bool get _allPhotosDecided {
    return _decidedCount == widget.photos.length;
  }

  void _confirmSelection() {
    if (!_allPhotosDecided) {
      return;
    }

    final completedDecisions = {
      for (final entry in _decisions.entries) entry.key: entry.value!,
    };

    widget.onConfirm(Map.unmodifiable(completedDecisions));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Fotos bewerten',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$_decidedCount / ${widget.photos.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              LinearProgressIndicator(
                value: widget.photos.isEmpty
                    ? 0
                    : _decidedCount / widget.photos.length,
              ),

              const SizedBox(height: 16),

              Expanded(
                child: GridView.builder(
                  itemCount: widget.photos.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  itemBuilder: (context, index) {
                    final photo = widget.photos[index];
                    final decision = _decisions[photo.id];

                    return _buildPhotoCard(photo, decision);
                  },
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _allPhotosDecided ? _confirmSelection : null,
                  child: Text(
                    _allPhotosDecided
                        ? 'Auswahl bestätigen'
                        : 'Alle Fotos bewerten',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoCard(PhotoItem photo, SortingAction? decision) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: Image.asset(photo.assetPath, fit: BoxFit.cover),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _buildDecisionLabel(decision),
          ),

          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: IconButton.filledTonal(
                    onPressed: () {
                      _setDecision(photo.id, SortingAction.discard);
                    },
                    icon: const Icon(Icons.close),
                    tooltip: 'Aussortieren',
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: IconButton.filledTonal(
                    onPressed: () {
                      _setDecision(photo.id, SortingAction.keep);
                    },
                    icon: const Icon(Icons.check),
                    tooltip: 'Behalten',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecisionLabel(SortingAction? decision) {
    switch (decision) {
      case SortingAction.keep:
        return const Text(
          'Behalten',
          style: TextStyle(fontWeight: FontWeight.w600),
        );

      case SortingAction.discard:
        return const Text(
          'Aussortieren',
          style: TextStyle(fontWeight: FontWeight.w600),
        );

      case null:
        return const Text('Nicht bewertet');
    }
  }
}