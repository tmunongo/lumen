import 'dart:convert';
import 'dart:io';

import 'package:lumen/domain/entities/markdown_document.dart';
import 'package:lumen/domain/repositories/markdown_repository.dart';
import 'package:lumen/infrastructure/services/project_storage_service.dart';
import 'package:path/path.dart' as p;

/// File-based implementation of [MarkdownRepository].
///
/// Stores markdown documents as .md files in project directories,
/// with metadata stored in a .documents.json file in each project folder.
class FileMarkdownRepository implements MarkdownRepository {
  final ProjectStorageService _storageService;

  /// Filename for document metadata storage
  static const String _metadataFileName = '.documents.json';

  FileMarkdownRepository(this._storageService);

  /// Get the metadata file for a project
  Future<File> _getMetadataFile(String projectSlug) async {
    final projectDir = await _storageService.getProjectDirectory(projectSlug);
    return File(p.join(projectDir.path, _metadataFileName));
  }

  /// Read all document metadata for a project
  Future<Map<String, Map<String, dynamic>>> _readMetadata(
    String projectSlug,
  ) async {
    final file = await _getMetadataFile(projectSlug);

    if (!await file.exists()) {
      return {};
    }

    try {
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      return json.map(
        (key, value) => MapEntry(key, value as Map<String, dynamic>),
      );
    } catch (e) {
      return {};
    }
  }

  /// Write all document metadata for a project
  Future<void> _writeMetadata(
    String projectSlug,
    Map<String, Map<String, dynamic>> metadata,
  ) async {
    final file = await _getMetadataFile(projectSlug);
    final jsonString = const JsonEncoder.withIndent('  ').convert(metadata);
    await file.writeAsString(jsonString);
  }

  @override
  Future<MarkdownDocument> create(MarkdownDocument document) async {
    // Ensure project directory exists
    await _storageService.getProjectDirectory(document.projectSlug);

    // Write the markdown file
    await _storageService.writeMarkdownFile(
      document.projectSlug,
      document.filename,
      document.content,
    );

    // Update metadata
    final metadata = await _readMetadata(document.projectSlug);
    metadata[document.id] = document.toJson();
    await _writeMetadata(document.projectSlug, metadata);

    // Update manifest
    await _storageService.addMarkdownToManifest(
      document.projectSlug,
      document.filename,
    );

    return document.copyWith(isDirty: false);
  }

  @override
  Future<MarkdownDocument?> findById(String id) async {
    // We need to search all projects for this document
    final projectSlugs = await _storageService.listProjectSlugs();

    for (final slug in projectSlugs) {
      final metadata = await _readMetadata(slug);
      if (metadata.containsKey(id)) {
        final docMeta = metadata[id]!;
        final content = await _storageService.readMarkdownFile(
          slug,
          docMeta['filename'] as String,
        );

        final doc = MarkdownDocument.fromJson(docMeta);
        return doc.copyWith(content: content ?? '', isDirty: false);
      }
    }

    return null;
  }

  @override
  Future<List<MarkdownDocument>> findByProject(int projectId) async {
    // Search all project directories for matching projectId
    final projectSlugs = await _storageService.listProjectSlugs();
    final documents = <MarkdownDocument>[];

    for (final slug in projectSlugs) {
      final metadata = await _readMetadata(slug);

      for (final entry in metadata.entries) {
        final docMeta = entry.value;
        if (docMeta['projectId'] == projectId) {
          final content = await _storageService.readMarkdownFile(
            slug,
            docMeta['filename'] as String,
          );

          final doc = MarkdownDocument.fromJson(docMeta);
          documents.add(doc.copyWith(content: content ?? '', isDirty: false));
        }
      }
    }

    // Sort by modified date, most recent first
    documents.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    return documents;
  }

  @override
  Future<List<MarkdownDocument>> findByProjectSlug(String projectSlug) async {
    final metadata = await _readMetadata(projectSlug);
    final documents = <MarkdownDocument>[];

    for (final entry in metadata.entries) {
      final docMeta = entry.value;
      final content = await _storageService.readMarkdownFile(
        projectSlug,
        docMeta['filename'] as String,
      );

      final doc = MarkdownDocument.fromJson(docMeta);
      documents.add(doc.copyWith(content: content ?? '', isDirty: false));
    }

    // Sort by modified date, most recent first
    documents.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    return documents;
  }

  @override
  Future<MarkdownDocument> update(MarkdownDocument document) async {
    // Write the markdown file
    await _storageService.writeMarkdownFile(
      document.projectSlug,
      document.filename,
      document.content,
    );

    // Update metadata with new modified date
    final updatedDoc = document.copyWith(
      modifiedAt: DateTime.now(),
      isDirty: false,
    );

    final metadata = await _readMetadata(document.projectSlug);
    metadata[document.id] = updatedDoc.toJson();
    await _writeMetadata(document.projectSlug, metadata);

    return updatedDoc;
  }

  @override
  Future<void> delete(String id) async {
    // Find the document first
    final document = await findById(id);
    if (document == null) return;

    // Delete the file
    await _storageService.deleteMarkdownFile(
      document.projectSlug,
      document.filename,
    );

    // Remove from metadata
    final metadata = await _readMetadata(document.projectSlug);
    metadata.remove(id);
    await _writeMetadata(document.projectSlug, metadata);
  }

  @override
  Future<void> deleteByProject(int projectId) async {
    final documents = await findByProject(projectId);
    for (final doc in documents) {
      await delete(doc.id);
    }
  }

  @override
  Future<void> deleteByProjectSlug(String projectSlug) async {
    // This will delete the entire project directory
    await _storageService.deleteProjectDirectory(projectSlug);
  }

  @override
  Future<bool> filenameExists(String projectSlug, String filename) async {
    final file = await _storageService.getMarkdownFile(projectSlug, filename);
    return await file.exists();
  }
}
