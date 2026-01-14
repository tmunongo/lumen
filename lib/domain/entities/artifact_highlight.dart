import 'package:isar/isar.dart';

part 'artifact_highlight.g.dart';

@collection
class ArtifactHighlight {
  Id id = Isar.autoIncrement;

  @Index()
  late int artifactId;

  /// The text content that was selected/highlighted
  late String selectedText;

  /// Optional user note attached to the highlight
  String? note;

  /// Color/Style of the highlight (e.g. 'yellow', 'green', 'red')
  String style = 'yellow';

  DateTime? createdAt;

  ArtifactHighlight({
    required this.artifactId,
    required this.selectedText,
    this.note,
    this.style = 'yellow',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
