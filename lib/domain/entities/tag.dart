import 'package:isar/isar.dart';

part 'tag.g.dart';

@collection
class Tag {
  Id id = Isar.autoIncrement;

  @Index()
  late int projectId;

  @Index(unique: true, composite: [CompositeIndex('projectId')])
  late String name;

  DateTime? createdAt;

  int usageCount = 0;

  Tag({
    required this.projectId,
    required String name,
    DateTime? createdAt,
    this.usageCount = 0,
  }) : name = _normalizeName(name),
       createdAt = createdAt ?? DateTime.now();

  void incrementUsage() {
    usageCount++;
  }

  void decrementUsage() {
    if (usageCount > 0) {
      usageCount--;
    }
  }

  static String _normalizeName(String name) {
    final trimmed = name.trim().toLowerCase();
    if (trimmed.isEmpty) {
      throw ArgumentError('Tag name cannot be empty');
    }
    if (trimmed.length > 50) {
      throw ArgumentError('Tag name cannot exceed 50 characters');
    }
    return trimmed;
  }
}
