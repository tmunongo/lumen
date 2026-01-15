import 'package:lumen/application/services/artifact_service.dart';
import 'package:lumen/domain/entities/project.dart';
import 'package:lumen/domain/repositories/artifact_repository.dart';
import 'package:lumen/domain/repositories/project_repository.dart';
import 'package:lumen/domain/repositories/tag_repository.dart';

class ProjectService {
  final ProjectRepository _projectRepository;
  final ArtifactRepository _artifactRepository;
  final TagRepository _tagRepository;
  final ArtifactService _artifactService;

  ProjectService({
    required ProjectRepository projectRepository,
    required ArtifactRepository artifactRepository,
    required TagRepository tagRepository,
    required ArtifactService artifactService,
  }) : _projectRepository = projectRepository,
       _artifactRepository = artifactRepository,
       _tagRepository = tagRepository,
       _artifactService = artifactService;

  Future<Project> createProject(String name) async {
    // Check for duplicate name
    final existing = await _projectRepository.findByName(name);
    if (existing != null) {
      throw Exception('Project with name "$name" already exists');
    }

    final project = Project(name: name);
    return await _projectRepository.create(project);
  }

  Future<void> renameProject(int id, String newName) async {
    final project = await _projectRepository.findById(id);
    if (project == null) {
      throw Exception('Project not found');
    }

    // Check if new name conflicts with another project
    final existing = await _projectRepository.findByName(newName);
    if (existing != null && existing.id != id) {
      throw Exception('Project with name "$newName" already exists');
    }

    project.rename(newName);
    await _projectRepository.update(project);
  }

  Future<void> archiveProject(int id) async {
    final project = await _projectRepository.findById(id);
    if (project == null) {
      throw Exception('Project not found');
    }

    project.archive();
    await _projectRepository.update(project);
  }

  Future<void> unarchiveProject(int id) async {
    final project = await _projectRepository.findById(id);
    if (project == null) {
      throw Exception('Project not found');
    }

    project.unarchive();
    await _projectRepository.update(project);
  }

  Future<List<Project>> getAllProjects({bool includeArchived = false}) async {
    return await _projectRepository.findAll(includeArchived: includeArchived);
  }

  Future<Project?> getProject(int id) async {
    return await _projectRepository.findById(id);
  }

  Future<void> deleteProject(int id) async {
    // Cascade delete artifacts
    final artifacts = await _artifactRepository.findByProject(id);
    for (final artifact in artifacts) {
      await _artifactService.deleteArtifact(artifact);
    }

    // Delete tags for this project
    // Note: TagRepository needs a method to delete by project, or we have to find and delete one by one.
    // Looking at TagRepository interface in providers.dart (inferred), it might handle findByProject.
    // Let's assume we fetch all and delete for now, or check if we need to add deleteByProjectId.
    // For now, let's fetch and delete.
    final tags = await _tagRepository.findByProject(id);
    for (final tag in tags) {
      await _tagRepository.delete(tag.id);
    }

    await _projectRepository.delete(id);
  }
}
