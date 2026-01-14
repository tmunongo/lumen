import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:lumen/domain/entities/artifact.dart';
import 'package:lumen/domain/entities/tag.dart';
import 'package:lumen/domain/repositories/artifact_repository.dart';
import 'package:lumen/domain/repositories/tag_repository.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ArtifactService {
  final ArtifactRepository _artifactRepository;
  final TagRepository _tagRepository;

  ArtifactService({
    required ArtifactRepository artifactRepository,
    required TagRepository tagRepository,
  }) : _artifactRepository = artifactRepository,
       _tagRepository = tagRepository;

  Future<Artifact> createNote({
    required int projectId,
    required String title,
    required String content,
    List<String>? tags,
  }) async {
    final artifact = Artifact(
      projectId: projectId,
      type: ArtifactType.note,
      title: title,
      content: content,
      tags: tags ?? [],
    );

    await _artifactRepository.create(artifact);
    await _updateTagUsage(projectId, tags ?? []);

    return artifact;
  }

  Future<Artifact> createQuote({
    required int projectId,
    required String title,
    required String content,
    required String attribution,
    String? sourceUrl,
    List<String>? tags,
  }) async {
    final artifact = Artifact(
      projectId: projectId,
      type: ArtifactType.quote,
      title: title,
      content: content,
      attribution: attribution,
      sourceUrl: sourceUrl,
      tags: tags ?? [],
    );

    await _artifactRepository.create(artifact);
    await _updateTagUsage(projectId, tags ?? []);

    return artifact;
  }

  Future<Artifact> createImageFromFile({
    required int projectId,
    required String title,
    required File imageFile,
    List<String>? tags,
  }) async {
    // Save image to app directory with hash-based name
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(path.join(appDir.path, 'images'));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    // Generate unique filename based on content hash
    final bytes = await imageFile.readAsBytes();
    final hash = sha256.convert(bytes).toString();
    final extension = path.extension(imageFile.path);
    final localPath = path.join(imagesDir.path, '$hash$extension');

    // Copy file if it doesn't exist
    final localFile = File(localPath);
    if (!await localFile.exists()) {
      await imageFile.copy(localPath);
    }

    final artifact = Artifact(
      projectId: projectId,
      type: ArtifactType.image,
      title: title,
      localAssetPath: localPath,
      tags: tags ?? [],
    );

    await _artifactRepository.create(artifact);
    await _updateTagUsage(projectId, tags ?? []);

    return artifact;
  }

  Future<void> updateArtifact({
    required Artifact artifact,
    String? newTitle,
    String? newContent,
    String? newAttribution,
    List<String>? newTags,
  }) async {
    final oldTags = Set<String>.from(artifact.tags);

    if (newTitle != null) {
      artifact.title = newTitle;
    }

    if (newContent != null) {
      artifact.updateContent(newContent);
    }

    if (newAttribution != null && artifact.type == ArtifactType.quote) {
      artifact.attribution = newAttribution;
    }

    if (newTags != null) {
      artifact.setTags(newTags);

      // Update tag usage counts
      final addedTags = newTags.toSet().difference(oldTags);
      final removedTags = oldTags.difference(newTags.toSet());

      await _incrementTagUsage(artifact.projectId, addedTags.toList());
      await _decrementTagUsage(artifact.projectId, removedTags.toList());
    }

    await _artifactRepository.update(artifact);
  }

  Future<void> deleteArtifact(Artifact artifact) async {
    // Decrement tag usage
    await _decrementTagUsage(artifact.projectId, artifact.tags);

    // Delete local image file if exists
    if (artifact.localAssetPath != null) {
      final file = File(artifact.localAssetPath!);
      if (await file.exists()) {
        await file.delete();
      }
    }

    await _artifactRepository.delete(artifact.id);
  }

  Future<void> addTagsToArtifact(Artifact artifact, List<String> tags) async {
    final newTags = tags.where((tag) => !artifact.tags.contains(tag)).toList();

    for (final tag in newTags) {
      artifact.addTag(tag);
    }

    await _artifactRepository.update(artifact);
    await _incrementTagUsage(artifact.projectId, newTags);
  }

  Future<void> removeTagFromArtifact(Artifact artifact, String tag) async {
    artifact.removeTag(tag);
    await _artifactRepository.update(artifact);
    await _decrementTagUsage(artifact.projectId, [tag]);
  }

  Future<void> _updateTagUsage(int projectId, List<String> tags) async {
    await _incrementTagUsage(projectId, tags);
  }

  Future<void> _incrementTagUsage(int projectId, List<String> tags) async {
    for (final tagName in tags) {
      final normalized = tagName.trim().toLowerCase();
      if (normalized.isEmpty) continue;

      var tag = await _tagRepository.findByName(projectId, normalized);
      if (tag == null) {
        tag = Tag(projectId: projectId, name: normalized);
        await _tagRepository.create(tag);
      } else {
        tag.incrementUsage();
        await _tagRepository.update(tag);
      }
    }
  }

  Future<void> _decrementTagUsage(int projectId, List<String> tags) async {
    for (final tagName in tags) {
      final normalized = tagName.trim().toLowerCase();
      if (normalized.isEmpty) continue;

      final tag = await _tagRepository.findByName(projectId, normalized);
      if (tag != null) {
        tag.decrementUsage();

        if (tag.usageCount <= 0) {
          // Optionally delete unused tags
          await _tagRepository.delete(tag.id);
        } else {
          await _tagRepository.update(tag);
        }
      }
    }
  }
}
