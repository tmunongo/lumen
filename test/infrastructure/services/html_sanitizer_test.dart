import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/infrastructure/services/html_sanitizer_impl.dart';

void main() {
  late HtmlSanitizerImpl sanitizer;

  setUp(() {
    sanitizer = HtmlSanitizerImpl();
  });

  group('HtmlSanitizer', () {
    test('allows safe tags', () {
      const html = '<p>Text with <strong>bold</strong> and <em>italic</em></p>';
      final result = sanitizer.sanitize(html);

      expect(result, contains('<p>'));
      expect(result, contains('<strong>'));
      expect(result, contains('<em>'));
    });

    test('removes script tags', () {
      const html = '<p>Safe</p><script>alert("xss")</script>';
      final result = sanitizer.sanitize(html);

      expect(result, contains('<p>Safe</p>'));
      expect(result, isNot(contains('<script>')));
      expect(result, isNot(contains('alert')));
    });

    test('removes style tags', () {
      const html = '<p>Content</p><style>body { color: red; }</style>';
      final result = sanitizer.sanitize(html);

      expect(result, isNot(contains('<style>')));
    });

    test('removes onclick and other event handlers', () {
      const html = '<button onclick="alert()">Click</button>';
      final result = sanitizer.sanitize(html);

      expect(result, isNot(contains('onclick')));
    });

    test('removes javascript: URLs', () {
      const html = '<a href="javascript:alert()">Link</a>';
      final result = sanitizer.sanitize(html);

      expect(result, isNot(contains('javascript:')));
    });

    test('removes data URLs except images', () {
      const html = '''
        <img src="data:image/png;base64,ABC123">
        <a href="data:text/html,<script>alert()</script>">Bad</a>
      ''';
      final result = sanitizer.sanitize(html);

      expect(result, contains('data:image/png'));
      expect(result, isNot(contains('data:text/html')));
    });

    test('preserves safe attributes', () {
      const html = '<a href="https://example.com" title="Link">Text</a>';
      final result = sanitizer.sanitize(html);

      expect(result, contains('href="https://example.com"'));
      expect(result, contains('title="Link"'));
    });

    test('removes style attributes', () {
      const html = '<p style="color: red;">Text</p>';
      final result = sanitizer.sanitize(html);

      expect(result, isNot(contains('style=')));
    });

    test('handles nested dangerous content', () {
      const html = '''
        <div>
          <p>Safe</p>
          <div onclick="bad()">
            <script>alert()</script>
            <p>More safe</p>
          </div>
        </div>
      ''';
      final result = sanitizer.sanitize(html);

      expect(result, contains('Safe'));
      expect(result, contains('More safe'));
      expect(result, isNot(contains('onclick')));
      expect(result, isNot(contains('<script>')));
    });

    test('preserves HTML entities', () {
      const html = '<p>&lt;not a tag&gt; &amp; entities</p>';
      final result = sanitizer.sanitize(html);

      expect(result, contains('&lt;'));
      expect(result, contains('&gt;'));
      expect(result, contains('&amp;'));
    });
  });
}
