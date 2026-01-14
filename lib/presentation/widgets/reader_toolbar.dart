import 'package:flutter/material.dart';
import 'package:lumen/domain/entities/artifact.dart';
import 'package:lumen/presentation/screens/relationship_screen.dart';
import 'package:lumen/presentation/theme/reader_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class ReaderToolbar extends StatelessWidget {
  final Artifact artifact;

  const ReaderToolbar({required this.artifact, super.key});

  void _showRelationships(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RelationshipsScreen(
          projectId: artifact.projectId,
          initialArtifact: artifact,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? ReaderTheme.darkSurface.withValues(alpha: .95)
        : ReaderTheme.lightSurface.withValues(alpha: .95);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          top: BorderSide(
            color: isDark ? ReaderTheme.darkBorder : ReaderTheme.lightBorder,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? .3 : .1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ToolbarButton(
                icon: Icons.label_outline,
                label: 'Tags',
                onPressed: () {
                  // TODO: Open tag editor
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tag editor coming soon')),
                  );
                },
              ),
              _ToolbarButton(
                icon: Icons.format_quote,
                label: 'Quote',
                onPressed: () {
                  // TODO: Create quote from selection
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Quote creation coming soon')),
                  );
                },
              ),
              _ToolbarButton(
                icon: Icons.hub,
                label: 'Related',
                onPressed: () => _showRelationships(context),
              ),
              if (artifact.sourceUrl != null)
                _ToolbarButton(
                  icon: Icons.open_in_browser,
                  label: 'Original',
                  onPressed: () => _openOriginal(context),
                ),
              _ToolbarButton(
                icon: Icons.share,
                label: 'Share',
                onPressed: () {
                  // TODO: Share functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share coming soon')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openOriginal(BuildContext context) async {
    if (artifact.sourceUrl == null) return;

    final uri = Uri.parse(artifact.sourceUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open URL')));
      }
    }
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
