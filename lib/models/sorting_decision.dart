enum SortingAction {
  keep,
  discard,
}

class SortingDecision {
  final String participantId;
  final String conditionId;
  final String photoId;
  final SortingAction action;
  final DateTime timestamp;

  const SortingDecision({
    required this.participantId,
    required this.conditionId,
    required this.photoId,
    required this.action,
    required this.timestamp,
  });

  String toCsvRow() {
    return '$participantId,$conditionId,$photoId,${action.name},${timestamp.toIso8601String()}';
  }
}