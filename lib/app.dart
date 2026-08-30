import 'package:flutter/material.dart';

import 'data/study_conditions.dart';

import 'models/photo_item.dart';
import 'models/sorting_decision.dart';
import 'models/study_condition.dart';

import 'screens/start_screen.dart';
import 'screens/condition_intro_screen.dart';
import 'screens/swipe_independent_screen.dart';
import 'screens/grid_independent_screen.dart';
import 'screens/swipe_series_screen.dart';
import 'screens/grid_series_screen.dart';
import 'screens/condition_complete_screen.dart';
import 'screens/study_complete_screen.dart';

enum AppStep {
  start,
  conditionIntro,
  swipeIndependent,
  gridIndependent,
  swipeSeries,
  gridSeries,
  conditionComplete,
  studyComplete,
}

class PhotoSortingApp extends StatelessWidget {
  const PhotoSortingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Sorting Study',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const StudyAppShell(),
    );
  }
}

class StudyAppShell extends StatefulWidget {
  const StudyAppShell({super.key});

  @override
  State<StudyAppShell> createState() => _StudyAppShellState();
}

class _StudyAppShellState extends State<StudyAppShell> {
  AppStep _currentStep = AppStep.start;

  String? _participantId;

  int _currentConditionIndex = 0;
  int _currentSwipePhotoIndex = 0;
  int _currentSeriesIndex = 0;

  final List<SortingDecision> _decisions = [];

  int get _totalConditions => studyConditions.length;

  StudyCondition get _currentCondition =>
      studyConditions[_currentConditionIndex];

  List<List<PhotoItem>> get _currentSeriesGroups {
    final groupedPhotos = <String, List<PhotoItem>>{};

    for (final photo in _currentCondition.photos) {
      final seriesId = photo.seriesId ?? '${_currentCondition.id}_series_01';

      groupedPhotos.putIfAbsent(seriesId, () => []);
      groupedPhotos[seriesId]!.add(photo);
    }

    return groupedPhotos.values.toList();
  }

  void _startStudy(String participantId) {
    setState(() {
      _participantId = participantId;
      _currentConditionIndex = 0;
      _currentSwipePhotoIndex = 0;
      _currentSeriesIndex = 0;
      _decisions.clear();
      _currentStep = AppStep.conditionIntro;
    });

    debugPrint('Studie gestartet: $participantId');
  }

  void _startCurrentCondition() {
    final condition = _currentCondition;

    setState(() {
      _currentSwipePhotoIndex = 0;
      _currentSeriesIndex = 0;

      if (condition.interfaceType == InterfaceType.swipe &&
          condition.taskType == TaskType.independent) {
        _currentStep = AppStep.swipeIndependent;
      } else if (condition.interfaceType == InterfaceType.grid &&
          condition.taskType == TaskType.independent) {
        _currentStep = AppStep.gridIndependent;
      } else if (condition.interfaceType == InterfaceType.swipe &&
          condition.taskType == TaskType.series) {
        _currentStep = AppStep.swipeSeries;
      } else if (condition.interfaceType == InterfaceType.grid &&
          condition.taskType == TaskType.series) {
        _currentStep = AppStep.gridSeries;
      } else {
        throw UnimplementedError(
          'Diese Bedingung ist noch nicht umgesetzt: ${condition.id}',
        );
      }
    });

    debugPrint('Condition gestartet: ${condition.id}');
  }

  void _handleSwipeKeep(PhotoItem photo) {
    _saveDecision(
      photoId: photo.id,
      action: SortingAction.keep,
    );

    _goToNextSwipePhoto();
  }

  void _handleSwipeDiscard(PhotoItem photo) {
    _saveDecision(
      photoId: photo.id,
      action: SortingAction.discard,
    );

    _goToNextSwipePhoto();
  }

  void _goToNextSwipePhoto() {
    final photos = _currentCondition.photos;

    if (_currentSwipePhotoIndex < photos.length - 1) {
      setState(() {
        _currentSwipePhotoIndex++;
      });
    } else {
      _finishCurrentCondition();
    }
  }

  void _handleGridDecisionChanged(
    String photoId,
    SortingAction? previousDecision,
    SortingAction newDecision,
  ) {
    debugPrint('Grid geändert: $photoId $previousDecision -> $newDecision');
  }

  void _handleGridConfirm(Map<String, SortingAction> decisions) {
    for (final entry in decisions.entries) {
      _saveDecision(
        photoId: entry.key,
        action: entry.value,
      );
    }

    _finishCurrentCondition();
  }

  void _handleSwipeSeriesCompleted(String seriesId, PhotoItem selectedPhoto) {
    _saveDecision(
      photoId: selectedPhoto.id,
      action: SortingAction.keep,
    );

    debugPrint(
      'Swipe-Serie abgeschlossen: $seriesId, Favorit: ${selectedPhoto.id}',
    );

    _goToNextSeries();
  }

  void _handleGridSeriesCompleted(String seriesId, PhotoItem selectedPhoto) {
    _saveDecision(
      photoId: selectedPhoto.id,
      action: SortingAction.keep,
    );

    debugPrint(
      'Raster-Serie abgeschlossen: $seriesId, Favorit: ${selectedPhoto.id}',
    );

    _goToNextSeries();
  }

