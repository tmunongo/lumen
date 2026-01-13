import 'package:lumen/domain/entities/project.dart';
import 'package:lumen/domain/repositories/project_repository.dart';

class ProjectService {
  final ProjectRepository _repository;

  ProjectService(this._repository);

  Future<Project> createProject(String name) async {
    // Check for duplicate name
    final existing = await _repository.findByName(name);
    if (existing != null) {
      throw Exception('Project with name "$name" already exists');
    }

    final project = Project(name: name);
    return await _repository.create(project);
  }

  Future<void> renameProject(int id, String newName) async {
    final project = await _repository.findById(id);
    if (project == null) {
      throw Exception('Project not found');
    }

    // Check if new name conflicts with another project
    final existing = await _repository.findByName(newName);
    if (existing != null && existing.id != id) {
      throw Exception('Project with name "$newName" already exists');
    }

    project.rename(newName);
    await _repository.update(project);
  }

  Future<void> archiveProject(int id) async {
    final project = await _repository.findById(id);
    if (project == null) {
      throw Exception('Project not found');
    }

    project.archive();
    await _repository.update(project);
  }

  Future<void> unarchiveProject(int id) async {
    final project = await _repository.findById(id);
    if (project == null) {
      throw Exception('Project not found');
    }

    project.unarchive();
    await _repository.update(project);
  }

  Future<List<Project>> getAllProjects({bool includeArchived = false}) async {
    return await _repository.findAll(includeArchived: includeArchived);
  }

  Future<Project?> getProject(int id) async {
    return await _repository.findById(id);
  }

  Future<void> deleteProject(int id) async {
    // Note: In production, you'd want to cascade delete artifacts and tags
    await _repository.delete(id);
  }
}
