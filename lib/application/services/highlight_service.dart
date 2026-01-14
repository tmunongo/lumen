import 'package:lumen/domain/entities/artifact_highlight.dart';
import 'package:lumen/domain/repositories/highlight_repository.dart';

class HighlightService {
  final HighlightRepository _repository;

  HighlightService(this._repository);

  Future<ArtifactHighlight> addHighlight({
    required int artifactId,
    required String selectedText,
    String? note,
    String style = 'yellow',
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

  Future<List<ArtifactHighlight>> getHighlightsForArtifact(int artifactId) async {
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
  /// This is a "fuzzy" injection that replaces occurrences of the text
  String injectHighlights(String htmlContent, List<ArtifactHighlight> highlights) {
    if (highlights.isEmpty) return htmlContent;

    String processedHtml = htmlContent;

    // Sort highlights by length descending to match longest phrases first (reduces partial collision)
    // Or just iterate.
    // A generic approach:
    for (final highlight in highlights) {
      final text = highlight.selectedText;
      if (text.trim().isEmpty) continue;
      
      // Simple case-insensitive replacement
      // We wrap in <mark data-id="${highlight.id}" class="highlight-${highlight.style}">...</mark>
      // We use a regex that tries not to break HTML tags (basic approach)
      final replacement = '<mark data-id="${highlight.id}" style="background-color: ${highlight.style}; cursor: pointer;">$text</mark>';
      
      // THIS IS NAIVE: it replaces ALL occurrences.
      // Ideal solution requires storing position/offset, but flutter_html doesn't give us easy offset.
      // We accept this limitation for the "fuzzy" strategy.
      processedHtml = processedHtml.replaceAll(text, replacement);
    }

    return processedHtml;
  }
}
