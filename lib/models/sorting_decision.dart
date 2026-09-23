enum SortingAction {
  keep,
  discard,
}

class SortingDecision {
  final String participantId;
  final String conditionId;

  final String interfaceType; // swipe oder grid
  final String taskType; // independent oder series

  final String photoId;
  final String? seriesId;

  final SortingAction action;

  final SortingAction? expectedAction; // nur Kategorie A
  final bool? isBestInSeries; // nur Kategorie B
  final bool? isCorrect;

  final DateTime timestamp;

  const SortingDecision({
    required this.participantId,
    required this.conditionId,
    required this.interfaceType,
    required this.taskType,
    required this.photoId,
    required this.action,
    required this.timestamp,
    this.seriesId,
    this.expectedAction,
    this.isBestInSeries,
    this.isCorrect,
  });

  Map<String, dynamic> toFirestoreMap() {
    return {
      'participantId': participantId,
      'conditionId': conditionId,
      'interfaceType': interfaceType,
      'taskType': taskType,
      'photoId': photoId,
      'seriesId': seriesId,
      'action': action.name,
      'expectedAction': expectedAction?.name,
      'isBestInSeries': isBestInSeries,
      'isCorrect': isCorrect,
      'timestamp': timestamp,
    };
  }

  String toCsvRow() {
    return [
      participantId,
      conditionId,
      interfaceType,
      taskType,
      seriesId ?? '',
      photoId,
      action.name,
      expectedAction?.name ?? '',
      isBestInSeries?.toString() ?? '',
      isCorrect?.toString() ?? '',
      timestamp.toIso8601String(),
    ].join(',');
  }
}