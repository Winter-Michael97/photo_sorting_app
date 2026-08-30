import '../models/photo_item.dart';
import '../models/sorting_decision.dart';
import '../models/study_condition.dart';

const List<PhotoItem> swipeIndependentPhotos = [
  PhotoItem(
    id: 'swipe_photo_01',
    assetPath: 'assets/test_images/photo_01.jpg',
    expectedAction: SortingAction.keep,
  ),
  PhotoItem(
    id: 'swipe_photo_02',
    assetPath: 'assets/test_images/photo_01.jpg',
    expectedAction: SortingAction.discard,
  ),
  PhotoItem(
    id: 'swipe_photo_03',
    assetPath: 'assets/test_images/photo_01.jpg',
    expectedAction: SortingAction.keep,
  ),
  PhotoItem(
    id: 'swipe_photo_04',
    assetPath: 'assets/test_images/photo_01.jpg',
    expectedAction: SortingAction.discard,
  ),
  PhotoItem(
    id: 'swipe_photo_05',
    assetPath: 'assets/test_images/photo_01.jpg',
    expectedAction: SortingAction.keep,
  ),
];

const List<PhotoItem> gridIndependentPhotos = [
  PhotoItem(
    id: 'grid_photo_01',
    assetPath: 'assets/test_images/photo_01.jpg',
    expectedAction: SortingAction.keep,
  ),
  PhotoItem(
    id: 'grid_photo_02',
    assetPath: 'assets/test_images/photo_01.jpg',
    expectedAction: SortingAction.discard,
  ),
  PhotoItem(
    id: 'grid_photo_03',
    assetPath: 'assets/test_images/photo_01.jpg',
    expectedAction: SortingAction.keep,
  ),
  PhotoItem(
    id: 'grid_photo_04',
    assetPath: 'assets/test_images/photo_01.jpg',
    expectedAction: SortingAction.discard,
  ),
  PhotoItem(
    id: 'grid_photo_05',
    assetPath: 'assets/test_images/photo_01.jpg',
    expectedAction: SortingAction.keep,
  ),
  PhotoItem(
    id: 'grid_photo_06',
    assetPath: 'assets/test_images/photo_01.jpg',
    expectedAction: SortingAction.discard,
  ),
];

const List<PhotoItem> seriesPlaceholderPhotos = [
  PhotoItem(
    id: 'series_01_01',
    assetPath: 'assets/test_images/series/series_01_01.jpg',
    seriesId: 'series_01',
    isBestInSeries: false,
  ),
  PhotoItem(
    id: 'series_01_02',
    assetPath: 'assets/test_images/series/series_01_02.jpg',
    seriesId: 'series_01',
    isBestInSeries: false,
  ),
  PhotoItem(
    id: 'series_01_03',
    assetPath: 'assets/test_images/series/series_01_03.jpg',
    seriesId: 'series_01',
    isBestInSeries: true,
  ),
  PhotoItem(
    id: 'series_01_04',
    assetPath: 'assets/test_images/series/series_01_04.jpg',
    seriesId: 'series_01',
    isBestInSeries: false,
  ),
  PhotoItem(
    id: 'series_01_05',
    assetPath: 'assets/test_images/series/series_01_05.jpg',
    seriesId: 'series_01',
    isBestInSeries: false,
  ),
  PhotoItem(
    id: 'series_01_06',
    assetPath: 'assets/test_images/series/series_01_06.jpg',
    seriesId: 'series_01',
    isBestInSeries: false,
  ),
];

const List<StudyCondition> studyConditions = [
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
    photos: swipeIndependentPhotos,
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
    photos: gridIndependentPhotos,
  ),

  StudyCondition(
    id: 'SB',
    interfaceType: InterfaceType.swipe,
    taskType: TaskType.series,
    title: 'Swipe: Fotoserie',
    description:
        'In dieser Aufgabe vergleichst du mehrere ähnliche Fotos nacheinander. Ziel ist es, aus der Serie genau ein bestes Foto auszuwählen.',
    instructions: [
      'Das erste Foto ist automatisch der aktuelle Favorit.',
      'Swipe nach links = aktuelles Vergleichsfoto aussortieren.',
      'Swipe nach rechts = aktuelles Vergleichsfoto wird neuer Favorit.',
      'Am Ende bleibt genau ein Favorit übrig.',
    ],
    photos: seriesPlaceholderPhotos,
  ),

  StudyCondition(
    id: 'RB',
    interfaceType: InterfaceType.grid,
    taskType: TaskType.series,
    title: 'Raster: Fotoserie',
    description:
        'In dieser Aufgabe siehst du mehrere ähnliche Fotos gleichzeitig. Ziel ist es, aus der Serie genau ein bestes Foto auszuwählen.',
    instructions: [
      'Tippe auf das Foto, das du für das beste Foto der Serie hältst.',
      'Es kann immer nur ein Foto ausgewählt sein.',
      'Du kannst deine Auswahl ändern, bevor du bestätigst.',
      'Bestätige deine Auswahl, um zur nächsten Serie zu gelangen.',
    ],
    photos: seriesPlaceholderPhotos,
  ),
];