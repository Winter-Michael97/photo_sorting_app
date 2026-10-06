import 'package:flutter/material.dart';

import '../models/interaction_event.dart';
import '../models/photo_item.dart';

class GridSeriesScreen extends StatefulWidget {
  final String seriesId;
  final List<PhotoItem> photos;

  final int currentSeriesIndex;
  final int totalSeriesCount;

  final void Function(String seriesId, PhotoItem selectedPhoto)
      onSeriesCompleted;
  final ValueChanged<InteractionEventDraft> onInteractionEvent;

  const GridSeriesScreen({
    super.key,
    required this.seriesId,
    required this.photos,
    required this.currentSeriesIndex,
    required this.totalSeriesCount,
    required this.onSeriesCompleted,
    required this.onInteractionEvent,
  });

  @override
  State<GridSeriesScreen> createState() => _GridSeriesScreenState();
}

class _GridSeriesScreenState extends State<GridSeriesScreen> {
  PhotoItem? _selectedPhoto;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _gridViewportKey = GlobalKey();
  late final Map<String, GlobalKey> _tileKeys;

  final Map<String, DateTime> _firstShownAt = <String, DateTime>{};
  final Map<String, DateTime> _visibleSince = <String, DateTime>{};
  final Map<String, int> _visibleDurationMs = <String, int>{};

  bool _visibilityCheckScheduled = false;
  bool _exposureFinalized = false;
  int _shownCounter = 0;