  void _goToNextSeries() {
    final seriesGroups = _currentSeriesGroups;

    if (_currentSeriesIndex < seriesGroups.length - 1) {
      setState(() {
        _currentSeriesIndex++;
      });
    } else {
      _finishCurrentCondition();
    }
  }

  void _saveDecision({
    required String photoId,
    required SortingAction action,
  }) {
    final decision = SortingDecision(
      participantId: _participantId ?? 'unknown',
      conditionId: _currentCondition.id,
      photoId: photoId,
      action: action,
      timestamp: DateTime.now(),
    );

    _decisions.add(decision);

    debugPrint('Entscheidung gespeichert: ${decision.toCsvRow()}');
  }

  void _finishCurrentCondition() {
    setState(() {
      _currentStep = AppStep.conditionComplete;
    });

    debugPrint('Condition ${_currentCondition.id} abgeschlossen.');
  }

  void _continueAfterCondition() {
    final isLastCondition = _currentConditionIndex == _totalConditions - 1;

    if (isLastCondition) {
      setState(() {
        _currentStep = AppStep.studyComplete;
      });
    } else {
      setState(() {
        _currentConditionIndex++;
        _currentSwipePhotoIndex = 0;
        _currentSeriesIndex = 0;
        _currentStep = AppStep.conditionIntro;
      });
    }
  }

  void _exportData() {
    debugPrint('--- EXPORT ---');
    debugPrint('participantId,conditionId,photoId,action,timestamp');

    for (final decision in _decisions) {
      debugPrint(decision.toCsvRow());
    }
  }

  Widget _buildErrorScreen(String message) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentStep) {
      case AppStep.start:
        return StartScreen(
          onStartStudy: _startStudy,
        );

      case AppStep.conditionIntro:
        return ConditionIntroScreen(
          conditionNumber:
              'Aufgabe ${_currentConditionIndex + 1} von $_totalConditions',
          title: _currentCondition.title,
          description: _currentCondition.description,
          instructions: _currentCondition.instructions,
          onStart: _startCurrentCondition,
        );

      case AppStep.swipeIndependent:
        if (_currentCondition.photos.isEmpty) {
          return _buildErrorScreen(
            'Für diese Swipe-Aufgabe wurden keine Fotos gefunden.',
          );
        }

        final currentPhoto = _currentCondition.photos[_currentSwipePhotoIndex];

        return SwipeIndependentScreen(
          key: ValueKey('${_currentCondition.id}_${currentPhoto.id}'),
          photo: currentPhoto,
          currentIndex: _currentSwipePhotoIndex + 1,
          totalCount: _currentCondition.photos.length,
          onKeep: _handleSwipeKeep,
          onDiscard: _handleSwipeDiscard,
        );

      case AppStep.gridIndependent:
        if (_currentCondition.photos.isEmpty) {
          return _buildErrorScreen(
            'Für diese Raster-Aufgabe wurden keine Fotos gefunden.',
          );
        }

        return GridIndependentScreen(
          key: ValueKey(_currentCondition.id),
          photos: _currentCondition.photos,
          onDecisionChanged: _handleGridDecisionChanged,
          onConfirm: _handleGridConfirm,
        );

      case AppStep.swipeSeries:
        final seriesGroups = _currentSeriesGroups;

        if (seriesGroups.isEmpty) {
          return _buildErrorScreen(
            'Für diese Serien-Aufgabe wurden keine Fotos gefunden.',
          );
        }

        final currentSeriesPhotos = seriesGroups[_currentSeriesIndex];
        final currentSeriesId =
            currentSeriesPhotos.first.seriesId ??
            '${_currentCondition.id}_series_${_currentSeriesIndex + 1}';

        return SwipeSeriesScreen(
          key: ValueKey('${_currentCondition.id}_$currentSeriesId'),
          seriesId: currentSeriesId,
          photos: currentSeriesPhotos,
          currentSeriesIndex: _currentSeriesIndex + 1,
          totalSeriesCount: seriesGroups.length,
          onSeriesCompleted: _handleSwipeSeriesCompleted,
        );

      case AppStep.gridSeries:
        final seriesGroups = _currentSeriesGroups;

        if (seriesGroups.isEmpty) {
          return _buildErrorScreen(
            'Für diese Serien-Aufgabe wurden keine Fotos gefunden.',
          );
        }

        final currentSeriesPhotos = seriesGroups[_currentSeriesIndex];
        final currentSeriesId =
            currentSeriesPhotos.first.seriesId ??
            '${_currentCondition.id}_series_${_currentSeriesIndex + 1}';

        return GridSeriesScreen(
          key: ValueKey('${_currentCondition.id}_$currentSeriesId'),
          seriesId: currentSeriesId,
          photos: currentSeriesPhotos,
          currentSeriesIndex: _currentSeriesIndex + 1,
          totalSeriesCount: seriesGroups.length,
          onSeriesCompleted: _handleGridSeriesCompleted,
        );

      case AppStep.conditionComplete:
        return ConditionCompleteScreen(
          completedCondition: _currentConditionIndex + 1,
          totalConditions: _totalConditions,
          onContinue: _continueAfterCondition,
        );

      case AppStep.studyComplete:
        return StudyCompleteScreen(
          participantId: _participantId ?? 'unknown',
          totalConditions: _totalConditions,
          onExport: _exportData,
        );
    }
  }
}