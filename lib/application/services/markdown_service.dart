import 'dart:io';

import 'package:lumen/domain/entities/markdown_document.dart';
import 'package:lumen/domain/repositories/markdown_repository.dart';
import 'package:lumen/domain/repositories/project_repository.dart';
import 'package:lumen/infrastructure/services/project_storage_service.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

/// Service for managing markdown documents.
///
/// Handles business logic for creating, editing, and saving
/// markdown documents within projects.
class MarkdownService {
  final MarkdownRepository _repository;
  final ProjectStorageService _storageService;
  final ProjectRepository _projectRepository;
  final Uuid _uuid = const Uuid();

  MarkdownService({
    required MarkdownRepository repository,
    required ProjectStorageService storageService,
    required ProjectRepository projectRepository,
  }) : _repository = repository,
       _storageService = storageService,
       _projectRepository = projectRepository;

  /// Create a new markdown document in a project
  Future<MarkdownDocument> createDocument({
    required int projectId,
    required String title,
    String? initialContent,
  }) async {
    // Get project to determine slug
    final project = await _projectRepository.findById(projectId);
    if (project == null) {
      throw Exception('Project not found: $projectId');
    }

    final projectSlug = _storageService.slugify(project.name);

    // Ensure manifest exists
    final manifest = await _storageService.getManifest(projectSlug);
    if (manifest == null) {
      await _storageService.createManifest(
        projectId: projectId,
        projectName: project.name,
        projectSlug: projectSlug,
      );
    }

    // Generate unique filename
    final baseFilename = _slugifyFilename(title);
    var filename = '$baseFilename.md';
    var counter = 1;

    while (await _repository.filenameExists(projectSlug, filename)) {
      filename = '$baseFilename-$counter.md';
      counter++;
    }

    final document = MarkdownDocument(
      id: _uuid.v4(),
      projectId: projectId,
      projectSlug: projectSlug,
      filename: filename,
      title: title,
      content: initialContent ?? _getDefaultContent(title),
    );

    return await _repository.create(document);
  }

  /// Save a document (update existing)
  Future<MarkdownDocument> saveDocument(MarkdownDocument document) async {
    return await _repository.update(document);
  }

  /// Get all markdown documents for a project
  Future<List<MarkdownDocument>> getProjectDocuments(int projectId) async {
    return await _repository.findByProject(projectId);
  }

  /// Get a document by ID
  Future<MarkdownDocument?> getDocument(String id) async {
    return await _repository.findById(id);
  }

  /// Delete a document
  Future<void> deleteDocument(String id) async {
    await _repository.delete(id);
  }

  /// Delete all documents for a project
  Future<void> deleteProjectDocuments(int projectId) async {
    await _repository.deleteByProject(projectId);
  }

  /// Rename a document (updates title and potentially filename)
  Future<MarkdownDocument> renameDocument(
    MarkdownDocument document,
    String newTitle,
  ) async {
    // Update just the title, keep the same filename
    final updated = document.copyWith(
      title: newTitle,
      modifiedAt: DateTime.now(),
    );
    return await _repository.update(updated);
  }

  /// Get the project slug for a project
  Future<String> getProjectSlug(int projectId) async {
    final project = await _projectRepository.findById(projectId);
    if (project == null) {
      throw Exception('Project not found: $projectId');
    }
    return _storageService.slugify(project.name);
  }

  /// Slugify a title for use as filename
  String _slugifyFilename(String title) {
    return title
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'[\s_]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  /// Export a document to a specific path
  Future<void> exportToFile(
    MarkdownDocument document,
    String destinationPath,
  ) async {
    // Get the source file path
    final projectDir = await _storageService.getProjectDirectory(
      document.projectSlug,
    );
    final sourceFile = File(path.join(projectDir.path, document.filename));

    if (!await sourceFile.exists()) {
      throw Exception('Source file not found');
    }

    final destFile = File(destinationPath);
    await destFile.writeAsString(document.content);
  }

  /// Import a document from a file path
  Future<MarkdownDocument> importFromFile({
    required int projectId,
    required String filePath,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Import file not found');
    }

    final content = await file.readAsString();
    // Use filename as initial title, but clean it up
    final title = path.basenameWithoutExtension(filePath);

    return await createDocument(
      projectId: projectId,
      title: title,
      initialContent: content,
    );
  }

  /// Get default content for a new document
  String _getDefaultContent(String title) {
    return '''# $title

Start writing your notes here...
''';
  }
}
