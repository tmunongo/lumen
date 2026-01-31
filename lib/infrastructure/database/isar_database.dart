import 'package:isar/isar.dart';
import 'package:lumen/domain/entities/artifact.dart';
import 'package:lumen/domain/entities/artifact_highlight.dart';
import 'package:lumen/domain/entities/artifact_link.dart';
import 'package:lumen/domain/entities/project.dart';
import 'package:lumen/domain/entities/tag.dart';
import 'package:path_provider/path_provider.dart';

class IsarDatabase {
  static Isar? _instance;

  static Future<Isar> getInstance() async {
    if (_instance != null) return _instance!;

    // Use getApplicationSupportDirectory for platform-specific data storage
    // Linux: ~/.local/share/lumen/
    // macOS: ~/Library/Application Support/lumen/
    // Windows: %APPDATA%\lumen\
    final dir = await getApplicationSupportDirectory();

    _instance = await Isar.open(
      [
        ProjectSchema,
        ArtifactSchema,
        TagSchema,
        ArtifactLinkSchema,
        ArtifactHighlightSchema,
      ],
      directory: dir.path,
      name: 'lumen-space',
    );

    return _instance!;
  }
}
