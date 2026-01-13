import 'package:isar/isar.dart';

part 'artifact.g.dart';

enum ArtifactType { webPage, rawLink, note, quote, image }

@collection
class Artifact {
  Id id = Isar.autoIncrement;

  @Index()
  late int projectId;

  @Enumerated(EnumType.name)
  late ArtifactType type;

  late String title;

  /// For webPage: cleaned HTML content
  /// For note: markdown text
  /// For quote: excerpt text
  /// For rawLink: empty until fetched
  /// For image: file path or base64
  String? content;

  /// Original URL for webPage and rawLink
  String? sourceUrl;

  /// For quote artifacts
  String? attribution;

  /// Local file path for downloaded assets
  String? localAssetPath;

  DateTime? createdAt;
  DateTime? modifiedAt;

  /// Denormalized tag names for query performance
  List<String> tags = [];

  bool isFetched = false;

  Artifact({
    required this.projectId,
    required this.type,
    required this.title,
    this.content,
    this.sourceUrl,
    this.attribution,
    this.localAssetPath,
    DateTime? createdAt,
    DateTime? modifiedAt,
    List<String> tags = const [],
  }) : createdAt = createdAt ?? DateTime.now(),
       modifiedAt = modifiedAt ?? DateTime.now(),
       tags = List.from(tags) {
    _validate();
  }

  void updateContent(String newContent) {
    content = newContent;
    touch();
  }

  void markFetched({required String cleanedContent, String? assetPath}) {
    if (type != ArtifactType.rawLink && type != ArtifactType.webPage) {
      throw StateError(
        'Only rawLink and webPage artifacts can be marked as fetched',
      );
    }
    content = cleanedContent;
    localAssetPath = assetPath;
    isFetched = true;
    if (type == ArtifactType.rawLink) {
      type = ArtifactType.webPage;
    }
    touch();
  }

  void addTag(String tag) {
    final normalized = _normalizeTag(tag);
    if (!tags.contains(normalized)) {
      tags.add(normalized);
      touch();
    }
  }

  void removeTag(String tag) {
    final normalized = _normalizeTag(tag);
    if (tags.remove(normalized)) {
      touch();
    }
  }

  void setTags(List<String> newTags) {
    tags = newTags.map(_normalizeTag).toSet().toList();
    touch();
  }

  void touch() {
    modifiedAt = DateTime.now();
  }

  static String _normalizeTag(String tag) {
    final trimmed = tag.trim().toLowerCase();
    if (trimmed.isEmpty) {
      throw ArgumentError('Tag cannot be empty');
    }
    if (trimmed.length > 50) {
      throw ArgumentError('Tag cannot exceed 50 characters');
    }
    return trimmed;
  }

  void _validate() {
    if (title.trim().isEmpty) {
      throw ArgumentError('Artifact title cannot be empty');
    }
    if (type == ArtifactType.quote && attribution == null) {
      throw ArgumentError('Quote artifacts must have attribution');
    }
    if ((type == ArtifactType.rawLink || type == ArtifactType.webPage) &&
        sourceUrl == null) {
      throw ArgumentError('Link artifacts must have sourceUrl');
    }
  }
}
