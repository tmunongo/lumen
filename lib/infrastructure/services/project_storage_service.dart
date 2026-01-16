import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Manifest data stored in each project's manifest.json
class ProjectManifest {
  final int projectId;
  final String projectName;
  final String slug;
  final DateTime createdAt;
  final List<ManifestArtifact> artifacts;
  final List<String> markdownFiles;

  ProjectManifest({
    required this.projectId,
    required this.projectName,
    required this.slug,
    required this.createdAt,
    this.artifacts = const [],
    this.markdownFiles = const [],
  });

  Map<String, dynamic> toJson() => {
    'projectId': projectId,
    'projectName': projectName,
    'slug': slug,
    'createdAt': createdAt.toIso8601String(),
    'artifacts': artifacts.map((a) => a.toJson()).toList(),
    'markdownFiles': markdownFiles,
  };

  factory ProjectManifest.fromJson(Map<String, dynamic> json) {
    return ProjectManifest(
      projectId: json['projectId'] as int,
      projectName: json['projectName'] as String,
      slug: json['slug'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      artifacts:
          (json['artifacts'] as List<dynamic>?)
              ?.map((a) => ManifestArtifact.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      markdownFiles:
          (json['markdownFiles'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  ProjectManifest copyWith({
    int? projectId,
    String? projectName,
    String? slug,
    DateTime? createdAt,
    List<ManifestArtifact>? artifacts,
    List<String>? markdownFiles,
  }) {
    return ProjectManifest(
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      slug: slug ?? this.slug,
      createdAt: createdAt ?? this.createdAt,
      artifacts: artifacts ?? this.artifacts,
      markdownFiles: markdownFiles ?? this.markdownFiles,
    );
  }
}

/// An artifact entry in the project manifest
class ManifestArtifact {
  final String id;
  final String type;
  final String title;
  final String? url;
  final String? base64Data;
  final DateTime savedAt;

  ManifestArtifact({
    required this.id,
    required this.type,
    required this.title,
    this.url,
    this.base64Data,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'title': title,
    if (url != null) 'url': url,
    if (base64Data != null) 'base64': base64Data,
    'savedAt': savedAt.toIso8601String(),
  };

  factory ManifestArtifact.fromJson(Map<String, dynamic> json) {
    return ManifestArtifact(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      url: json['url'] as String?,
      base64Data: json['base64'] as String?,
      savedAt: DateTime.parse(json['savedAt'] as String),
    );
  }
}

/// Service for managing project directories and file storage.
///
/// Handles the file system structure for projects:
/// - ~/.config/lumen/ (Linux) or AppData/lumen/ (Windows)
///   - project-slug-1/
///     - manifest.json
///     - document1.md
///     - document2.md
///   - project-slug-2/
///     - manifest.json
///     - notes.md
class ProjectStorageService {
  static const String _appDirName = 'lumen';
  static const String _manifestFileName = 'manifest.json';

  Directory? _cachedStorageDir;

  /// Get the base storage directory
  Future<Directory> getStorageDirectory() async {
    if (_cachedStorageDir != null) {
      return _cachedStorageDir!;
    }

    Directory baseDir;

    if (Platform.isLinux) {
      // Use ~/.config/lumen
      final home = Platform.environment['HOME'] ?? '/home';
      baseDir = Directory(p.join(home, '.config', _appDirName));
    } else if (Platform.isWindows) {
      // Use AppData\Roaming\lumen
      final appData =
          Platform.environment['APPDATA'] ??
          Platform.environment['USERPROFILE']!;
      baseDir = Directory(p.join(appData, _appDirName));
    } else if (Platform.isMacOS) {
      // Use ~/Library/Application Support/lumen
      final home = Platform.environment['HOME'] ?? '/Users';
      baseDir = Directory(
        p.join(home, 'Library', 'Application Support', _appDirName),
      );
    } else {
      // Fallback to application documents directory
      final docsDir = await getApplicationDocumentsDirectory();
      baseDir = Directory(p.join(docsDir.path, _appDirName));
    }

    if (!await baseDir.exists()) {
      await baseDir.create(recursive: true);
    }

    _cachedStorageDir = baseDir;
    return baseDir;
  }

  /// Get or create a project's directory
  Future<Directory> getProjectDirectory(String projectSlug) async {
    final storageDir = await getStorageDirectory();
    final projectDir = Directory(p.join(storageDir.path, projectSlug));

    if (!await projectDir.exists()) {
      await projectDir.create(recursive: true);
    }

    return projectDir;
  }

  /// Slugify a project name for use as a directory name
  String slugify(String projectName) {
    return projectName
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^\w\s-]'), '') // Remove special chars
        .replaceAll(
          RegExp(r'[\s_]+'),
          '-',
        ) // Replace spaces/underscores with dash
        .replaceAll(RegExp(r'-+'), '-') // Collapse multiple dashes
        .replaceAll(RegExp(r'^-+|-+$'), ''); // Trim leading/trailing dashes
  }

  /// Get the manifest file path for a project
  Future<File> _getManifestFile(String projectSlug) async {
    final projectDir = await getProjectDirectory(projectSlug);
    return File(p.join(projectDir.path, _manifestFileName));
  }

  /// Read the project manifest JSON
  Future<ProjectManifest?> getManifest(String projectSlug) async {
    final file = await _getManifestFile(projectSlug);

    if (!await file.exists()) {
      return null;
    }

    try {
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      return ProjectManifest.fromJson(json);
    } catch (e) {
      // Corrupted manifest, return null
      return null;
    }
  }

  /// Update or create the project manifest
  Future<void> updateManifest(
    String projectSlug,
    ProjectManifest manifest,
  ) async {
    final file = await _getManifestFile(projectSlug);
    final jsonString = const JsonEncoder.withIndent(
      '  ',
    ).convert(manifest.toJson());
    await file.writeAsString(jsonString);
  }

  /// Create initial manifest for a project
  Future<void> createManifest({
    required int projectId,
    required String projectName,
    required String projectSlug,
  }) async {
    final manifest = ProjectManifest(
      projectId: projectId,
      projectName: projectName,
      slug: projectSlug,
      createdAt: DateTime.now(),
    );
    await updateManifest(projectSlug, manifest);
  }

  /// Add a markdown file to the manifest
  Future<void> addMarkdownToManifest(
    String projectSlug,
    String filename,
  ) async {
    var manifest = await getManifest(projectSlug);
    if (manifest == null) {
      throw Exception('Project manifest not found: $projectSlug');
    }

    if (!manifest.markdownFiles.contains(filename)) {
      manifest = manifest.copyWith(
        markdownFiles: [...manifest.markdownFiles, filename],
      );
      await updateManifest(projectSlug, manifest);
    }
  }

  /// Remove a markdown file from the manifest
  Future<void> removeMarkdownFromManifest(
    String projectSlug,
    String filename,
  ) async {
    var manifest = await getManifest(projectSlug);
    if (manifest == null) return;

    if (manifest.markdownFiles.contains(filename)) {
      manifest = manifest.copyWith(
        markdownFiles: manifest.markdownFiles
            .where((f) => f != filename)
            .toList(),
      );
      await updateManifest(projectSlug, manifest);
    }
  }

  /// Get the file path for a markdown document
  Future<File> getMarkdownFile(String projectSlug, String filename) async {
    final projectDir = await getProjectDirectory(projectSlug);
    return File(p.join(projectDir.path, filename));
  }

  /// Read a markdown file's content
  Future<String?> readMarkdownFile(String projectSlug, String filename) async {
    final file = await getMarkdownFile(projectSlug, filename);
    if (!await file.exists()) {
      return null;
    }
    return await file.readAsString();
  }

  /// Write content to a markdown file
  Future<void> writeMarkdownFile(
    String projectSlug,
    String filename,
    String content,
  ) async {
    final file = await getMarkdownFile(projectSlug, filename);
    await file.writeAsString(content);
  }

  /// Delete a markdown file
  Future<void> deleteMarkdownFile(String projectSlug, String filename) async {
    final file = await getMarkdownFile(projectSlug, filename);
    if (await file.exists()) {
      await file.delete();
    }
    await removeMarkdownFromManifest(projectSlug, filename);
  }

  /// Delete an entire project directory
  Future<void> deleteProjectDirectory(String projectSlug) async {
    final storageDir = await getStorageDirectory();
    final projectDir = Directory(p.join(storageDir.path, projectSlug));

    if (await projectDir.exists()) {
      await projectDir.delete(recursive: true);
    }
  }

  /// Check if a project directory exists
  Future<bool> projectDirectoryExists(String projectSlug) async {
    final storageDir = await getStorageDirectory();
    final projectDir = Directory(p.join(storageDir.path, projectSlug));
    return await projectDir.exists();
  }

  /// List all project directories
  Future<List<String>> listProjectSlugs() async {
    final storageDir = await getStorageDirectory();
    final entities = await storageDir.list().toList();

    return entities
        .whereType<Directory>()
        .map((d) => p.basename(d.path))
        .where((name) => !name.startsWith('.')) // Exclude hidden dirs
        .toList();
  }
}
