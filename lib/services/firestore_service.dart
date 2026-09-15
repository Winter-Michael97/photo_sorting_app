import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/sorting_decision.dart';
import '../models/study_condition.dart';
import '../models/condition_timing.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<String> getNextParticipantId() async {
    final counterRef = _firestore
        .collection('metadata')
        .doc('participant_counter');

    final participantNumber =
        await _firestore.runTransaction<int>((transaction) async {
      final snapshot = await transaction.get(counterRef);

      int currentNumber = 0;

      if (snapshot.exists) {
        final data = snapshot.data();

        if (data != null) {
          currentNumber = (data['lastNumber'] as num?)?.toInt() ?? 0;
        }
      }

      final nextNumber = currentNumber + 1;

      transaction.set(
        counterRef,
        {
          'lastNumber': nextNumber,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      return nextNumber;
    });

    return 'P${participantNumber.toString().padLeft(3, '0')}';
  }

  Future<String> saveStudyRun({
    required String participantId,
    required String deviceId,
    required String testerId,
    required String appVersion,
    required int counterbalanceGroup,
    required List<StudyCondition> conditionOrder,
    required List<SortingDecision> decisions,
    required Map<String, Map<String, int>> subjectiveRatings,
    required List<ConditionTiming> conditionTimings,
    required Map<String, dynamic> finalQuestionnaire,
    required Map<String, dynamic> demographics,
  }) async {
    final docRef = await _firestore.collection('study_runs').add({
      'participantId': participantId,
      'deviceId': deviceId,
      'testerId': testerId,
      'appVersion': appVersion,
      'counterbalanceGroup': counterbalanceGroup,
      'finalQuestionnaire': finalQuestionnaire,
      'demographics': demographics,
      'createdAt': FieldValue.serverTimestamp(),

      'conditionOrder': conditionOrder.map((condition) {
        return {
          'conditionId': condition.id,
          'interfaceType': condition.interfaceType.name,
          'taskType': condition.taskType.name,
          'title': condition.title,
          'photoSetId': _getPhotoSetId(condition),
        };
      }).toList(),

      'decisions': decisions.map((decision) {
        final map = decision.toFirestoreMap();

        map['timestamp'] = Timestamp.fromDate(decision.timestamp);

        return map;
      }).toList(),

      'conditionTimings': conditionTimings.map((timing) {
        final map = timing.toFirestoreMap();

        map['startedAt'] = Timestamp.fromDate(timing.startedAt);
        map['endedAt'] = Timestamp.fromDate(timing.endedAt);

        return map;
      }).toList(),

      'ratings': _buildRatingRows(
        participantId: participantId,
        conditionOrder: conditionOrder,
        subjectiveRatings: subjectiveRatings,
      ),
    });

    return docRef.id;
  }

  String? _getPhotoSetId(StudyCondition condition) {
    if (condition.photos.isEmpty) {
      return null;
    }

    final photoId = condition.photos.first.id;
    final separatorIndex = photoId.indexOf('_');

    if (separatorIndex == -1) {
      return photoId;
    }

    return photoId.substring(0, separatorIndex);
  }

  List<Map<String, dynamic>> _buildRatingRows({
    required String participantId,
    required List<StudyCondition> conditionOrder,
    required Map<String, Map<String, int>> subjectiveRatings,
  }) {
    final conditionLookup = {
      for (final condition in conditionOrder) condition.id: condition,
    };

    final rows = <Map<String, dynamic>>[];

    for (final conditionEntry in subjectiveRatings.entries) {
      final conditionId = conditionEntry.key;
      final answers = conditionEntry.value;
      final condition = conditionLookup[conditionId];

      for (final answerEntry in answers.entries) {
        rows.add({
          'participantId': participantId,
          'conditionId': conditionId,
          'interfaceType': condition?.interfaceType.name,
          'taskType': condition?.taskType.name,
          'questionId': answerEntry.key,
          'rating': answerEntry.value,
        });
      }
    }

    return rows;
  }
}
