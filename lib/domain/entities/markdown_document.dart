/// A markdown document stored as a file in the project directory.
///
/// Unlike other artifacts that are stored in the Isar database,
/// MarkdownDocuments are stored as .md files on the filesystem for
/// easy Git integration and portability.
class MarkdownDocument {
  /// Unique identifier (UUID)
  final String id;

  /// The project's ID this document belongs to
  final int projectId;

  /// Slugified project name used as directory name
  final String projectSlug;

  /// The filename (e.g., "my-notes.md")
  final String filename;

  /// Display title for the document
  String title;

  /// The markdown content
  String content;

  /// When the document was created
  final DateTime createdAt;

  /// When the document was last modified
  DateTime modifiedAt;

  /// Tags associated with this document
  List<String> tags;

  /// Whether the document has unsaved changes
  bool isDirty;

  MarkdownDocument({
    required this.id,
    required this.projectId,
    required this.projectSlug,
    required this.filename,
    required this.title,
    this.content = '',
    DateTime? createdAt,
    DateTime? modifiedAt,
    List<String>? tags,
    this.isDirty = false,
  }) : createdAt = createdAt ?? DateTime.now(),
       modifiedAt = modifiedAt ?? DateTime.now(),
       tags = tags ?? [];

  /// Get the relative file path within the storage directory
  String get filePath => '$projectSlug/$filename';

  /// Update content and mark as dirty
  void updateContent(String newContent) {
    if (content != newContent) {
      content = newContent;
      isDirty = true;
      modifiedAt = DateTime.now();
    }
  }

  /// Update title and mark as dirty
  void updateTitle(String newTitle) {
    if (title != newTitle) {
      title = newTitle;
      isDirty = true;
      modifiedAt = DateTime.now();
    }
  }

  /// Mark document as saved
  void markSaved() {
    isDirty = false;
  }

  /// Add a tag
  void addTag(String tag) {
    final normalized = tag.trim().toLowerCase();
    if (normalized.isNotEmpty && !tags.contains(normalized)) {
      tags.add(normalized);
      isDirty = true;
    }
  }

  /// Remove a tag
  void removeTag(String tag) {
    final normalized = tag.trim().toLowerCase();
    if (tags.remove(normalized)) {
      isDirty = true;
    }
  }

  /// Convert to JSON for manifest storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'projectSlug': projectSlug,
      'filename': filename,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'tags': tags,
    };
  }

  /// Create from JSON
  factory MarkdownDocument.fromJson(Map<String, dynamic> json) {
    return MarkdownDocument(
      id: json['id'] as String,
      projectId: json['projectId'] as int,
      projectSlug: json['projectSlug'] as String,
      filename: json['filename'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  /// Create a copy with optional overrides
  MarkdownDocument copyWith({
    String? id,
    int? projectId,
    String? projectSlug,
    String? filename,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? modifiedAt,
    List<String>? tags,
    bool? isDirty,
  }) {
    return MarkdownDocument(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      projectSlug: projectSlug ?? this.projectSlug,
      filename: filename ?? this.filename,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      tags: tags ?? List.from(this.tags),
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  String toString() {
    return 'MarkdownDocument(id: $id, title: $title, filename: $filename)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MarkdownDocument && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
