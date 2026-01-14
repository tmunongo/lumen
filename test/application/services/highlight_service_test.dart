import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/application/services/highlight_service.dart';
import 'package:lumen/domain/entities/artifact_highlight.dart';
import 'package:lumen/domain/repositories/highlight_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockHighlightRepository extends Mock implements HighlightRepository {}

class FakeArtifactHighlight extends Fake implements ArtifactHighlight {}

void main() {
  late HighlightService service;
  late MockHighlightRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeArtifactHighlight());
  });

  setUp(() {
    mockRepository = MockHighlightRepository();
    service = HighlightService(mockRepository);
  });

  test('addHighlight creates and persists highlight', () async {
    const artifactId = 1;
    const text = 'Important text';
    
    when(() => mockRepository.create(any())).thenAnswer((invocation) async {
       return invocation.positionalArguments.first as ArtifactHighlight;
    });

    final highlight = await service.addHighlight(
      artifactId: artifactId,
      selectedText: text,
    );

    expect(highlight.artifactId, artifactId);
    expect(highlight.selectedText, text);
    verify(() => mockRepository.create(any())).called(1);
  });

  test('injectHighlights wraps text in mark tags', () {
    final highlights = [
      ArtifactHighlight(
        artifactId: 1,
        selectedText: 'ipsum',
        style: 'yellow',
      )..id = 10,
    ];

    const html = '<p>Lorem ipsum dolor sit amet</p>';
    final result = service.injectHighlights(html, highlights);

    expect(result, contains('<mark data-id="10" style="background-color: yellow; cursor: pointer;">ipsum</mark>'));
    expect(result, startsWith('<p>Lorem '));
    expect(result, endsWith(' dolor sit amet</p>'));
  });

  test('injectHighlights handles multiple highlights', () {
    final highlights = [
      ArtifactHighlight(artifactId: 1, selectedText: 'Lorem', style: 'red')..id = 1,
      ArtifactHighlight(artifactId: 1, selectedText: 'amet', style: 'green')..id = 2,
    ];

    const html = '<p>Lorem ipsum dolor sit amet</p>';
    final result = service.injectHighlights(html, highlights);

    expect(result, contains('<mark data-id="1" style="background-color: red; cursor: pointer;">Lorem</mark>'));
    expect(result, contains('<mark data-id="2" style="background-color: green; cursor: pointer;">amet</mark>'));
  });
}
