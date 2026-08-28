import 'package:flutter/material.dart';
import 'package:photo_sorting_app/screens/condition_complete_screen.dart';
import 'package:photo_sorting_app/screens/condition_intro_screen.dart';
import 'package:photo_sorting_app/screens/grid_independent_screen.dart';
import 'package:photo_sorting_app/screens/study_complete_screen.dart';
import 'package:photo_sorting_app/screens/swipe_independent_screen.dart';

import 'screens/start_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Triage Study',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: GridIndependentScreen(
        photos: const [
          GridPhotoItem(
            id: 'photo_01',
            assetPath: 'assets/test_images/photo_01.jpg',
          ),
          GridPhotoItem(
            id: 'photo_02',
            assetPath: 'assets/test_images/photo_01.jpg',
          ),
          GridPhotoItem(
            id: 'photo_03',
            assetPath: 'assets/test_images/photo_01.jpg',
          ),
          GridPhotoItem(
            id: 'photo_04',
            assetPath: 'assets/test_images/photo_01.jpg',
          ),
          GridPhotoItem(
            id: 'photo_05',
            assetPath: 'assets/test_images/photo_01.jpg',
          ),
          GridPhotoItem(
            id: 'photo_06',
            assetPath: 'assets/test_images/photo_01.jpg',
          ),
        ],

        onDecisionChanged: (photoId, previousDecision, newDecision) {
          debugPrint('$photoId: $previousDecision -> $newDecision');
        },

        onConfirm: (decisions) {
          debugPrint('RA bestätigt: $decisions');
        },
      ),

      /*StudyCompleteScreen(
        participantId: 'participantId',
        totalConditions: 4,
        onExport: onExport,
      ),*/

      /*ConditionCompleteScreen(
        completedCondition: 1,
        totalConditions: 4,
        onContinue: () {
          debugPrint('Weiter zur nächsten Condition');
        },
      ),*/

      /*SwipeIndependentScreen(
        photoId: 'photo_01',
        photoAssetPath: 'assets/test_images/photo_01.jpg',
        currentIndex: 1,
        totalCount: 5,

        onKeep: (photoId) {
          debugPrint('KEEP: $photoId');
        },

        onDiscard: (photoId) {
          debugPrint('DISCARD: $photoId');
        },

        onUndo: () {
          debugPrint('UNDO');
        },

        canUndo: true,
      ),
      */
      //conditionintroscreen
      /*
      ConditionIntroScreen(
        conditionNumber: '1/4',
        title: 'test',
        description: 'test ',
        instructions: ['test'],
        onStart: () {},
      ),*/

      //start screen
      /*StartScreen(
        onStartStudy: (participantId) {
          debugPrint('Study started for participant: $participantId');
        },*/
    );
  }

  //wichtig gür study abschluss screen
  void onExport() {
    print('exported data');
  }
}
