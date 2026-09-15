import 'package:flutter/material.dart';

import 'data/study_conditions.dart';

import 'models/photo_item.dart';
import 'models/sorting_decision.dart';
import 'models/study_condition.dart';
import 'models/study_session_info.dart';
import 'models/condition_timing.dart';

import 'screens/start_screen.dart';
import 'screens/condition_intro_screen.dart';
import 'screens/swipe_independent_screen.dart';
import 'screens/grid_independent_screen.dart';
import 'screens/swipe_series_screen.dart';
import 'screens/grid_series_screen.dart';
import 'screens/condition_complete_screen.dart';
import 'screens/subjective_rating_screen.dart';
import 'screens/final_questionnaire_screen.dart';
import 'screens/demographics_screen.dart';
import 'screens/study_complete_screen.dart';

import 'services/firestore_service.dart';

enum AppStep {
  start,
  conditionIntro,
  swipeIndependent,
  gridIndependent,
  swipeSeries,
  gridSeries,
  conditionComplete,
  subjectiveRating,
  finalQuestionnaire,
  demographics,
  studyComplete,
}

class PhotoSortingApp extends StatelessWidget {
  const PhotoSortingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Sorting Study',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
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

  StudySessionInfo? _sessionInfo;

  int _currentConditionIndex = 0;
  int _currentSwipePhotoIndex = 0;
  int _currentSeriesIndex = 0;

  List<StudyCondition> _conditionOrder = List.of(studyConditions);
  int _counterbalanceGroup = 1;

  final List<SortingDecision> _decisions = [];
  final Map<String, Map<String, int>> _subjectiveRatings = {};
  final List<ConditionTiming> _conditionTimings = [];
  final Map<String, dynamic> _finalQuestionnaire = {};
  final Map<String, dynamic> _demographics = {};

  final FirestoreService _firestoreService = FirestoreService();

  static const String _appVersion = '0.1.0';

  bool _isExporting = false;

  DateTime? _currentConditionStartedAt;

  int get _totalConditions => _conditionOrder.length;

  StudyCondition get _currentCondition =>
      _conditionOrder[_currentConditionIndex];

  List<RatingQuestion> get _currentRatingQuestions {
    return [
      const RatingQuestion(
        id: 'ease',
        text: 'Die Bedienung war einfach verständlich.',
      ),
      const RatingQuestion(
        id: 'control',
        text:
            'Ich hatte das Gefühl, die Kontrolle über meine Entscheidungen zu behalten.',
      ),
      const RatingQuestion(
        id: 'confidence',
        text: 'Ich war mir bei meinen Entscheidungen sicher.',
      ),
      const RatingQuestion(
        id: 'workload',
        text: 'Die Aufgabe war anstrengend.',
      ),
      const RatingQuestion(
        id: 'satisfaction',
        text: 'Die Bedienung war angenehm.',
      ),
      if (_currentCondition.taskType == TaskType.series)
        const RatingQuestion(
          id: 'comparison',
          text: 'Ich konnte die Fotos gut miteinander vergleichen.',
        ),
    ];
  }

  List<List<PhotoItem>> get _currentSeriesGroups {
    final groupedPhotos = <String, List<PhotoItem>>{};

    for (final photo in _currentCondition.photos) {
      final seriesId = photo.seriesId ?? '${_currentCondition.id}_series_01';

      groupedPhotos.putIfAbsent(seriesId, () => []);
      groupedPhotos[seriesId]!.add(photo);
    }

    return groupedPhotos.values.toList();
  }

  StudyCondition _copyConditionWithPhotos(
    StudyCondition condition,
    List<PhotoItem> photos,
  ) {
    return StudyCondition(
      id: condition.id,
      interfaceType: condition.interfaceType,
      taskType: condition.taskType,
      title: condition.title,
      description: condition.description,
      instructions: condition.instructions,
      photos: photos,
    );
  }

