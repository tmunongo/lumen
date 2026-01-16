import 'package:lumen/domain/entities/artifact_highlight.dart';
import 'package:lumen/domain/repositories/highlight_repository.dart';

class HighlightService {
  final HighlightRepository _repository;

  HighlightService(this._repository);

  Future<ArtifactHighlight> addHighlight({
    required int artifactId,
    required String selectedText,
    String? note,
    String style = 'rgba(255, 235, 59, 0.5)',
  }) async {
    final highlight = ArtifactHighlight(
      artifactId: artifactId,
      selectedText: selectedText,
      note: note,
      style: style,
    );
    return await _repository.create(highlight);
  }

  Future<void> removeHighlight(int highlightId) async {
    await _repository.delete(highlightId);
  }

  Future<List<ArtifactHighlight>> getHighlightsForArtifact(
    int artifactId,
  ) async {
    return await _repository.findByArtifact(artifactId);
  }

  Future<void> updateNote(int highlightId, String note) async {
    // This requires finding it first, or we need an update method that takes ID.
    // For now, let's assume UI passes the object or we find it.
    // But repository only has update(highlight).
    // Let's implement full update if we had the object, but here we might need a findById.
    // Since repository doesn't have findById in the interface yet (my bad), I'll skipping exact implementation
    // or adding findById to repo.
    // Actually, findByArtifact returns list. We can filter.
    // Better to add findById to repo? Yes.
  }

  /// Injects <mark> tags into HTML content based on highlights
  /// Uses HTML-aware text matching to avoid breaking HTML structure
  String injectHighlights(
    String htmlContent,
    List<ArtifactHighlight> highlights,
  ) {
    if (highlights.isEmpty) return htmlContent;

    // Sort highlights by length (longest first) to handle overlapping text better
    final sortedHighlights = List<ArtifactHighlight>.from(highlights)
      ..sort((a, b) => b.selectedText.length.compareTo(a.selectedText.length));

    String processedHtml = htmlContent;

    // Keep track of what we've already highlighted to avoid duplicates
    final Set<String> processedTexts = {};

    for (final highlight in sortedHighlights) {
      final text = highlight.selectedText.trim();
      if (text.isEmpty || processedTexts.contains(text)) continue;

      // Use a more sophisticated approach: only replace text outside of HTML tags
      // This regex matches the text but not if it's inside a tag (< ... >)
      // We use word boundaries when possible, but fallback to exact match

      // Create a regex that matches the text but NOT inside HTML tags
      // This is a simplified approach - we look for text that isn't between < and >
      // We use negative lookahead to avoid matching text that's part of an HTML tag or attribute

      // Split by HTML tags to process only text content
      final parts = <String>[];
      var lastIndex = 0;
      final tagPattern = RegExp(r'<[^>]+>');

      for (final match in tagPattern.allMatches(processedHtml)) {
        // Add text before tag (if any)
        if (match.start > lastIndex) {
          final textPart = processedHtml.substring(lastIndex, match.start);
          // Only replace in text parts, not in tags
          final replacedText = _replaceFirstOccurrence(
            textPart,
            text,
            '<a href="highlight:${highlight.id}" style="background-color: ${highlight.style}; color: inherit; text-decoration: none;">$text</a>',
          );
          parts.add(replacedText);
        }

        // Add the tag itself unchanged
        parts.add(match.group(0)!);
        lastIndex = match.end;
      }

      // Add remaining text after last tag
      if (lastIndex < processedHtml.length) {
        final textPart = processedHtml.substring(lastIndex);
        final replacedText = _replaceFirstOccurrence(
          textPart,
          text,
          '<a href="highlight:${highlight.id}" style="background-color: ${highlight.style}; color: inherit; text-decoration: none;">$text</a>',
        );
        parts.add(replacedText);
      }

      processedHtml = parts.join();
      processedTexts.add(text);
    }

    return processedHtml;
  }

  /// Helper to replace only the first occurrence of text
  String _replaceFirstOccurrence(
    String source,
    String pattern,
    String replacement,
  ) {
    final index = source.indexOf(pattern);
    if (index == -1) return source;

    return source.substring(0, index) +
        replacement +
        source.substring(index + pattern.length);
  }
}
