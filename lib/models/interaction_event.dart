class InteractionEventDraft {
  final String eventType;
  final DateTime timestamp;

  final String? photoId;
  final String? seriesId;

  final int? presentationIndex;
  final int? seriesIndex;
  final int? roundNumber;
  final int? positionInRound;
  final int? gridPosition;

  final String? action;
  final String? previousAction;
  final String? previousPhotoId;

  final int? durationMs;
  final int? visibleDurationMs;

  final String? expectedAction;
  final bool? isBestInSeries;

  const InteractionEventDraft({
    required this.eventType,
    required this.timestamp,
    this.photoId,
    this.seriesId,
    this.presentationIndex,
    this.seriesIndex,
    this.roundNumber,
    this.positionInRound,
    this.gridPosition,
    this.action,
    this.previousAction,
    this.previousPhotoId,
    this.durationMs,
    this.visibleDurationMs,
    this.expectedAction,
    this.isBestInSeries,
  });
}

class InteractionEvent {
  final int sequence;
  final String participantId;
  final String conditionId;
  final String interfaceType;
  final String taskType;
  final String eventType;
  final DateTime timestamp;

  final String? photoId;
  final String? seriesId;
  final String? difficulty;

  final int? presentationIndex;
  final int? seriesIndex;
  final int? roundNumber;
  final int? positionInRound;
  final int? gridPosition;

  final String? action;
  final String? previousAction;
  final String? previousPhotoId;

  final int? durationMs;
  final int? visibleDurationMs;

  final String? expectedAction;
  final bool? isBestInSeries;

  const InteractionEvent({
    required this.sequence,
    required this.participantId,
    required this.conditionId,
    required this.interfaceType,
    required this.taskType,
    required this.eventType,
    required this.timestamp,
    this.photoId,
    this.seriesId,
    this.difficulty,
    this.presentationIndex,
    this.seriesIndex,
    this.roundNumber,
    this.positionInRound,
    this.gridPosition,
    this.action,
    this.previousAction,
    this.previousPhotoId,
    this.durationMs,
    this.visibleDurationMs,
    this.expectedAction,
    this.isBestInSeries,
  });

  Map<String, dynamic> toFirestoreMap() {
    return {
      'sequence': sequence,
      'participantId': participantId,
      'conditionId': conditionId,
      'interfaceType': interfaceType,
      'taskType': taskType,
      'eventType': eventType,
      'timestamp': timestamp,
      if (photoId != null) 'photoId': photoId,
      if (seriesId != null) 'seriesId': seriesId,
      if (difficulty != null) 'difficulty': difficulty,
      if (presentationIndex != null) 'presentationIndex': presentationIndex,
      if (seriesIndex != null) 'seriesIndex': seriesIndex,
      if (roundNumber != null) 'roundNumber': roundNumber,
      if (positionInRound != null) 'positionInRound': positionInRound,
      if (gridPosition != null) 'gridPosition': gridPosition,
      if (action != null) 'action': action,
      if (previousAction != null) 'previousAction': previousAction,
      if (previousPhotoId != null) 'previousPhotoId': previousPhotoId,
      if (durationMs != null) 'durationMs': durationMs,
      if (visibleDurationMs != null) 'visibleDurationMs': visibleDurationMs,
      if (expectedAction != null) 'expectedAction': expectedAction,
      if (isBestInSeries != null) 'isBestInSeries': isBestInSeries,
    };
  }
}