  @override
  void initState() {
    super.initState();

    _tileKeys = {
      for (final photo in widget.photos) photo.id: GlobalKey(),
    };

    _scrollController.addListener(_scheduleVisibilityCheck);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateVisibility();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scheduleVisibilityCheck);
    _scrollController.dispose();
    super.dispose();
  }

  void _scheduleVisibilityCheck() {
    if (_visibilityCheckScheduled || !mounted) {
      return;
    }

    _visibilityCheckScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _visibilityCheckScheduled = false;

      if (mounted) {
        _updateVisibility();
      }
    });
  }

  double _visibleFraction(RenderBox tileBox, Rect viewportRect) {
    final tileOrigin = tileBox.localToGlobal(Offset.zero);
    final tileRect = tileOrigin & tileBox.size;

    if (!tileRect.overlaps(viewportRect)) {
      return 0;
    }

    final intersection = tileRect.intersect(viewportRect);
    final tileArea = tileRect.width * tileRect.height;

    if (tileArea <= 0) {
      return 0;
    }

    return (intersection.width * intersection.height) / tileArea;
  }

  void _updateVisibility({DateTime? now}) {
    if (_exposureFinalized) {
      return;
    }

    final viewportContext = _gridViewportKey.currentContext;
    final viewportObject = viewportContext?.findRenderObject();

    if (viewportObject is! RenderBox || !viewportObject.hasSize) {
      return;
    }

    final timestamp = now ?? DateTime.now();
    final viewportOrigin = viewportObject.localToGlobal(Offset.zero);
    final viewportRect = viewportOrigin & viewportObject.size;

    for (int index = 0; index < widget.photos.length; index++) {
      final photo = widget.photos[index];
      final tileContext = _tileKeys[photo.id]?.currentContext;
      final tileObject = tileContext?.findRenderObject();

      final isVisible = tileObject is RenderBox &&
          tileObject.hasSize &&
          _visibleFraction(tileObject, viewportRect) >= 0.5;

      final wasVisible = _visibleSince.containsKey(photo.id);

      if (isVisible && !wasVisible) {
        _visibleSince[photo.id] = timestamp;

        if (!_firstShownAt.containsKey(photo.id)) {
          _firstShownAt[photo.id] = timestamp;
          _shownCounter++;

          widget.onInteractionEvent(
            InteractionEventDraft(
              eventType: 'photo_shown',
              timestamp: timestamp,
              photoId: photo.id,
              seriesId: widget.seriesId,
              presentationIndex: _shownCounter,
              seriesIndex: widget.currentSeriesIndex,
              gridPosition: index + 1,
              isBestInSeries: photo.isBestInSeries,
            ),
          );
        }
      } else if (!isVisible && wasVisible) {
        _closeVisibleInterval(photo.id, timestamp);
      }
    }
  }

  void _closeVisibleInterval(String photoId, DateTime now) {
    final startedAt = _visibleSince.remove(photoId);

    if (startedAt == null) {
      return;
    }

    final elapsed = now.difference(startedAt).inMilliseconds;
    _visibleDurationMs[photoId] =
        (_visibleDurationMs[photoId] ?? 0) + elapsed;
  }

  int _currentVisibleDuration(String photoId, DateTime now) {
    var duration = _visibleDurationMs[photoId] ?? 0;
    final activeSince = _visibleSince[photoId];

    if (activeSince != null) {
      duration += now.difference(activeSince).inMilliseconds;
    }

    return duration;
  }

  void _selectPhoto(PhotoItem photo) {
    final now = DateTime.now();
    _updateVisibility(now: now);

    final previousPhoto = _selectedPhoto;

    setState(() {
      _selectedPhoto = photo;
    });

    final gridPosition = widget.photos.indexWhere((p) => p.id == photo.id) + 1;
    final firstShownAt = _firstShownAt[photo.id];

    widget.onInteractionEvent(
      InteractionEventDraft(
        eventType: 'grid_selection_changed',
        timestamp: now,
        photoId: photo.id,
        seriesId: widget.seriesId,
        seriesIndex: widget.currentSeriesIndex,
        gridPosition: gridPosition,
        action: 'select',
        previousPhotoId: previousPhoto?.id,
        durationMs: firstShownAt == null
            ? null
            : now.difference(firstShownAt).inMilliseconds,
        visibleDurationMs: _currentVisibleDuration(photo.id, now),
        isBestInSeries: photo.isBestInSeries,
      ),
    );
  }

  void _finalizeExposure(DateTime now) {
    if (_exposureFinalized) {
      return;
    }

    _updateVisibility(now: now);

    for (final photoId in _visibleSince.keys.toList()) {
      _closeVisibleInterval(photoId, now);
    }

    _exposureFinalized = true;

    for (int index = 0; index < widget.photos.length; index++) {
      final photo = widget.photos[index];

      widget.onInteractionEvent(
        InteractionEventDraft(
          eventType: 'photo_exposure_summary',
          timestamp: now,
          photoId: photo.id,
          seriesId: widget.seriesId,
          seriesIndex: widget.currentSeriesIndex,
          gridPosition: index + 1,
          visibleDurationMs: _visibleDurationMs[photo.id] ?? 0,
          durationMs: _firstShownAt[photo.id] == null
              ? null
              : now.difference(_firstShownAt[photo.id]!).inMilliseconds,
          isBestInSeries: photo.isBestInSeries,
        ),
      );
    }
  }

  void _confirmSelection() {
    final selectedPhoto = _selectedPhoto;

    if (selectedPhoto == null) {
      return;
    }

    final now = DateTime.now();
    _finalizeExposure(now);

    widget.onInteractionEvent(
      InteractionEventDraft(
        eventType: 'grid_confirmed',
        timestamp: now,
        photoId: selectedPhoto.id,
        seriesId: widget.seriesId,
        seriesIndex: widget.currentSeriesIndex,
        action: 'confirm_selection',
        isBestInSeries: selectedPhoto.isBestInSeries,
      ),
    );

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
                    : 'Foto ausgewählt',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: Container(
                  key: _gridViewportKey,
                  child: GridView.builder(
                    controller: _scrollController,
                    itemCount: widget.photos.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.78,
                    ),
                    itemBuilder: (context, index) {
                      final photo = widget.photos[index];
                      final isSelected = _selectedPhoto?.id == photo.id;

                      return KeyedSubtree(
                        key: _tileKeys[photo.id],
                        child: _buildPhotoCard(photo, isSelected),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

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
      onTap: () => _selectPhoto(photo),
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
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              photo.assetPath,
              fit: BoxFit.cover,
            ),
            if (isSelected)
              const Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  radius: 15,
                  child: Icon(
                    Icons.check,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
