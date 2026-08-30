import 'photo_item.dart';

enum InterfaceType {
  swipe,
  grid,
}

enum TaskType {
  independent,
  series,
}

class StudyCondition {
  final String id;
  final InterfaceType interfaceType;
  final TaskType taskType;
  final String title;
  final String description;
  final List<String> instructions;
  final List<PhotoItem> photos;

  const StudyCondition({
    required this.id,
    required this.interfaceType,
    required this.taskType,
    required this.title,
    required this.description,
    required this.instructions,
    required this.photos,
  });
}