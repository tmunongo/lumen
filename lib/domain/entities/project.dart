import 'package:isar/isar.dart';

part 'project.g.dart';

@collection
class Project {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;

  DateTime? createdAt;
  DateTime? modifiedAt;

  bool isArchived = false;

  Project({required this.name, DateTime? createdAt, DateTime? modifiedAt})
    : createdAt = createdAt ?? DateTime.now(),
      modifiedAt = modifiedAt ?? DateTime.now() {
    _validateName(name);
  }

  void rename(String newName) {
    _validateName(newName);
    name = newName;
    touch();
  }

  void archive() {
    isArchived = true;
    touch();
  }

  void unarchive() {
    isArchived = false;
    touch();
  }

  void touch() {
    modifiedAt = DateTime.now();
  }

  static void _validateName(String name) {
    if (name.trim().isEmpty) {
      throw ArgumentError('Project name cannot be empty');
    }
    if (name.length > 200) {
      throw ArgumentError('Project name cannot exceed 200 characters');
    }
  }
}
