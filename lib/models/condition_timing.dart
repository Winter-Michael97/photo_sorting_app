class ConditionTiming {
  final String conditionId;
  final String interfaceType;
  final String taskType;
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationMs;

  const ConditionTiming({
    required this.conditionId,
    required this.interfaceType,
    required this.taskType,
    required this.startedAt,
    required this.endedAt,
    required this.durationMs,
  });

  Map<String, dynamic> toFirestoreMap() {
    return {
      'conditionId': conditionId,
      'interfaceType': interfaceType,
      'taskType': taskType,
      'startedAt': startedAt,
      'endedAt': endedAt,
      'durationMs': durationMs,
    };
  }
}