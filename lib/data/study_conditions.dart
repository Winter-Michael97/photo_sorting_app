import '../models/photo_item.dart';
import '../models/sorting_decision.dart';
import '../models/study_condition.dart';

List<PhotoItem> _buildIndependentPhotos({
  required String folder,
  required String prefix,
}) {
  return List.generate(20, (index) {
    final number = index + 1;
    final numberStr = number.toString().padLeft(2, '0');

    return PhotoItem(
      id: '${prefix}_$numberStr',
      assetPath: 'assets/test_images/$folder/${prefix}_$numberStr.jpg',
      expectedAction: number <= 10
          ? SortingAction.keep
          : SortingAction.discard,
    );
  });
}

List<PhotoItem> _buildSeriesPhotos({
  required String folder,
  required String prefix,
}) {
  final photos = <PhotoItem>[];

  for (int series = 1; series <= 6; series++) {
    final seriesStr = series.toString().padLeft(2, '0');
    final seriesId = '${prefix}_s$seriesStr';

    for (int photo = 1; photo <= 5; photo++) {
      final photoStr = photo.toString().padLeft(2, '0');

      photos.add(
        PhotoItem(
          id: '${prefix}_s${seriesStr}_$photoStr',
          assetPath:
              'assets/test_images/$folder/${prefix}_s${seriesStr}_$photoStr.jpg',
          seriesId: seriesId,
          isBestInSeries: photo == 3,
        ),
      );
    }
  }

  return photos;
}

final List<PhotoItem> clearA1Photos = _buildIndependentPhotos(
  folder: 'clear_a1',
  prefix: 'a1',
);

final List<PhotoItem> clearA2Photos = _buildIndependentPhotos(
  folder: 'clear_a2',
  prefix: 'a2',
);

final List<PhotoItem> seriesB1Photos = _buildSeriesPhotos(
  folder: 'series_b1',
  prefix: 'b1',
);

final List<PhotoItem> seriesB2Photos = _buildSeriesPhotos(
  folder: 'series_b2',
  prefix: 'b2',
);

final List<StudyCondition> studyConditions = [
  StudyCondition(
    id: 'SA',
    interfaceType: InterfaceType.swipe,
    taskType: TaskType.independent,
    title: 'Swipe: Einzelfotos',
    description:
        'In dieser Aufgabe bewertest du Fotos nacheinander. Entscheide für jedes Foto, ob es behalten oder aussortiert werden soll.',
    instructions: [
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
        'In dieser Aufgabe bewertest du mehrere Fotos in einer Rasteransicht. Entscheide für jedes Foto, ob es behalten oder aussortiert werden soll.',
    instructions: [
      'Bewerte jedes Foto im Raster.',
      'Markiere pro Foto, ob es behalten oder aussortiert werden soll.',
      'Du kannst erst fortfahren, wenn alle Fotos bewertet wurden.',
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
        'In dieser Aufgabe vergleichst du mehrere ähnliche Fotos nacheinander. Ziel ist es, aus jeder Serie genau ein bestes Foto auszuwählen.',
    instructions: [
      'Das erste Foto ist automatisch der aktuelle Favorit.',
      'Swipe nach links = aktuelles Vergleichsfoto aussortieren.',
      'Swipe nach rechts = aktuelles Vergleichsfoto wird neuer Favorit.',
      'Am Ende bleibt pro Serie genau ein Favorit übrig.',
    ],
    photos: seriesB1Photos,
  ),
  StudyCondition(
    id: 'RB',
    interfaceType: InterfaceType.grid,
    taskType: TaskType.series,
    title: 'Raster: Fotoserie',
    description:
        'In dieser Aufgabe siehst du mehrere ähnliche Fotos gleichzeitig. Ziel ist es, aus jeder Serie genau ein bestes Foto auszuwählen.',
    instructions: [
      'Tippe auf das Foto, das du für das beste Foto der Serie hältst.',
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