  List<StudyCondition> _buildCounterbalancedStudyConditions(int group) {
    final saBase = studyConditions.firstWhere((condition) => condition.id == 'SA');
    final raBase = studyConditions.firstWhere((condition) => condition.id == 'RA');
    final sbBase = studyConditions.firstWhere((condition) => condition.id == 'SB');
    final rbBase = studyConditions.firstWhere((condition) => condition.id == 'RB');

    final normalSetAssignment = group == 1 || group == 3;

    final sa = _copyConditionWithPhotos(
      saBase,
      normalSetAssignment ? clearA1Photos : clearA2Photos,
    );

    final ra = _copyConditionWithPhotos(
      raBase,
      normalSetAssignment ? clearA2Photos : clearA1Photos,
    );

    final sb = _copyConditionWithPhotos(
      sbBase,
      normalSetAssignment ? seriesB1Photos : seriesB2Photos,
    );

    final rb = _copyConditionWithPhotos(
      rbBase,
      normalSetAssignment ? seriesB2Photos : seriesB1Photos,
    );

    switch (group) {
      case 1:
        return [sa, ra, rb, sb];
      case 2:
        return [ra, sb, sa, rb];
      case 3:
        return [sb, rb, ra, sa];
      case 4:
        return [rb, sa, sb, ra];
      default:
        return [sa, ra, rb, sb];
    }
  }

  int _getCounterbalanceGroup(String participantId) {
    final match = RegExp(r'\d+').firstMatch(participantId);

    if (match == null) {
      return 1;
    }

    final participantNumber = int.tryParse(match.group(0)!);

    if (participantNumber == null || participantNumber <= 0) {
      return 1;
    }

    return ((participantNumber - 1) % 4) + 1;
  }

  Future<void> _startStudy({
    required String deviceId,
    required String testerId,
  }) async {
    final participantId = await _firestoreService.getNextParticipantId();

    final sessionInfo = StudySessionInfo(
      participantId: participantId,
      deviceId: deviceId,
      testerId: testerId,
    );

    final group = _getCounterbalanceGroup(participantId);
    final conditionOrder = _buildCounterbalancedStudyConditions(group);

    setState(() {
      _sessionInfo = sessionInfo;
      _counterbalanceGroup = group;
      _conditionOrder = conditionOrder;

      _currentConditionIndex = 0;
      _currentSwipePhotoIndex = 0;
      _currentSeriesIndex = 0;

      _decisions.clear();
      _subjectiveRatings.clear();
      _conditionTimings.clear();
      _finalQuestionnaire.clear();
      _demographics.clear();

      _currentConditionStartedAt = null;
      _isExporting = false;

      _currentStep = AppStep.conditionIntro;
    });

    debugPrint('Studie gestartet: $participantId');
    debugPrint('Gerät: $deviceId');
    debugPrint('Versuchsleiter: $testerId');
    debugPrint('Counterbalance-Gruppe: $group');
    debugPrint(
      'Reihenfolge: ${conditionOrder.map((condition) => condition.id).join(' -> ')}',
    );
  }

