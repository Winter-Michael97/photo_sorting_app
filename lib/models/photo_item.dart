import 'sorting_decision.dart';

class PhotoItem {
  final String id;
  final String assetPath;

  // Für Kategorie A: erwartete richtige Entscheidung.
  final SortingAction? expectedAction;

  // Später für Kategorie B / Fotoserien.
  final String? seriesId;
  final bool isBestInSeries;

  const PhotoItem({
    required this.id,
    required this.assetPath,
    this.expectedAction,
    this.seriesId,
    this.isBestInSeries = false,
  });
}