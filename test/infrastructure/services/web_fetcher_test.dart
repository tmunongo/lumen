import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lumen/infrastructure/services/web_fetcher.dart';

void main() {
  group('WebFetcher', () {
    test('fetches valid URL successfully', () async {
      final mockClient = MockClient((request) async {
        return http.Response('<html>Test</html>', 200);
      });

      final fetcher = WebFetcher(client: mockClient);
      final result = await fetcher.fetch('https://example.com');

      expect(result.statusCode, 200);
      expect(result.content, contains('Test'));
    });

    test('throws on invalid URL', () async {
      final fetcher = WebFetcher();

      expect(
        () => fetcher.fetch('not a url'),
        throwsA(isA<WebFetchException>()),
      );
    });

    test('throws on non-HTTP(S) scheme', () async {
      final fetcher = WebFetcher();

      expect(
        () => fetcher.fetch('ftp://example.com'),
        throwsA(isA<WebFetchException>()),
      );
    });

    test('throws on HTTP error status', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final fetcher = WebFetcher(client: mockClient);

      expect(
        () => fetcher.fetch('https://example.com/missing'),
        throwsA(isA<WebFetchException>()),
      );
    });

    test('handles timeout', () async {
      final mockClient = MockClient((request) async {
        await Future.delayed(const Duration(seconds: 2));
        return http.Response('', 200);
      });

      final fetcher = WebFetcher(
        client: mockClient,
        timeout: const Duration(milliseconds: 100),
      );

      expect(
        () => fetcher.fetch('https://slow.example.com'),
        throwsA(isA<WebFetchException>()),
      );
    });
  });
}
