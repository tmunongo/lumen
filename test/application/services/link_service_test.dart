import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/application/services/link_service.dart';
import 'package:lumen/domain/entities/artifact.dart';
import 'package:lumen/domain/entities/artifact_link.dart';
import 'package:lumen/domain/repositories/artifact_repository.dart';
import 'package:lumen/domain/repositories/link_repository.dart';

// Mock implementations for testing
class MockLinkRepository implements LinkRepository {
  final Map<int, ArtifactLink> _links = {};
  int _nextId = 1;

  @override
  Future<ArtifactLink> create(ArtifactLink link) async {
    link.id = _nextId++;
    _links[link.id] = link;
    return link;
  }

  @override
  Future<void> delete(int id) async {
    _links.remove(id);
  }

  @override
  Future<List<ArtifactLink>> findOutgoingLinks(int artifactId) async {
    return _links.values
        .where((link) => link.sourceArtifactId == artifactId)
        .toList();
  }

  @override
  Future<List<ArtifactLink>> findIncomingLinks(int artifactId) async {
    return _links.values
        .where((link) => link.targetArtifactId == artifactId)
        .toList();
  }

  @override
  Future<List<ArtifactLink>> findByProject(int projectId) async {
    return _links.values
        .where((link) => link.projectId == projectId)
        .toList();
  }

  @override
  Future<bool> linkExists(int sourceId, int targetId) async {
    return _links.values.any(
      (link) =>
          link.sourceArtifactId == sourceId && link.targetArtifactId == targetId,
    );
  }

  @override
  Future<ArtifactLink?> findLink(int sourceId, int targetId) async {
    try {
      return _links.values.firstWhere(
        (link) =>
            link.sourceArtifactId == sourceId &&
            link.targetArtifactId == targetId,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> deleteAllForArtifact(int artifactId) async {
    _links.removeWhere((_, link) =>
        link.sourceArtifactId == artifactId ||
        link.targetArtifactId == artifactId);
  }
}

class MockArtifactRepository implements ArtifactRepository {
  final Map<int, Artifact> _artifacts = {};

  void addArtifact(Artifact artifact) {
    _artifacts[artifact.id] = artifact;
  }

  @override
  Future<Artifact> create(Artifact artifact) async {
    _artifacts[artifact.id] = artifact;
    return artifact;
  }

  @override
  Future<void> delete(int id) async {
    _artifacts.remove(id);
  }

  @override
  Future<Artifact?> findById(int id) async {
    return _artifacts[id];
  }

  @override
  Future<List<Artifact>> findByProject(int projectId) async {
    return _artifacts.values
        .where((a) => a.projectId == projectId)
        .toList();
  }

  @override
  Future<List<Artifact>> findByTag(int projectId, String tag) async {
    return _artifacts.values
        .where((a) => a.projectId == projectId && a.tags.contains(tag))
        .toList();
  }

  @override
  Future<List<Artifact>> findByTags(int projectId, List<String> tags) async {
    return _artifacts.values
        .where((a) =>
            a.projectId == projectId &&
            a.tags.any((t) => tags.contains(t)))
        .toList();
  }

  @override
  Future<void> update(Artifact artifact) async {
    _artifacts[artifact.id] = artifact;
  }
}

void main() {
  late LinkService linkService;
  late MockLinkRepository mockLinkRepo;
  late MockArtifactRepository mockArtifactRepo;

  setUp(() {
    mockLinkRepo = MockLinkRepository();
    mockArtifactRepo = MockArtifactRepository();
    linkService = LinkService(
      linkRepository: mockLinkRepo,
      artifactRepository: mockArtifactRepo,
    );
  });

  group('LinkService', () {
    test('creates link between artifacts', () async {
      final link = await linkService.createLink(1, 2, 1);

      expect(link, isNotNull);
      expect(link!.sourceArtifactId, 1);
      expect(link.targetArtifactId, 2);
      expect(link.projectId, 1);
    });

    test('prevents duplicate links', () async {
      await linkService.createLink(1, 2, 1);
      final duplicate = await linkService.createLink(1, 2, 1);

      expect(duplicate, isNull);
    });

    test('prevents self-linking', () async {
      expect(
        () => linkService.createLink(1, 1, 1),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('removes link between artifacts', () async {
      await linkService.createLink(1, 2, 1);
      await linkService.removeLink(1, 2);

      final exists = await mockLinkRepo.linkExists(1, 2);
      expect(exists, false);
    });

    test('gets outgoing linked artifacts', () async {
      final artifact1 = Artifact(
        projectId: 1,
        type: ArtifactType.note,
        title: 'Artifact 1',
      );
      artifact1.id = 1;

      final artifact2 = Artifact(
        projectId: 1,
        type: ArtifactType.note,
        title: 'Artifact 2',
      );
      artifact2.id = 2;

      mockArtifactRepo.addArtifact(artifact1);
      mockArtifactRepo.addArtifact(artifact2);

      await linkService.createLink(1, 2, 1);
      final linked = await linkService.getOutgoingLinkedArtifacts(1);

      expect(linked.length, 1);
      expect(linked.first.id, 2);
    });

    test('gets backlinks (incoming links)', () async {
      final artifact1 = Artifact(
        projectId: 1,
        type: ArtifactType.note,
        title: 'Artifact 1',
      );
      artifact1.id = 1;

      final artifact2 = Artifact(
        projectId: 1,
        type: ArtifactType.note,
        title: 'Artifact 2',
      );
      artifact2.id = 2;

      mockArtifactRepo.addArtifact(artifact1);
      mockArtifactRepo.addArtifact(artifact2);

      await linkService.createLink(1, 2, 1);
      final backlinks = await linkService.getBacklinks(2);

      expect(backlinks.length, 1);
      expect(backlinks.first.id, 1);
    });

    test('checks if artifacts are linked', () async {
      await linkService.createLink(1, 2, 1);

      expect(await linkService.areLinked(1, 2), true);
      // areLinked checks BOTH directions so 2,1 should NOT be true unless there's a link 2->1
      // Since we only created 1->2, let's check the logic:
      // The linkService.areLinked checks linkExists(1,2) OR linkExists(2,1)
      // linkExists only returns true if that exact direction exists
      expect(await linkService.areLinked(2, 1), true); // areLinked checks both directions
      expect(await linkService.areLinked(1, 3), false);
    });

    test('deletes all links for artifact', () async {
      await linkService.createLink(1, 2, 1);
      await linkService.createLink(3, 1, 1);

      await linkService.deleteAllLinksForArtifact(1);

      final outgoing = await mockLinkRepo.findOutgoingLinks(1);
      final incoming = await mockLinkRepo.findIncomingLinks(1);

      expect(outgoing.length, 0);
      expect(incoming.length, 0);
    });

    test('creates link with optional note', () async {
      final link = await linkService.createLink(
        1,
        2,
        1,
        note: 'Reference for context',
      );

      expect(link, isNotNull);
      expect(link!.note, 'Reference for context');
    });
  });
}
