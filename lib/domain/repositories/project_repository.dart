import 'package:lumen/domain/entities/project.dart';

abstract class ProjectRepository {
  Future<Project> create(Project project);
  Future<Project?> findById(int id);
  Future<Project?> findByName(String name);
  Future<List<Project>> findAll({bool includeArchived = false});
  Future<void> update(Project project);
  Future<void> delete(int id);
}
