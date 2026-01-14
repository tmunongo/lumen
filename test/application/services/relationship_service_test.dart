import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/application/services/relationship_service.dart';
import 'package:lumen/domain/entities/artifact.dart';

void main() {
  late RelationshipService service;

  setUp(() {
    service = RelationshipService();
  });

  group('RelationshipService', () {
    test('finds relationships with shared tags', () {
      final artifacts = [
        Artifact(
          projectId: 1,
          type: ArtifactType.note,
          title: 'A',
          tags: ['ai', 'ml', 'python'],
        ),
        Artifact(
          projectId: 1,
          type: ArtifactType.note,
          title: 'B',
          tags: ['ai', 'ml'],
        ),
        Artifact(
          projectId: 1,
          type: ArtifactType.note,
          title: 'C',
          tags: ['rust', 'systems'],
        ),
      ];

      final cluster = service.findRelatedArtifacts(artifacts[0], artifacts);

      expect(cluster.totalRelated, 1); // Only B is related
      expect(cluster.relationships.first.target.title, 'B');
      expect(cluster.relationships.first.sharedTags, {'ai', 'ml'});
    });

    test('calculates relationship strength correctly', () {
      final source = Artifact(
        projectId: 1,
        type: ArtifactType.note,
        title: 'Source',
        tags: ['a', 'b', 'c'],
      );

      final target = Artifact(
        projectId: 1,
        type: ArtifactType.note,
        title: 'Target',
        tags: ['a', 'b', 'c'],
      );

      final artifacts = [source, target];
      final cluster = service.findRelatedArtifacts(source, artifacts);

      // Perfect overlap: 3 shared / 3 total = 1.0
      expect(cluster.relationships.first.strength, 1.0);
      expect(cluster.relationships.first.isStrong, true);
    });

    test('calculates partial overlap correctly', () {
      final source = Artifact(
        projectId: 1,
        type: ArtifactType.note,
        title: 'Source',
        tags: ['a', 'b'],
      );

      final target = Artifact(
        projectId: 1,
        type: ArtifactType.note,
        title: 'Target',
        tags: ['b', 'c'],
      );

      final artifacts = [source, target];
      final cluster = service.findRelatedArtifacts(source, artifacts);

      // 1 shared / 3 total = 0.33...
      expect(cluster.relationships.first.strength, closeTo(0.33, 0.01));
      expect(cluster.relationships.first.isMedium, true);
    });

    test('excludes artifacts with no shared tags', () {
      final artifacts = [
        Artifact(
          projectId: 1,
          type: ArtifactType.note,
          title: 'A',
          tags: ['ai'],
        ),
        Artifact(
          projectId: 1,
          type: ArtifactType.note,
          title: 'B',
          tags: ['rust'],
        ),
      ];

      final cluster = service.findRelatedArtifacts(artifacts[0], artifacts);

      expect(cluster.totalRelated, 0);
    });

    test('excludes the source artifact itself', () {
      final artifact = Artifact(
        projectId: 1,
        type: ArtifactType.note,
        title: 'Self',
        tags: ['tag'],
      );

      final cluster = service.findRelatedArtifacts(artifact, [artifact]);

      expect(cluster.totalRelated, 0);
    });

    test('sorts relationships by strength descending', () {
      final source = Artifact(
        projectId: 1,
        type: ArtifactType.note,
        title: 'Source',
        tags: ['a', 'b', 'c'],
      );

      final artifacts = [
        source,
        Artifact(
          projectId: 1,
          type: ArtifactType.note,
          title: 'Strong',
          tags: ['a', 'b', 'c'],
        ),
        Artifact(
          projectId: 1,
          type: ArtifactType.note,
          title: 'Medium',
          tags: ['a', 'b'],
        ),
        Artifact(
          projectId: 1,
          type: ArtifactType.note,
          title: 'Weak',
          tags: ['a'],
        ),
      ];

      final cluster = service.findRelatedArtifacts(source, artifacts);

      expect(cluster.relationships[0].target.title, 'Strong');
      expect(cluster.relationships[1].target.title, 'Medium');
      expect(cluster.relationships[2].target.title, 'Weak');
    });

    test('finds all connected artifacts transitively', () {
      final artifacts = [
        Artifact(
          projectId: 1,
          type: ArtifactType.note,
          title: 'A',
          tags: ['x', 'y'],
        ),
        Artifact(
          projectId: 1,
          type: ArtifactType.note,
          title: 'B',
          tags: ['y', 'z'],
        ),
        Artifact(
          projectId: 1,
          type: ArtifactType.note,
          title: 'C',
          tags: ['z', 'w'],
        ),
        Artifact(
          projectId: 1,
          type: ArtifactType.note,
          title: 'D',
          tags: ['unrelated'],
        ),
      ];

      final network = service.findConnectedNetwork(artifacts[0], artifacts);

      // A connects to B, B connects to C
      expect(network.length, 3); // A, B, C
      expect(network.any((a) => a.title == 'D'), false);
    });

    test('finds tag co-occurrence patterns', () {
      final artifacts = [
        Artifact(
          projectId: 1,
          type: ArtifactType.note,
          title: '1',
          tags: ['ai', 'ml'],
        ),
        Artifact(
          projectId: 1,
          type: ArtifactType.note,
          title: '2',
          tags: ['ai', 'ml', 'python'],
        ),
        Artifact(
          projectId: 1,
          type: ArtifactType.note,
          title: '3',
          tags: ['ai', 'ethics'],
        ),
      ];

      final cooccurrence = service.analyzeTagCooccurrence(artifacts);

      expect(cooccurrence['ai']!['ml'], 2); // ai and ml appear together twice
      expect(cooccurrence['ai']!['python'], 1);
      expect(cooccurrence['ai']!['ethics'], 1);
    });
  });
}
