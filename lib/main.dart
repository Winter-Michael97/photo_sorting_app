import 'package:flutter/material.dart';
import 'package:photo_sorting_app/screens/condition_intro_screen.dart';

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
      home: ConditionIntroScreen(
        conditionNumber: '1/4',
        title: 'test',
        description: 'test ',
        instructions: ['test'],
        onStart: () {},
      ),

      /*StartScreen(
        onStartStudy: (participantId) {
          debugPrint('Study started for participant: $participantId');
        },*/
    );
  }
}
