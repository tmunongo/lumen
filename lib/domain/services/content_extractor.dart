/// Abstract interface for content extraction
abstract class ContentExtractor {
  /// Extract readable content from HTML
  /// Returns cleaned HTML suitable for reading
  Future<ExtractedContent> extract(String html, Uri sourceUrl);
}

class ExtractedContent {
  final String title;
  final String cleanedHtml;
  final String? byline;
  final String? excerpt;
  final int? readingTimeMinutes;

  ExtractedContent({
    required this.title,
    required this.cleanedHtml,
    this.byline,
    this.excerpt,
    this.readingTimeMinutes,
  });
}
