import 'package:lumen/domain/entities/markdown_document.dart';

/// Repository interface for markdown document persistence.
///
/// This repository handles file-based storage of markdown documents,
/// unlike other repositories that use Isar database.
abstract class MarkdownRepository {
  /// Create a new markdown document
  Future<MarkdownDocument> create(MarkdownDocument document);

  /// Find a document by its ID
  Future<MarkdownDocument?> findById(String id);

  /// Find all documents for a project
  Future<List<MarkdownDocument>> findByProject(int projectId);

  /// Find all documents for a project by slug
  Future<List<MarkdownDocument>> findByProjectSlug(String projectSlug);

  /// Update an existing document (saves content to file)
  Future<MarkdownDocument> update(MarkdownDocument document);

  /// Delete a document
  Future<void> delete(String id);

  /// Delete all documents for a project
  Future<void> deleteByProject(int projectId);

  /// Delete all documents for a project by slug
  Future<void> deleteByProjectSlug(String projectSlug);

  /// Check if a filename exists in a project
  Future<bool> filenameExists(String projectSlug, String filename);
}
