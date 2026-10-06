import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/condition_timing.dart';
import '../models/interaction_event.dart';
import '../models/photo_item.dart';
import '../models/sorting_decision.dart';
import '../models/study_condition.dart';

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
    required String deviceModel,
    required String testerId,
    required String appVersion,
    required int counterbalanceGroup,
    required List<StudyCondition> conditionOrder,
    required List<SortingDecision> decisions,
    required List<InteractionEvent> interactionEvents,
    required Map<String, Map<String, int>> subjectiveRatings,
    required List<ConditionTiming> conditionTimings,
    required Map<String, dynamic> finalQuestionnaire,
    required Map<String, dynamic> demographics,
    required bool consentAccepted,
    required DateTime consentAcceptedAt,
    required String consentVersion,
  }) async {
    final docRef = await _firestore.collection('study_runs').add({
      'participantId': participantId,
      'deviceId': deviceId,
      'deviceModel': deviceModel,
      'testerId': testerId,
      'appVersion': appVersion,
      'counterbalanceGroup': counterbalanceGroup,
      'finalQuestionnaire': finalQuestionnaire,
      'demographics': demographics,

      'consent': {
        'accepted': consentAccepted,
        'acceptedAt': Timestamp.fromDate(consentAcceptedAt),
        'version': consentVersion,
        'method': 'in_app_checkbox',
      },

      'createdAt': FieldValue.serverTimestamp(),

      // Speichert nicht nur die vier Conditions, sondern auch die tatsächlich
      // randomisierte Foto-/Serienreihenfolge dieses konkreten Durchlaufs.
      'conditionOrder': conditionOrder.map(_buildConditionSnapshot).toList(),

      'decisions': decisions.map((decision) {
        final map = decision.toFirestoreMap();
        map['timestamp'] = Timestamp.fromDate(decision.timestamp);
        return map;
      }).toList(),

      // Detailliertes Präsentations- und Interaktionslogging.
      'interactionEvents': interactionEvents.map((event) {
        final map = event.toFirestoreMap();
        map['timestamp'] = Timestamp.fromDate(event.timestamp);
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

  Map<String, dynamic> _buildConditionSnapshot(StudyCondition condition) {
    final snapshot = <String, dynamic>{
      'conditionId': condition.id,
      'interfaceType': condition.interfaceType.name,
      'taskType': condition.taskType.name,
      'title': condition.title,
      'photoSetId': _getPhotoSetId(condition),
      'photoOrder': condition.photos.map((photo) => photo.id).toList(),
    };

    if (condition.taskType.name == 'independent') {
      snapshot['expectedActions'] = {
        for (final photo in condition.photos)
          photo.id: photo.expectedAction?.name,
      };
    }

    if (condition.taskType.name == 'series') {
      final grouped = <String, List<PhotoItem>>{};

      for (final photo in condition.photos) {
        final seriesId = photo.seriesId;

        if (seriesId == null) {
          continue;
        }

        grouped.putIfAbsent(seriesId, () => <PhotoItem>[]);
        grouped[seriesId]!.add(photo);
      }

      snapshot['seriesOrder'] = grouped.keys.toList();
      snapshot['seriesMetadata'] = grouped.entries.map((entry) {
        final seriesId = entry.key;
        final photos = entry.value;
        String? groundTruthPhotoId;

        for (final photo in photos) {
          if (photo.isBestInSeries) {
            groundTruthPhotoId = photo.id;
            break;
          }
        }

        return {
          'seriesId': seriesId,
          'difficulty': _difficultyFromSeriesId(seriesId),
          'photoOrder': photos.map((photo) => photo.id).toList(),
          'groundTruthPhotoId': groundTruthPhotoId,
        };
      }).toList();
    }

    return snapshot;
  }

  String? _difficultyFromSeriesId(String seriesId) {
    if (seriesId.contains('_e_')) {
      return 'easy';
    }

    if (seriesId.contains('_h_')) {
      return 'hard';
    }

    return null;
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
