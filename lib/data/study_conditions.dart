import '../models/photo_item.dart';
import '../models/sorting_decision.dart';
import '../models/study_condition.dart';

List<PhotoItem> _buildIndependentPhotos({
  required String folder,
  required String prefix,
  required Set<int> keepNumbers,
}) {
  return List.generate(20, (index) {
    final number = index + 1;
    final numberStr = number.toString().padLeft(2, '0');

    return PhotoItem(
      id: '${prefix}_$numberStr',
      assetPath: 'assets/test_images/$folder/${prefix}_$numberStr.jpg',
      expectedAction: keepNumbers.contains(number)
          ? SortingAction.keep
          : SortingAction.discard,
    );
  });
}

List<PhotoItem> _buildSeriesPhotos({
  required String folder,
  required String prefix,
  required Map<int, int> bestPhotoBySeries,
}) {
  final photos = <PhotoItem>[];

  for (int series = 1; series <= 4; series++) {
    final seriesStr = series.toString().padLeft(2, '0');
    final seriesId = '${prefix}_s$seriesStr';
    final bestPhotoNumber = bestPhotoBySeries[series];

    if (bestPhotoNumber == null) {
      throw ArgumentError(
        'Keine Ground Truth für $prefix Serie $series definiert.',
      );
    }

    for (int photo = 1; photo <= 4; photo++) {
      final photoStr = photo.toString().padLeft(2, '0');

      photos.add(
        PhotoItem(
          id: '${prefix}_s${seriesStr}_$photoStr',
          assetPath:
              'assets/test_images/$folder/${prefix}_s${seriesStr}_$photoStr.jpg',
          seriesId: seriesId,
          isBestInSeries: photo == bestPhotoNumber,
        ),
      );
    }
  }

  return photos;
}

final List<PhotoItem> clearA1Photos = _buildIndependentPhotos(
  folder: 'clear_a1',
  prefix: 'a1',
  keepNumbers: {1, 4, 5, 7, 10, 12, 13, 15, 18, 19},
);

final List<PhotoItem> clearA2Photos = _buildIndependentPhotos(
  folder: 'clear_a2',
  prefix: 'a2',
  keepNumbers: {2, 3, 5, 8, 9, 11, 13, 16, 18, 19},
);

final List<PhotoItem> seriesB1EasyPhotos = _buildSeriesPhotos(
  folder: 'series_b1_easy',
  prefix: 'b1_e',
  bestPhotoBySeries: {1: 3, 2: 2, 3: 4, 4: 1},
);

final List<PhotoItem> seriesB1HardPhotos = _buildSeriesPhotos(
  folder: 'series_b1_hard',
  prefix: 'b1_h',
  bestPhotoBySeries: {1: 3, 2: 2, 3: 3, 4: 1},
);

final List<PhotoItem> seriesB2EasyPhotos = _buildSeriesPhotos(
  folder: 'series_b2_easy',
  prefix: 'b2_e',
  bestPhotoBySeries: {1: 4, 2: 1, 3: 3, 4: 4},
);

final List<PhotoItem> seriesB2HardPhotos = _buildSeriesPhotos(
  folder: 'series_b2_hard',
  prefix: 'b2_h',
  bestPhotoBySeries: {1: 2, 2: 3, 3: 2, 4: 1},
);

final List<PhotoItem> seriesB1Photos = [
  ...seriesB1EasyPhotos,
  ...seriesB1HardPhotos,
];

final List<PhotoItem> seriesB2Photos = [
  ...seriesB2EasyPhotos,
  ...seriesB2HardPhotos,
];

