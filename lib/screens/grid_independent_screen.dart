import 'package:flutter/material.dart';

import '../models/interaction_event.dart';
import '../models/photo_item.dart';
import '../models/sorting_decision.dart';

class GridIndependentScreen extends StatefulWidget {
  final List<PhotoItem> photos;

  final void Function(
    String photoId,
    SortingAction? previousDecision,
    SortingAction newDecision,
  ) onDecisionChanged;

  final void Function(Map<String, SortingAction> decisions) onConfirm;
  final ValueChanged<InteractionEventDraft> onInteractionEvent;

  const GridIndependentScreen({
    super.key,
    required this.photos,
    required this.onDecisionChanged,
    required this.onConfirm,
    required this.onInteractionEvent,
  });

  @override
  State<GridIndependentScreen> createState() => _GridIndependentScreenState();
}

class _GridIndependentScreenState extends State<GridIndependentScreen> {
  final Set<String> _selectedForDeletion = <String>{};

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _gridViewportKey = GlobalKey();
  late final Map<String, GlobalKey> _tileKeys;

  final Map<String, DateTime> _firstShownAt = <String, DateTime>{};
  final Map<String, DateTime> _visibleSince = <String, DateTime>{};
  final Map<String, int> _visibleDurationMs = <String, int>{};

  bool _visibilityCheckScheduled = false;
  bool _exposureFinalized = false;
  int _shownCounter = 0;

  int get _selectedCount => _selectedForDeletion.length;

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
              presentationIndex: _shownCounter,
              gridPosition: index + 1,
              expectedAction: photo.expectedAction?.name,
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

  void _togglePhoto(PhotoItem photo) {
    final now = DateTime.now();
    _updateVisibility(now: now);

    final wasSelected = _selectedForDeletion.contains(photo.id);

    setState(() {
      if (wasSelected) {
        _selectedForDeletion.remove(photo.id);
      } else {
        _selectedForDeletion.add(photo.id);
      }
    });

    final previousAction =
        wasSelected ? SortingAction.discard : SortingAction.keep;
    final newAction = wasSelected ? SortingAction.keep : SortingAction.discard;

    widget.onDecisionChanged(
      photo.id,
      previousAction,
      newAction,
    );

    final firstShownAt = _firstShownAt[photo.id];
    final gridPosition = widget.photos.indexWhere((p) => p.id == photo.id) + 1;

    widget.onInteractionEvent(
      InteractionEventDraft(
        eventType: 'grid_selection_changed',
        timestamp: now,
        photoId: photo.id,
        gridPosition: gridPosition,
        action: newAction.name,
        previousAction: previousAction.name,
        durationMs: firstShownAt == null
            ? null
            : now.difference(firstShownAt).inMilliseconds,
        visibleDurationMs: _currentVisibleDuration(photo.id, now),
        expectedAction: photo.expectedAction?.name,
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
          gridPosition: index + 1,
          visibleDurationMs: _visibleDurationMs[photo.id] ?? 0,
          durationMs: _firstShownAt[photo.id] == null
              ? null
              : now.difference(_firstShownAt[photo.id]!).inMilliseconds,
          expectedAction: photo.expectedAction?.name,
        ),
      );
    }
  }

  void _confirmSelection() {
    final now = DateTime.now();
    _finalizeExposure(now);

    final completedDecisions = <String, SortingAction>{
      for (final photo in widget.photos)
        photo.id: _selectedForDeletion.contains(photo.id)
            ? SortingAction.discard
            : SortingAction.keep,
    };

    widget.onInteractionEvent(
      InteractionEventDraft(
        eventType: 'grid_confirmed',
        timestamp: now,
      ),
    );

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
                child: Container(
                  key: _gridViewportKey,
                  child: GridView.builder(
                    controller: _scrollController,
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

                      return KeyedSubtree(
                        key: _tileKeys[photo.id],
                        child: _buildPhotoTile(photo, isSelected),
                      );
                    },
                  ),
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
