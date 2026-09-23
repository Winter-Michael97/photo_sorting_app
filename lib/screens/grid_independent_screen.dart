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
  final Set<String> _selectedForDeletion = <String>{};

  int get _selectedCount => _selectedForDeletion.length;

  void _togglePhoto(PhotoItem photo) {
    final wasSelected = _selectedForDeletion.contains(photo.id);

    setState(() {
      if (wasSelected) {
        _selectedForDeletion.remove(photo.id);
      } else {
        _selectedForDeletion.add(photo.id);
      }
    });

    // Für die bestehende App-Schnittstelle:
    // markiert = aussortieren, unmarkiert = behalten.
    widget.onDecisionChanged(
      photo.id,
      wasSelected ? SortingAction.discard : SortingAction.keep,
      wasSelected ? SortingAction.keep : SortingAction.discard,
    );
  }

  void _confirmSelection() {
    final completedDecisions = <String, SortingAction>{
      for (final photo in widget.photos)
        photo.id: _selectedForDeletion.contains(photo.id)
            ? SortingAction.discard
            : SortingAction.keep,
    };

    widget.onConfirm(Map.unmodifiable(completedDecisions));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Fotos auswählen',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$_selectedCount ausgewählt',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              const Text(
                'Tippe auf die Fotos, die du aussortieren möchtest. '
                'Nicht markierte Fotos werden behalten.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),

              const SizedBox(height: 14),

              Expanded(
                child: GridView.builder(
                  itemCount: widget.photos.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.90,
                  ),
                  itemBuilder: (context, index) {
                    final photo = widget.photos[index];
                    final isSelected =
                        _selectedForDeletion.contains(photo.id);

                    return _buildPhotoTile(photo, isSelected);
                  },
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: _confirmSelection,
                  icon: Icon(
                    _selectedCount == 0
                        ? Icons.check
                        : Icons.delete_outline,
                  ),
                  label: Text(
                    _selectedCount == 0
                        ? 'Ohne Löschen fortfahren'
                        : '$_selectedCount ausgewählte '
                            '${_selectedCount == 1 ? 'Foto' : 'Fotos'} löschen',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoTile(PhotoItem photo, bool isSelected) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () => _togglePhoto(photo),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              photo.assetPath,
              fit: BoxFit.cover,
            ),

            if (isSelected)
              Container(
                color: Colors.black.withValues(alpha: 0.30),
              ),

            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? colorScheme.error
                      : Colors.black.withValues(alpha: 0.42),
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: Icon(
                  isSelected ? Icons.check : Icons.circle_outlined,
                  size: 19,
                  color: Colors.white,
                ),
              ),
            ),

            if (isSelected)
              const Positioned(
                left: 8,
                bottom: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0x99000000),
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 17,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Löschen',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
