import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/infrastructure/services/readability_extractor.dart';

void main() {
  late ReadabilityExtractor extractor;

  setUp(() {
    extractor = ReadabilityExtractor();
  });

  group('ReadabilityExtractor', () {
    test('extracts title from h1', () async {
      const html = '''
        <!DOCTYPE html>
        <html>
          <head><title>Page Title</title></head>
          <body>
            <h1>Article Title</h1>
            <p>Some content here.</p>
          </body>
        </html>
      ''';

      final result = await extractor.extract(
        html,
        Uri.parse('https://example.com'),
      );
      expect(result.title, 'Article Title');
    });

    test('falls back to title tag when no h1', () async {
      const html = '''
        <!DOCTYPE html>
        <html>
          <head><title>Page Title</title></head>
          <body>
            <p>Some content here.</p>
          </body>
        </html>
      ''';

      final result = await extractor.extract(
        html,
        Uri.parse('https://example.com'),
      );
      expect(result.title, 'Page Title');
    });

    test('extracts main content paragraphs', () async {
      const html = '''
        <!DOCTYPE html>
        <html>
          <body>
            <nav>Navigation stuff</nav>
            <article>
              <h1>Main Article</h1>
              <p>First paragraph of real content.</p>
              <p>Second paragraph of real content.</p>
            </article>
            <footer>Footer stuff</footer>
          </body>
        </html>
      ''';

      final result = await extractor.extract(
        html,
        Uri.parse('https://example.com'),
      );
      expect(result.cleanedHtml, contains('First paragraph'));
      expect(result.cleanedHtml, contains('Second paragraph'));
      expect(result.cleanedHtml, isNot(contains('Navigation')));
      expect(result.cleanedHtml, isNot(contains('Footer')));
    });

    test('preserves basic formatting tags', () async {
      const html = '''
        <!DOCTYPE html>
        <html>
          <body>
            <article>
              <h1>Title</h1>
              <p>Text with <strong>bold</strong> and <em>italic</em>.</p>
              <ul>
                <li>List item 1</li>
                <li>List item 2</li>
              </ul>
            </article>
          </body>
        </html>
      ''';

      final result = await extractor.extract(
        html,
        Uri.parse('https://example.com'),
      );
      expect(result.cleanedHtml, contains('<strong>bold</strong>'));
      expect(result.cleanedHtml, contains('<em>italic</em>'));
      expect(result.cleanedHtml, contains('<li>'));
    });

    test('removes script and style tags', () async {
      const html = '''
        <!DOCTYPE html>
        <html>
          <head>
            <style>body { color: red; }</style>
          </head>
          <body>
            <script>alert('xss');</script>
            <article>
              <h1>Title</h1>
              <p>Content</p>
            </article>
          </body>
        </html>
      ''';

      final result = await extractor.extract(
        html,
        Uri.parse('https://example.com'),
      );
      expect(result.cleanedHtml, isNot(contains('<script>')));
      expect(result.cleanedHtml, isNot(contains('<style>')));
      expect(result.cleanedHtml, isNot(contains('alert')));
    });

    test('extracts byline from common author patterns', () async {
      const html = '''
        <!DOCTYPE html>
        <html>
          <body>
            <article>
              <h1>Title</h1>
              <p class="byline">By John Doe</p>
              <p>Content here.</p>
            </article>
          </body>
        </html>
      ''';

      final result = await extractor.extract(
        html,
        Uri.parse('https://example.com'),
      );
      expect(result.byline, contains('John Doe'));
    });

    test('calculates approximate reading time', () async {
      var html =
          '''
        <!DOCTYPE html>
        <html>
          <body>
            <article>
              <h1>Title</h1>
              ${List.generate(300, (i) => '<p>Word ' * 50 + '</p>').join()}
            </article>
          </body>
        </html>
      ''';

      final result = await extractor.extract(
        html,
        Uri.parse('https://example.com'),
      );
      expect(result.readingTimeMinutes, greaterThan(0));
    });

    test('handles malformed HTML gracefully', () async {
      const html = '''
        <html><body><p>Unclosed paragraph
        <div>Unclosed div
        <h1>Title</h1>
        Content
      ''';

      final result = await extractor.extract(
        html,
        Uri.parse('https://example.com'),
      );
      expect(result.title, isNotEmpty);
      expect(result.cleanedHtml, isNotEmpty);
    });

    test('returns empty content for invalid HTML', () async {
      const html = '';

      final result = await extractor.extract(
        html,
        Uri.parse('https://example.com'),
      );
      expect(result.title, 'Untitled');
      expect(result.cleanedHtml, isEmpty);
    });
  });
}
