import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/application/services/markdown_service.dart';
import 'package:lumen/domain/entities/markdown_document.dart';
import 'package:lumen/domain/entities/project.dart';
import 'package:lumen/domain/repositories/markdown_repository.dart';
import 'package:lumen/domain/repositories/project_repository.dart';
import 'package:lumen/infrastructure/services/project_storage_service.dart';
import 'package:mocktail/mocktail.dart';

class MockMarkdownRepository extends Mock implements MarkdownRepository {}

class MockProjectStorageService extends Mock implements ProjectStorageService {}

class MockProjectRepository extends Mock implements ProjectRepository {}

// Fake for return values
class FakeMarkdownDocument extends Fake implements MarkdownDocument {}

void main() {
  group('MarkdownService', () {
    late MockMarkdownRepository mockRepository;
    late MockProjectStorageService mockStorageService;
    late MockProjectRepository mockProjectRepository;
    late MarkdownService service;

    setUpAll(() {
      registerFallbackValue(FakeMarkdownDocument());
    });

    setUp(() {
      mockRepository = MockMarkdownRepository();
      mockStorageService = MockProjectStorageService();
      mockProjectRepository = MockProjectRepository();

      service = MarkdownService(
        repository: mockRepository,
        storageService: mockStorageService,
        projectRepository: mockProjectRepository,
      );
    });

    test(
      'createDocument creates manifest if missing, handles duplicates, and saves doc',
      () async {
        final projectId = 1;
        final project = Project(name: 'My Project')..id = projectId;
        final slug = 'my-project';
        final title = 'My Note';
        final baseFilename = 'my-note';

        // Mocks
        when(
          () => mockProjectRepository.findById(projectId),
        ).thenAnswer((_) async => project);

        when(() => mockStorageService.slugify('My Project')).thenReturn(slug);

        // Manifest missing first
        when(
          () => mockStorageService.getManifest(slug),
        ).thenAnswer((_) async => null);

        when(
          () => mockStorageService.createManifest(
            projectId: projectId,
            projectName: 'My Project',
            projectSlug: slug,
          ),
        ).thenAnswer((_) async {});

        // Filename collision
        when(
          () => mockRepository.filenameExists(slug, '$baseFilename.md'),
        ).thenAnswer((_) async => true); // collision
        when(
          () => mockRepository.filenameExists(slug, '$baseFilename-1.md'),
        ).thenAnswer((_) async => false); // no collision

        when(() => mockRepository.create(any())).thenAnswer(
          (invocation) async =>
              invocation.positionalArguments[0] as MarkdownDocument,
        );

        // Execute
        final result = await service.createDocument(
          projectId: projectId,
          title: title,
        );

        // Verify
        expect(result.title, title);
        expect(result.filename, '$baseFilename-1.md');
        expect(result.projectId, projectId);
        expect(result.projectSlug, slug);

        verify(
          () => mockStorageService.createManifest(
            projectId: projectId,
            projectName: 'My Project',
            projectSlug: slug,
          ),
        ).called(1);

        verify(
          () => mockRepository.filenameExists(slug, '$baseFilename.md'),
        ).called(1);
        verify(
          () => mockRepository.filenameExists(slug, '$baseFilename-1.md'),
        ).called(1);
        verify(() => mockRepository.create(any())).called(1);
      },
    );

    test('getProjectDocuments delegates to repository', () async {
      when(() => mockRepository.findByProject(1)).thenAnswer((_) async => []);

      await service.getProjectDocuments(1);

      verify(() => mockRepository.findByProject(1)).called(1);
    });

    test('renameDocument updates title and saves', () async {
      final doc = MarkdownDocument(
        id: '1',
        projectId: 1,
        projectSlug: 'slug',
        filename: 'file.md',
        title: 'Old',
      );

      when(() => mockRepository.update(any())).thenAnswer(
        (inv) async => inv.positionalArguments[0] as MarkdownDocument,
      );

      final result = await service.renameDocument(doc, 'New');

      expect(result.title, 'New');
      expect(result.filename, 'file.md'); // filename should not change
      expect(result.isDirty, false); // repository returns saved doc (clean)
      // it does copyWith. Wait, copyWith doesn't auto-set dirty unless specified
      // or logic in service does it?
      // Looking at service code:
      // final updated = document.copyWith(
      //   title: newTitle,
      //   modifiedAt: DateTime.now(),
      // );
      // return await _repository.update(updated);

      verify(
        () => mockRepository.update(
          any(
            that: isA<MarkdownDocument>().having(
              (d) => d.title,
              'title',
              'New',
            ),
          ),
        ),
      ).called(1);
    });

    test('getProjectSlug throws if project not found', () async {
      when(
        () => mockProjectRepository.findById(99),
      ).thenAnswer((_) async => null);

      expect(() => service.getProjectSlug(99), throwsException);
    });
  });
}
