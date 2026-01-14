import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumen/presentation/theme/reader_theme.dart';

class ReaderContent extends StatelessWidget {
  final String html;
  final String? baseUrl;

  const ReaderContent({required this.html, this.baseUrl, super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? ReaderTheme.darkText : ReaderTheme.lightText;
    final linkColor = isDark ? ReaderTheme.darkAccent : ReaderTheme.lightAccent;
    final codeBackground = isDark
        ? ReaderTheme.darkSurface
        : ReaderTheme.lightSurface;

    return Html(
      data: html,
      extensions: [
        TagExtension(
          tagsToExtend: {'img'},
          builder: (extensionContext) {
            final src = extensionContext.attributes['src'];
            if (src == null || src.isEmpty) {
              return const SizedBox.shrink();
            }

            // Handle relative URLs
            String imageUrl = src;
            if (!src.startsWith('http') && baseUrl != null) {
              final base = Uri.tryParse(baseUrl!);
              if (base != null) {
                imageUrl = base.resolve(src).toString();
              }
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Image.network(
                imageUrl,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: codeBackground,
                      border: Border.all(
                        color: isDark
                            ? ReaderTheme.darkBorder
                            : ReaderTheme.lightBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.broken_image,
                          color: isDark
                              ? ReaderTheme.darkTextSecondary
                              : ReaderTheme.lightTextSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Failed to load image',
                            style: TextStyle(
                              color: isDark
                                  ? ReaderTheme.darkTextSecondary
                                  : ReaderTheme.lightTextSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
      style: {
        'html': Style(padding: HtmlPaddings.zero, margin: Margins.zero),
        'body': Style(
          padding: HtmlPaddings.zero,
          margin: Margins.zero,
          color: textColor,
          fontSize: FontSize(16),
          lineHeight: const LineHeight(1.7),
          fontFamily: GoogleFonts.literata().fontFamily,
        ),
        'p': Style(
          fontSize: FontSize(16),
          lineHeight: const LineHeight(1.7),
          margin: Margins.only(bottom: 20),
        ),
        'h1': Style(
          fontSize: FontSize(28),
          fontWeight: FontWeight.w700,
          lineHeight: const LineHeight(1.2),
          margin: Margins.only(top: 32, bottom: 16),
          letterSpacing: -0.5,
        ),
        'h2': Style(
          fontSize: FontSize(24),
          fontWeight: FontWeight.w600,
          lineHeight: const LineHeight(1.3),
          margin: Margins.only(top: 28, bottom: 14),
        ),
        'h3': Style(
          fontSize: FontSize(20),
          fontWeight: FontWeight.w600,
          lineHeight: const LineHeight(1.4),
          margin: Margins.only(top: 24, bottom: 12),
        ),
        'h4': Style(
          fontSize: FontSize(18),
          fontWeight: FontWeight.w600,
          lineHeight: const LineHeight(1.4),
          margin: Margins.only(top: 20, bottom: 10),
        ),
        'h5': Style(
          fontSize: FontSize(16),
          fontWeight: FontWeight.w600,
          lineHeight: const LineHeight(1.5),
          margin: Margins.only(top: 18, bottom: 10),
        ),
        'h6': Style(
          fontSize: FontSize(14),
          fontWeight: FontWeight.w600,
          lineHeight: const LineHeight(1.5),
          margin: Margins.only(top: 16, bottom: 8),
        ),
        'a': Style(
          color: linkColor,
          textDecoration: TextDecoration.underline,
          textDecorationColor: linkColor.withValues(alpha: .4),
        ),
        'strong, b': Style(fontWeight: FontWeight.w700),
        'em, i': Style(fontStyle: FontStyle.italic),
        'blockquote': Style(
          border: Border(left: BorderSide(color: linkColor, width: 4)),
          margin: Margins.only(top: 20, bottom: 20, left: 0),
          padding: HtmlPaddings.only(left: 20, top: 8, bottom: 8),
          backgroundColor: codeBackground,
          fontStyle: FontStyle.italic,
        ),
        'code': Style(
          backgroundColor: codeBackground,
          color: textColor,
          padding: HtmlPaddings.symmetric(horizontal: 6, vertical: 2),
          fontFamily: 'monospace',
          fontSize: FontSize(14),
        ),
        'pre': Style(
          backgroundColor: codeBackground,
          padding: HtmlPaddings.all(16),
          margin: Margins.only(top: 16, bottom: 16),
          border: Border.all(
            color: isDark ? ReaderTheme.darkBorder : ReaderTheme.lightBorder,
            width: 1,
          ),
        ),
        'pre code': Style(
          backgroundColor: Colors.transparent,
          padding: HtmlPaddings.zero,
          fontFamily: 'monospace',
          fontSize: FontSize(15),
        ),
        'ul, ol': Style(
          margin: Margins.only(top: 16, bottom: 16, left: 24),
          padding: HtmlPaddings.zero,
        ),
        'li': Style(
          margin: Margins.only(bottom: 8),
          fontSize: FontSize(16),
          lineHeight: const LineHeight(1.7),
        ),
        'img': Style(
          width: Width(100, Unit.percent),
          margin: Margins.only(top: 20, bottom: 20),
        ),
        'figure': Style(
          margin: Margins.only(top: 24, bottom: 24),
          padding: HtmlPaddings.zero,
        ),
        'figcaption': Style(
          fontSize: FontSize(15),
          color: isDark
              ? ReaderTheme.darkTextSecondary
              : ReaderTheme.lightTextSecondary,
          fontStyle: FontStyle.italic,
          textAlign: TextAlign.center,
          margin: Margins.only(top: 8),
        ),
        'hr': Style(
          margin: Margins.only(top: 32, bottom: 32),
          border: Border(
            top: BorderSide(
              color: isDark ? ReaderTheme.darkBorder : ReaderTheme.lightBorder,
              width: 1,
            ),
          ),
        ),
      },
    );
  }
}
