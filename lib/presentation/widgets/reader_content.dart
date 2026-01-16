import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumen/presentation/theme/reader_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class ReaderContent extends StatelessWidget {
  final String html;
  final String? baseUrl;
  final Function(int)? onHighlightTap;

  const ReaderContent({
    required this.html,
    this.baseUrl,
    this.onHighlightTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? ReaderTheme.darkText : ReaderTheme.lightText;
    final linkColor = isDark ? ReaderTheme.darkAccent : ReaderTheme.lightAccent;
    final codeBackground = isDark
        ? ReaderTheme.darkSurface
        : ReaderTheme.lightSurface;

    return HtmlWidget(
      html,
      baseUrl: baseUrl != null ? Uri.tryParse(baseUrl!) : null,
      enableCaching: true,
      textStyle: TextStyle(
        color: textColor,
        fontSize: 16,
        height: 1.7,
        fontFamily: GoogleFonts.literata().fontFamily,
      ),
      customStylesBuilder: (element) {
        final tag = element.localName ?? '';

        switch (tag) {
          case 'p':
            return {'margin': '0 0 20px 0'};
          case 'h1':
            return {
              'font-size': '28px',
              'font-weight': '700',
              'line-height': '1.2',
              'margin': '32px 0 16px 0',
              'letter-spacing': '-0.5px',
            };
          case 'h2':
            return {
              'font-size': '24px',
              'font-weight': '600',
              'line-height': '1.3',
              'margin': '28px 0 14px 0',
            };
          case 'h3':
            return {
              'font-size': '20px',
              'font-weight': '600',
              'line-height': '1.4',
              'margin': '24px 0 12px 0',
            };
          case 'h4':
            return {
              'font-size': '18px',
              'font-weight': '600',
              'line-height': '1.4',
              'margin': '20px 0 10px 0',
            };
          case 'a':
            if (element.attributes.containsKey('href') &&
                element.attributes['href']!.startsWith('highlight:')) {
              return {
                'text-decoration': 'none',
                'color':
                    '#${textColor.toARGB32().toRadixString(16).substring(2)}',
              };
            }
            return {
              'color':
                  '#${linkColor.toARGB32().toRadixString(16).substring(2)}',
              'text-decoration': 'underline',
            };
          case 'blockquote':
            return {
              'border-left':
                  '4px solid #${linkColor.toARGB32().toRadixString(16).substring(2)}',
              'margin': '20px 0',
              'padding': '8px 0 8px 20px',
              'background-color':
                  '#${codeBackground.toARGB32().toRadixString(16).substring(2)}',
              'font-style': 'italic',
            };
          case 'code':
            return {
              'background-color':
                  '#${codeBackground.toARGB32().toRadixString(16).substring(2)}',
              'padding': '2px 6px',
              'font-family': 'monospace',
              'font-size': '14px',
            };
          case 'pre':
            return {
              'background-color':
                  '#${codeBackground.toARGB32().toRadixString(16).substring(2)}',
              'padding': '16px',
              'margin': '16px 0',
              'overflow': 'auto',
            };
          case 'ul':
          case 'ol':
            return {'margin': '16px 0 16px 24px'};
          case 'li':
            return {'margin': '0 0 8px 0'};
          case 'img':
            return {'margin': '20px 0', 'max-width': '100%'};
          default:
            return null;
        }
      },
      onTapUrl: (url) async {
        if (url.startsWith('highlight:')) {
          final id = int.tryParse(url.substring(10));
          if (id != null && onHighlightTap != null) {
            onHighlightTap!(id);
            return true;
          }
          return false;
        }
        final uri = Uri.tryParse(url);
        if (uri != null) {
          return await launchUrl(uri);
        }
        return false;
      },
    );
  }
}