  void _startCurrentCondition() {
    final condition = _currentCondition;

    setState(() {
      _currentSwipePhotoIndex = 0;
      _currentSeriesIndex = 0;
      _currentConditionStartedAt = DateTime.now();

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
    _saveDecision(photo: photo, action: SortingAction.keep);
    _goToNextSwipePhoto();
  }

  void _handleSwipeDiscard(PhotoItem photo) {
    _saveDecision(photo: photo, action: SortingAction.discard);
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
      final photo = _findCurrentPhotoById(entry.key);

      if (photo == null) {
        debugPrint('Foto nicht gefunden: ${entry.key}');
        continue;
      }

      _saveDecision(photo: photo, action: entry.value);
    }

    _finishCurrentCondition();
  }

  void _handleSwipeSeriesCompleted(String seriesId, PhotoItem selectedPhoto) {
    _saveDecision(photo: selectedPhoto, action: SortingAction.keep);

    debugPrint(
      'Swipe-Serie abgeschlossen: $seriesId, Favorit: ${selectedPhoto.id}',
    );

    _goToNextSeries();
  }

  void _handleGridSeriesCompleted(String seriesId, PhotoItem selectedPhoto) {
    _saveDecision(photo: selectedPhoto, action: SortingAction.keep);

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

  PhotoItem? _findCurrentPhotoById(String photoId) {
    for (final photo in _currentCondition.photos) {
      if (photo.id == photoId) {
        return photo;
      }
    }

    return null;
  }

  void _saveDecision({
    required PhotoItem photo,
    required SortingAction action,
  }) {
    final condition = _currentCondition;

    bool? isCorrect;

    if (condition.taskType == TaskType.independent &&
        photo.expectedAction != null) {
      isCorrect = action == photo.expectedAction;
    }

    if (condition.taskType == TaskType.series) {
      isCorrect = photo.isBestInSeries;
    }

    final decision = SortingDecision(
      participantId: _sessionInfo?.participantId ?? 'unknown',
      conditionId: condition.id,
      interfaceType: condition.interfaceType.name,
      taskType: condition.taskType.name,
      photoId: photo.id,
      seriesId: photo.seriesId,
      action: action,
      expectedAction: photo.expectedAction,
      isBestInSeries:
          condition.taskType == TaskType.series ? photo.isBestInSeries : null,
      isCorrect: isCorrect,
      timestamp: DateTime.now(),
    );

    _decisions.add(decision);

    debugPrint('Entscheidung gespeichert: ${decision.toCsvRow()}');
  }

  void _finishCurrentCondition() {
    final condition = _currentCondition;
    final endedAt = DateTime.now();
    final startedAt = _currentConditionStartedAt ?? endedAt;

    final timing = ConditionTiming(
      conditionId: condition.id,
      interfaceType: condition.interfaceType.name,
      taskType: condition.taskType.name,
      startedAt: startedAt,
      endedAt: endedAt,
      durationMs: endedAt.difference(startedAt).inMilliseconds,
    );

    _conditionTimings.add(timing);
    _currentConditionStartedAt = null;

    setState(() {
      _currentStep = AppStep.conditionComplete;
    });

    debugPrint(
      'Condition ${condition.id} abgeschlossen. Dauer: ${timing.durationMs} ms',
    );
  }

  void _openSubjectiveRating() {
    setState(() {
      _currentStep = AppStep.subjectiveRating;
    });
  }

  void _handleRatingSubmit(Map<String, int> answers) {
    final conditionId = _currentCondition.id;

    _subjectiveRatings[conditionId] = Map<String, int>.from(answers);

    debugPrint('Ratings gespeichert für $conditionId: $answers');

    final isLastCondition = _currentConditionIndex == _totalConditions - 1;

    if (isLastCondition) {
      setState(() {
        _currentStep = AppStep.finalQuestionnaire;
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

  void _handleFinalQuestionnaireSubmit(
    Map<String, dynamic> answers,
  ) {
    setState(() {
      _finalQuestionnaire
        ..clear()
        ..addAll(answers);
      _currentStep = AppStep.demographics;
    });

    debugPrint(
      'Abschlussfragebogen gespeichert: $_finalQuestionnaire',
    );
  }

  void _handleDemographicsSubmit(Map<String, dynamic> demographics) {
    setState(() {
      _demographics
        ..clear()
        ..addAll(demographics);
      _currentStep = AppStep.studyComplete;
    });

    debugPrint('Demografische Daten gespeichert: $_demographics');
  }

  Future<bool> _exportData() async {
    if (_isExporting) {
      return false;
    }

    final sessionInfo = _sessionInfo;

    if (sessionInfo == null) {
      return false;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      final documentId = await _firestoreService.saveStudyRun(
        participantId: sessionInfo.participantId,
        deviceId: sessionInfo.deviceId,
        testerId: sessionInfo.testerId,
        appVersion: _appVersion,
        counterbalanceGroup: _counterbalanceGroup,
        conditionOrder: _conditionOrder,
        decisions: _decisions,
        subjectiveRatings: _subjectiveRatings,
        conditionTimings: _conditionTimings,
        finalQuestionnaire:
            Map<String, dynamic>.from(_finalQuestionnaire),
        demographics: Map<String, dynamic>.from(_demographics),
      );

      debugPrint('Studienlauf gespeichert: $documentId');
      return true;
    } catch (error) {
      debugPrint('Fehler beim Speichern: $error');
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
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
        return StartScreen(onStartStudy: _startStudy);

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
          onContinue: _openSubjectiveRating,
        );

      case AppStep.subjectiveRating:
        return SubjectiveRatingScreen(
          key: ValueKey('rating_${_currentCondition.id}'),
          questions: _currentRatingQuestions,
          onSubmit: _handleRatingSubmit,
        );

      case AppStep.finalQuestionnaire:
        return FinalQuestionnaireScreen(
          key: ValueKey(
            'final_questionnaire_${_sessionInfo?.participantId ?? 'unknown'}',
          ),
          onSubmit: _handleFinalQuestionnaireSubmit,
        );

      case AppStep.demographics:
        return DemographicsScreen(
          key: ValueKey('demographics_${_sessionInfo?.participantId ?? 'unknown'}'),
          onSubmit: _handleDemographicsSubmit,
        );

      case AppStep.studyComplete:
        return StudyCompleteScreen(
          key: ValueKey('complete_${_sessionInfo?.participantId ?? 'unknown'}'),
          participantId: _sessionInfo?.participantId ?? 'unknown',
          totalConditions: _totalConditions,
          onSave: _exportData,
        );
    }
  }
}