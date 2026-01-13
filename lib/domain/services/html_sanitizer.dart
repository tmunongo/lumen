/// Abstract interface for HTML sanitization
abstract class HtmlSanitizer {
  /// Sanitize HTML, removing scripts, dangerous attributes, etc.
  String sanitize(String html);
}