final List<StudyCondition> studyConditions = [
  StudyCondition(
    id: 'SA',
    interfaceType: InterfaceType.swipe,
    taskType: TaskType.independent,
    title: 'Swipe: Einzelfotos',
    description:
        'In dieser Aufgabe bewertest du Fotos nacheinander. Entscheide für jedes Foto, ob es aufgrund seiner sichtbaren Bildqualität behalten oder aussortiert werden sollte.',
    instructions: [
      'Bewerte die Fotos möglichst anhand ihrer sichtbaren Bildqualität und nicht danach, welches Motiv dir persönlich besser gefällt.',
      'Achte zum Beispiel auf Schärfe, Belichtung und erkennbare Bildfehler.',
      'Swipe nach links = Foto aussortieren.',
      'Swipe nach rechts = Foto behalten.',
      'Arbeite möglichst zügig, aber trotzdem sorgfältig.',
      'Es gibt in der Studienversion kein Undo.',
    ],
    photos: clearA1Photos,
  ),

  StudyCondition(
    id: 'RA',
    interfaceType: InterfaceType.grid,
    taskType: TaskType.independent,
    title: 'Raster: Einzelfotos',
    description:
        'In dieser Aufgabe bewertest du mehrere Fotos gleichzeitig in einer Rasteransicht. Wähle die Fotos aus, die aufgrund ihrer sichtbaren Bildqualität aussortiert werden sollten.',
    instructions: [
      'Bewerte die Fotos möglichst anhand ihrer sichtbaren Bildqualität und nicht danach, welches Motiv dir persönlich besser gefällt.',
      'Achte zum Beispiel auf Schärfe, Belichtung und erkennbare Bildfehler.',
      'Tippe auf ein Foto, um es zum Aussortieren auszuwählen.',
      'Tippe erneut auf ein ausgewähltes Foto, um die Auswahl zurückzunehmen.',
      'Nicht ausgewählte Fotos werden behalten.',
      'Bestätige unten deine Auswahl, wenn du fertig bist.',
      'Arbeite möglichst zügig, aber trotzdem sorgfältig.',
    ],
    photos: clearA2Photos,
  ),

  StudyCondition(
    id: 'SB',
    interfaceType: InterfaceType.swipe,
    taskType: TaskType.series,
    title: 'Swipe: Fotoserie',
    description:
        'In dieser Aufgabe vergleichst du mehrere ähnliche Fotos derselben Serie. Ziel ist es, anhand der sichtbaren Bildqualität genau ein bestes Foto auszuwählen.',
    instructions: [
      'Wähle das qualitativ beste Foto und nicht das Foto, dessen Motiv dir persönlich am besten gefällt.',
      'Achte zum Beispiel auf Schärfe, Belichtung und erkennbare Bildfehler.',
      'Swipe nach links = Foto aussortieren.',
      'Swipe nach rechts = Foto für die nächste Vergleichsrunde behalten.',
      'Bleiben mehrere Fotos übrig, vergleichst du diese erneut.',
      'Am Ende bleibt genau ein bestes Foto pro Serie übrig.',
    ],
    photos: seriesB1Photos,
  ),

  StudyCondition(
    id: 'RB',
    interfaceType: InterfaceType.grid,
    taskType: TaskType.series,
    title: 'Raster: Fotoserie',
    description:
        'In dieser Aufgabe siehst du mehrere ähnliche Fotos derselben Serie gleichzeitig. Ziel ist es, anhand der sichtbaren Bildqualität genau ein bestes Foto auszuwählen.',
    instructions: [
      'Wähle das qualitativ beste Foto und nicht das Foto, dessen Motiv dir persönlich am besten gefällt.',
      'Achte zum Beispiel auf Schärfe, Belichtung und erkennbare Bildfehler.',
      'Tippe auf das Foto, das du für das qualitativ beste Foto der Serie hältst.',
      'Es kann immer nur ein Foto ausgewählt sein.',
      'Du kannst deine Auswahl ändern, bevor du bestätigst.',
      'Bestätige deine Auswahl, um zur nächsten Serie zu gelangen.',
    ],
    photos: seriesB2Photos,
  ),
];

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

List<StudyCondition> buildCounterbalancedStudyConditions(int group) {
  final saBase = studyConditions.firstWhere((c) => c.id == 'SA');
  final raBase = studyConditions.firstWhere((c) => c.id == 'RA');
  final sbBase = studyConditions.firstWhere((c) => c.id == 'SB');
  final rbBase = studyConditions.firstWhere((c) => c.id == 'RB');

  // Gruppe 1 und 3:
  // Swipe bekommt A1/B1, Raster bekommt A2/B2
  //
  // Gruppe 2 und 4:
  // Swipe bekommt A2/B2, Raster bekommt A1/B1
  final bool normalSetAssignment = group == 1 || group == 3;

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
      return [
        sa,
        ra,
        rb,
        sb,
      ];

    case 2:
      return [
        ra,
        sb,
        sa,
        rb,
      ];

    case 3:
      return [
        sb,
        rb,
        ra,
        sa,
      ];

    case 4:
      return [
        rb,
        sa,
        sb,
        ra,
      ];

    default:
      return [
        sa,
        ra,
        rb,
        sb,
      ];
  }
}