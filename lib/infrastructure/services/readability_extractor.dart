import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:lumen/domain/services/content_extractor.dart';

class ReadabilityExtractor implements ContentExtractor {
  // Tags that likely contain the main content
  static const _contentTags = ['article', 'main', 'div'];

  // Tags to completely remove
  static const _removeTags = [
    'script',
    'style',
    'noscript',
    'iframe',
    'object',
    'embed',
    'nav',
    'header',
    'footer',
    'aside',
    'form',
  ];

  // Tags to preserve for formatting
  static const _preserveTags = [
    'p',
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
    'strong',
    'em',
    'b',
    'i',
    'u',
    'a',
    'ul',
    'ol',
    'li',
    'blockquote',
    'pre',
    'code',
    'img',
    'figure',
    'figcaption',
    'br',
    'hr',
  ];

  @override
  Future<ExtractedContent> extract(String html, Uri sourceUrl) async {
    if (html.trim().isEmpty) {
      return ExtractedContent(title: 'Untitled', cleanedHtml: '');
    }

    final document = html_parser.parse(html);

    // Remove unwanted elements
    for (final tag in _removeTags) {
      document.querySelectorAll(tag).forEach((el) => el.remove());
    }

    // Extract metadata
    final title = _extractTitle(document);
    final byline = _extractByline(document);

    // Find main content
    final content = _extractMainContent(document);
    final cleanedHtml = _cleanContent(content);

    // Calculate reading time
    final readingTime = _calculateReadingTime(cleanedHtml);

    // Generate excerpt
    final excerpt = _generateExcerpt(cleanedHtml);

    return ExtractedContent(
      title: title,
      cleanedHtml: cleanedHtml,
      byline: byline,
      excerpt: excerpt,
      readingTimeMinutes: readingTime,
    );
  }

  String _extractTitle(Document document) {
    // Try h1 first
    final h1 = document.querySelector('h1');
    if (h1 != null && h1.text.trim().isNotEmpty) {
      return h1.text.trim();
    }

    // Try article > h1, h2
    final articleHeading = document.querySelector('article h1, article h2');
    if (articleHeading != null && articleHeading.text.trim().isNotEmpty) {
      return articleHeading.text.trim();
    }

    // Fallback to title tag
    final titleTag = document.querySelector('title');
    if (titleTag != null && titleTag.text.trim().isNotEmpty) {
      return titleTag.text.trim();
    }

    return 'Untitled';
  }

  String? _extractByline(Document document) {
    // Look for common byline patterns
    final selectors = [
      '[class*="author"]',
      '[class*="byline"]',
      '[rel="author"]',
      '.author',
      '.byline',
    ];

    for (final selector in selectors) {
      final element = document.querySelector(selector);
      if (element != null) {
        final text = element.text.trim();
        if (text.isNotEmpty && text.length < 100) {
          return text;
        }
      }
    }

    return null;
  }

  Element _extractMainContent(Document document) {
    // Try to find main content container
    final article = document.querySelector('article');
    if (article != null) return article;

    final main = document.querySelector('main');
    if (main != null) return main;

    // Score divs by content density
    final divs = document.querySelectorAll('div');
    if (divs.isEmpty) return document.body ?? document.documentElement!;

    Element? bestDiv;
    double bestScore = 0;

    for (final div in divs) {
      final score = _scoreContentNode(div);
      if (score > bestScore) {
        bestScore = score;
        bestDiv = div;
      }
    }

    return bestDiv ?? document.body ?? document.documentElement!;
  }

  double _scoreContentNode(Element element) {
    double score = 0;

    // Count paragraphs
    final paragraphs = element.querySelectorAll('p');
    score += paragraphs.length * 3;

    // Count text length
    final textLength = element.text.length;
    score += textLength / 100;

    // Penalize certain classes/ids
    final classAndId = '${element.className} ${element.id}'.toLowerCase();
    if (classAndId.contains('comment')) score -= 50;
    if (classAndId.contains('footer')) score -= 50;
    if (classAndId.contains('nav')) score -= 50;
    if (classAndId.contains('sidebar')) score -= 50;

    // Bonus for article-like classes
    if (classAndId.contains('article')) score += 25;
    if (classAndId.contains('content')) score += 15;
    if (classAndId.contains('main')) score += 20;

    return score;
  }

  String _cleanContent(Element content) {
    final buffer = StringBuffer();
    _traverseAndClean(content, buffer);
    return buffer.toString().trim();
  }

  void _traverseAndClean(Node node, StringBuffer buffer) {
    if (node is Element) {
      final tagName = node.localName?.toLowerCase();

      if (tagName == null || _removeTags.contains(tagName)) {
        return;
      }

      if (_preserveTags.contains(tagName)) {
        buffer.write('<$tagName');

        // Preserve certain attributes
        if (tagName == 'a') {
          final href = node.attributes['href'];
          if (href != null) buffer.write(' href="$href"');
        } else if (tagName == 'img') {
          final src = node.attributes['src'];
          final alt = node.attributes['alt'];
          if (src != null) buffer.write(' src="$src"');
          if (alt != null) buffer.write(' alt="$alt"');
        }

        buffer.write('>');
      }

      for (final child in node.nodes) {
        _traverseAndClean(child, buffer);
      }

      if (_preserveTags.contains(tagName)) {
        buffer.write('</$tagName>');
      }
    } else if (node is Text) {
      final text = node.text.trim();
      if (text.isNotEmpty) {
        buffer.write(text);
      }
    }
  }

  int _calculateReadingTime(String html) {
    // Strip HTML tags for word count
    final text = html.replaceAll(RegExp(r'<[^>]*>'), ' ');
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

    // Average reading speed: 200 words per minute
    final minutes = (words / 200).ceil();
    return minutes > 0 ? minutes : 1;
  }

  String? _generateExcerpt(String html) {
    final text = html.replaceAll(RegExp(r'<[^>]*>'), ' ');
    final cleaned = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (cleaned.length <= 200) return cleaned;

    // Find last space before 200 chars
    final cutoff = cleaned.lastIndexOf(' ', 200);
    if (cutoff == -1) return '${cleaned.substring(0, 200)}...';

    return '${cleaned.substring(0, cutoff)}...';
  }
}
