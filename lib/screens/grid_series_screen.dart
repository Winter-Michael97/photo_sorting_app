import 'package:flutter/material.dart';

import '../models/photo_item.dart';

class GridSeriesScreen extends StatefulWidget {
  final String seriesId;
  final List<PhotoItem> photos;

  final int currentSeriesIndex;
  final int totalSeriesCount;

  final void Function(String seriesId, PhotoItem selectedPhoto)
  onSeriesCompleted;

  const GridSeriesScreen({
    super.key,
    required this.seriesId,
    required this.photos,
    required this.currentSeriesIndex,
    required this.totalSeriesCount,
    required this.onSeriesCompleted,
  });

  @override
  State<GridSeriesScreen> createState() => _GridSeriesScreenState();
}

class _GridSeriesScreenState extends State<GridSeriesScreen> {
  PhotoItem? _selectedPhoto;

  void _selectPhoto(PhotoItem photo) {
    setState(() {
      _selectedPhoto = photo;
    });
  }

  void _confirmSelection() {
    final selectedPhoto = _selectedPhoto;

    if (selectedPhoto == null) {
      return;
    }

    widget.onSeriesCompleted(widget.seriesId, selectedPhoto);
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.totalSeriesCount == 0
        ? 0.0
        : widget.currentSeriesIndex / widget.totalSeriesCount;

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
                  Text(
                    'Serie ${widget.currentSeriesIndex} / ${widget.totalSeriesCount}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${widget.photos.length} Fotos',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              LinearProgressIndicator(value: progress),

              const SizedBox(height: 20),

              const Text(
                'Wähle das beste Foto aus dieser Serie aus.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _selectedPhoto == null
                    ? 'Noch kein Foto ausgewählt'
                    : 'Ausgewählt: ${_selectedPhoto!.id}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
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
                    final isSelected = _selectedPhoto?.id == photo.id;

                    return _buildPhotoCard(photo, isSelected);
                  },
                ),
              ),

              const SizedBox(height: 16),

              // ---------- Bestätigung ----------
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _selectedPhoto == null ? null : _confirmSelection,
                  child: Text(
                    _selectedPhoto == null
                        ? 'Ein Foto auswählen'
                        : 'Auswahl bestätigen',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoCard(PhotoItem photo, bool isSelected) {
    return InkWell(
      onTap: () {
        _selectPhoto(photo);
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: isSelected ? 6 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            width: isSelected ? 3 : 1,
            color: isSelected ? Colors.green : Colors.grey.shade300,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: Image.asset(
                  photo.assetPath,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    size: 20,
                  ),

                  const SizedBox(width: 6),

                  Expanded(
                    child: Text(
                      photo.id,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}