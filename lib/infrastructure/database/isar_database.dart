import 'package:isar/isar.dart';
import 'package:lumen/domain/entities/artifact.dart';
import 'package:lumen/domain/entities/artifact_link.dart';
import 'package:lumen/domain/entities/project.dart';
import 'package:lumen/domain/entities/tag.dart';
import 'package:path_provider/path_provider.dart';

class IsarDatabase {
  static Isar? _instance;

  static Future<Isar> getInstance() async {
    if (_instance != null) return _instance!;

    final dir = await getApplicationDocumentsDirectory();

    _instance = await Isar.open(
      [ProjectSchema, ArtifactSchema, TagSchema, ArtifactLinkSchema],
      directory: dir.path,
      name: 'research_workspace',
    );

    return _instance!;
  }

  static Future<void> close() async {
    await _instance?.close();
    _instance = null;
  }
}
