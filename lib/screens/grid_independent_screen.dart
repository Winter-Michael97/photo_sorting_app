import 'package:flutter/material.dart';

/// Mögliche Zustände eines Fotos innerhalb der Raster-Bedingung.
enum GridDecision { undecided, keep, discard }

class GridPhotoItem {
  final String id;
  final String assetPath;

  const GridPhotoItem({required this.id, required this.assetPath});
}

class GridIndependentScreen extends StatefulWidget {
  final List<GridPhotoItem> photos;

  // Wird bei jeder Änderung einer Entscheidung ausgelöst.
  // Dadurch kann die Experimentlogik später beispielsweise, Selection Changes oder vorherige Entscheidungen loggen.
  final void Function(
    String photoId,
    GridDecision previousDecision,
    GridDecision newDecision,
  )
  onDecisionChanged;

  // Wird ausgelöst, wenn alle Fotos bewertet wurden und auswahl bestätigt wird
  final void Function(Map<String, GridDecision> decisions) onConfirm;

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
  late Map<String, GridDecision> _decisions;

  @override
  void initState() {
    super.initState();

    // fotos sind anfangst unbewertet
    _decisions = {
      for (final photo in widget.photos) photo.id: GridDecision.undecided,
    };
  }

  void _setDecision(String photoId, GridDecision newDecision) {
    final previousDecision = _decisions[photoId] ?? GridDecision.undecided;

    // Wenn dieselbe Entscheidung erneut gedrückt wird,
    // muss nichts verändert werden.
    if (previousDecision == newDecision) {
      return;
    }

    setState(() {
      _decisions[photoId] = newDecision;
    });

    // Änderung an die Experimentlogik weitergeben.
    widget.onDecisionChanged(photoId, previousDecision, newDecision);
  }

  int get _decidedCount {
    return _decisions.values
        .where((decision) => decision != GridDecision.undecided)
        .length;
  }

  bool get _allPhotosDecided {
    return _decidedCount == widget.photos.length;
  }

  void _confirmSelection() {
    if (!_allPhotosDecided) {
      return;
    }

    widget.onConfirm(Map.unmodifiable(_decisions));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ---------- Fortschritt ----------

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

              // ---------- Foto-Raster ----------
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

                    final decision =
                        _decisions[photo.id] ?? GridDecision.undecided;

                    return _buildPhotoCard(photo, decision);
                  },
                ),
              ),

              const SizedBox(height: 16),

              // ---------- Bestätigung ----------
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

  Widget _buildPhotoCard(GridPhotoItem photo, GridDecision decision) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ---------- Bild ----------

          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: Image.asset(photo.assetPath, fit: BoxFit.cover),
            ),
          ),

          // ---------- Aktueller Zustand ----------
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _buildDecisionLabel(decision),
          ),

          // ---------- Entscheidung ----------
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: IconButton.filledTonal(
                    onPressed: () {
                      _setDecision(photo.id, GridDecision.discard);
                    },
                    icon: const Icon(Icons.close),
                    tooltip: 'Aussortieren',
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: IconButton.filledTonal(
                    onPressed: () {
                      _setDecision(photo.id, GridDecision.keep);
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

  Widget _buildDecisionLabel(GridDecision decision) {
    switch (decision) {
      case GridDecision.keep:
        return const Text(
          'Behalten',
          style: TextStyle(fontWeight: FontWeight.w600),
        );

      case GridDecision.discard:
        return const Text(
          'Aussortieren',
          style: TextStyle(fontWeight: FontWeight.w600),
        );

      case GridDecision.undecided:
        return const Text('Nicht bewertet');
    }
  }
}
