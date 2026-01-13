import 'dart:async';

import 'package:http/http.dart' as http;

class WebFetchResult {
  final String content;
  final int statusCode;
  final String contentType;
  final Uri finalUrl;

  WebFetchResult({
    required this.content,
    required this.statusCode,
    required this.contentType,
    required this.finalUrl,
  });
}

class WebFetchException implements Exception {
  final String message;
  final int? statusCode;

  WebFetchException(this.message, [this.statusCode]);

  @override
  String toString() =>
      'WebFetchException: $message${statusCode != null ? ' (HTTP $statusCode)' : ''}';
}

class WebFetcher {
  final http.Client _client;
  final Duration timeout;

  WebFetcher({http.Client? client, this.timeout = const Duration(seconds: 30)})
    : _client = client ?? http.Client();

  Future<WebFetchResult> fetch(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      throw WebFetchException('Invalid URL: $url');
    }

    if (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
      throw WebFetchException('Only HTTP and HTTPS URLs are supported');
    }

    try {
      final response = await _client.get(uri).timeout(timeout);

      if (response.statusCode >= 400) {
        throw WebFetchException('HTTP error', response.statusCode);
      }

      final contentType = response.headers['content-type'] ?? 'text/html';

      return WebFetchResult(
        content: response.body,
        statusCode: response.statusCode,
        contentType: contentType,
        finalUrl: response.request?.url ?? uri,
      );
    } on TimeoutException {
      throw WebFetchException('Request timed out after ${timeout.inSeconds}s');
    } on http.ClientException catch (e) {
      throw WebFetchException('Network error: ${e.message}');
    } catch (e) {
      throw WebFetchException('Unexpected error: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
