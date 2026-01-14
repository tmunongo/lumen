import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen/application/providers.dart';
import 'package:lumen/domain/entities/artifact.dart';
import 'package:lumen/presentation/screens/relationship_screen.dart';
import 'package:lumen/presentation/theme/reader_theme.dart';
import 'package:lumen/presentation/widgets/artifact_picker_dialog.dart';
import 'package:lumen/presentation/widgets/quote_editor.dart';
import 'package:lumen/presentation/widgets/tag_editor.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ReaderToolbar extends ConsumerWidget {
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

  void _editTags(BuildContext context, WidgetRef ref) async {
    await showDialog(
      context: context,
      builder: (context) => TagEditor(
        projectId: artifact.projectId,
        initialTags: artifact.tags,
        onSave: (tags) async {
          final service = ref.read(artifactServiceProvider);
          await service.updateArtifact(artifact: artifact, newTags: tags);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tags updated')),
            );
          }
        },
      ),
    );
  }

  void _createLink(BuildContext context, WidgetRef ref) async {
    final result = await ArtifactPickerDialog.show(
      context,
      projectId: artifact.projectId,
      excludeArtifactId: artifact.id,
    );

    if (result == null) return;

    final linkService = ref.read(linkServiceProvider);
    
    try {
      final link = await linkService.createLink(
        artifact.id,
        result.artifact.id,
        artifact.projectId,
        type: result.type,
      );

      if (context.mounted) {
        if (link != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Linked to "${result.artifact.title}" as ${link.typeLabel}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Link already exists')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create link: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _createQuote(BuildContext context, WidgetRef ref) async {
    await showDialog(
      context: context,
      builder: (context) => QuoteEditor(
        onSave: (title, content, attribution, sourceUrl) async {
          final service = ref.read(artifactServiceProvider);
          await service.createQuote(
            projectId: artifact.projectId,
            title: title,
            content: content,
            attribution: attribution,
            sourceUrl: sourceUrl ?? artifact.sourceUrl,
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Quote created')),
            );
          }
        },
      ),
    );
  }

  void _shareArtifact() {
    final StringBuffer shareText = StringBuffer();
    shareText.writeln(artifact.title);
    
    if (artifact.content != null && artifact.content!.isNotEmpty) {
      // For quotes and notes, share the content
      if (artifact.type == ArtifactType.quote || artifact.type == ArtifactType.note) {
        shareText.writeln();
        shareText.writeln(artifact.content);
      }
    }
    
    if (artifact.attribution != null) {
      shareText.writeln();
      shareText.writeln('— ${artifact.attribution}');
    }
    
    if (artifact.sourceUrl != null) {
      shareText.writeln();
      shareText.writeln(artifact.sourceUrl);
    }
    
    Share.share(shareText.toString());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                onPressed: () => _editTags(context, ref),
              ),
              _ToolbarButton(
                icon: Icons.link,
                label: 'Link',
                onPressed: () => _createLink(context, ref),
              ),
              _ToolbarButton(
                icon: Icons.format_quote,
                label: 'Quote',
                onPressed: () => _createQuote(context, ref),
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
                onPressed: _shareArtifact,
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
