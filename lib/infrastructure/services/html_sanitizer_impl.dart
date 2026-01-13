import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:lumen/domain/services/html_sanitizer.dart';

class HtmlSanitizerImpl implements HtmlSanitizer {
  static const _allowedTags = {
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
    'div',
    'span',
  };

  static const _allowedAttributes = {
    'a': {'href', 'title'},
    'img': {'src', 'alt', 'title'},
  };

  static const _dangerousProtocols = ['javascript:', 'data:text', 'vbscript:'];

  @override
  String sanitize(String html) {
    if (html.trim().isEmpty) return '';

    final document = html_parser.parseFragment(html);
    final sanitized = _sanitizeNode(document);

    return sanitized.outerHtml;
  }

  DocumentFragment _sanitizeNode(DocumentFragment fragment) {
    final cleaned = DocumentFragment();

    for (final node in fragment.nodes.toList()) {
      final sanitizedNode = _sanitizeNodeRecursive(node);
      if (sanitizedNode != null) {
        cleaned.append(sanitizedNode);
      }
    }

    return cleaned;
  }

  Node? _sanitizeNodeRecursive(Node node) {
    if (node is Text) {
      return Text(node.text);
    }

    if (node is Element) {
      final tagName = node.localName?.toLowerCase();

      // Remove disallowed tags
      if (tagName == null || !_allowedTags.contains(tagName)) {
        return null;
      }

      final newElement = Element.tag(tagName);

      // Filter attributes
      _sanitizeAttributes(node, newElement);

      // Recursively sanitize children
      for (final child in node.nodes) {
        final sanitizedChild = _sanitizeNodeRecursive(child);
        if (sanitizedChild != null) {
          newElement.append(sanitizedChild);
        }
      }

      return newElement;
    }

    return null;
  }

  void _sanitizeAttributes(Element original, Element cleaned) {
    final tagName = original.localName?.toLowerCase();
    if (tagName == null) return;

    final allowedAttrs = _allowedAttributes[tagName] ?? <String>{};

    for (final attr in original.attributes.entries) {
      final attrName = attr.key.toString().toLowerCase();
      final attrValue = attr.value;

      // Skip event handlers
      if (attrName.startsWith('on')) continue;

      // Skip style attribute
      if (attrName == 'style') continue;

      // Check if attribute is allowed for this tag
      if (!allowedAttrs.contains(attrName)) continue;

      // Validate URL attributes
      if (attrName == 'href' || attrName == 'src') {
        if (!_isSafeUrl(attrValue)) continue;
      }

      cleaned.attributes[attrName] = attrValue;
    }
  }

  bool _isSafeUrl(String url) {
    final lower = url.toLowerCase().trim();

    // Check for dangerous protocols
    for (final protocol in _dangerousProtocols) {
      if (lower.startsWith(protocol)) {
        return false;
      }
    }

    // Allow data URLs only for images
    if (lower.startsWith('data:image/')) {
      return true;
    }

    if (lower.startsWith('data:')) {
      return false;
    }

    // Allow http, https, relative URLs
    return true;
  }
}
