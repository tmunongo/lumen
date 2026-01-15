import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen/application/providers.dart';
import 'package:lumen/domain/entities/artifact.dart';
import 'package:lumen/presentation/widgets/note_editor.dart';
import 'package:lumen/presentation/widgets/quote_editor.dart';
import 'package:lumen/presentation/widgets/tag_editor.dart';

class ProjectSidebar extends ConsumerStatefulWidget {
  final int projectId;
  final Artifact? selectedArtifact;
  final Function(Artifact?) onArtifactSelected;
  final FocusNode urlFocusNode;

  const ProjectSidebar({
    required this.projectId,
    required this.selectedArtifact,
    required this.onArtifactSelected,
    required this.urlFocusNode,
    super.key,
  });

  @override
  ConsumerState<ProjectSidebar> createState() => _ProjectSidebarState();
}

class _ProjectSidebarState extends ConsumerState<ProjectSidebar> {
  final _urlController = TextEditingController();
  bool _isIngesting = false;
  String? _filterTag;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _addLink() async {
    if (_urlController.text.trim().isEmpty) return;

    try {
      final artifactRepo = ref.read(artifactRepositoryProvider);
      final ingestionService = ref.read(ingestionServiceProvider);

      final artifact = Artifact(
        projectId: widget.projectId,
        type: ArtifactType.rawLink,
        title: _urlController.text.trim(),
        sourceUrl: _urlController.text.trim(),
      );

      await artifactRepo.create(artifact);
      _urlController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link added, fetching content...')),
        );
      }

      setState(() => _isIngesting = true);
      final result = await ingestionService.ingest(artifact);
      setState(() => _isIngesting = false);

      if (mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Content fetched successfully')),
          );
          // Auto-select the new artifact?
          // widget.onArtifactSelected(artifact); // Artifact ID might have changed or internal state.
          // For now just refresh locally via riverpod watcher
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${result.errorMessage}')),
          );
        }
      }
    } catch (e) {
      setState(() => _isIngesting = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showArtifactOptions(Artifact artifact) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.label),
              title: const Text('Manage Tags'),
              onTap: () {
                Navigator.pop(context);
                _editTags(artifact);
              },
            ),
            if (artifact.type == ArtifactType.note)
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Note'),
                onTap: () {
                  Navigator.pop(context);
                  _editNote(artifact);
                },
              ),
            if (artifact.type == ArtifactType.quote)
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Quote'),
                onTap: () {
                  Navigator.pop(context);
                  _editQuote(artifact);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await _deleteArtifact(artifact);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editTags(Artifact artifact) async {
    await showDialog(
      context: context,
      builder: (context) => TagEditor(
        projectId: widget.projectId,
        initialTags: artifact.tags,
        onSave: (tags) async {
          final service = ref.read(artifactServiceProvider);
          await service.updateArtifact(artifact: artifact, newTags: tags);
          ref.invalidate(artifactRepositoryProvider);
        },
      ),
    );
  }

  Future<void> _editNote(Artifact artifact) async {
    await showDialog(
      context: context,
      builder: (context) => NoteEditor(
        existingNote: artifact,
        onSave: (title, content) async {
          final service = ref.read(artifactServiceProvider);
          await service.updateArtifact(
            artifact: artifact,
            newTitle: title,
            newContent: content,
          );
          ref.invalidate(artifactRepositoryProvider);
        },
      ),
    );
  }

  Future<void> _editQuote(Artifact artifact) async {
    await showDialog(
      context: context,
      builder: (context) => QuoteEditor(
        existingQuote: artifact,
        onSave: (title, content, attribution, sourceUrl) async {
          final service = ref.read(artifactServiceProvider);
          await service.updateArtifact(
            artifact: artifact,
            newTitle: title,
            newContent: content,
            newAttribution: attribution,
          );
          ref.invalidate(artifactRepositoryProvider);
        },
      ),
    );
  }

  Future<void> _deleteArtifact(Artifact artifact) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Artifact'),
        content: Text('Delete "${artifact.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final service = ref.read(artifactServiceProvider);
      await service.deleteArtifact(artifact);

      if (widget.selectedArtifact?.id == artifact.id) {
        widget.onArtifactSelected(null);
      }

      if (mounted) {
        setState(() {}); // Refresh list
      }
    }
  }

  Widget _getArtifactIcon(Artifact artifact) {
    IconData icon;
    switch (artifact.type) {
      case ArtifactType.webPage:
        icon = Icons.article;
      case ArtifactType.rawLink:
        icon = Icons.link;
      case ArtifactType.note:
        icon = Icons.note;
      case ArtifactType.quote:
        icon = Icons.format_quote;
      case ArtifactType.image:
        icon = Icons.image;
    }
    return Icon(icon, size: 20); // Smaller icon for dense list
  }

  @override
  Widget build(BuildContext context) {
    final artifactRepo = ref.watch(artifactRepositoryProvider);
    final tagRepo = ref.watch(tagRepositoryProvider);

    return Column(
      children: [
        // Tag filter
        FutureBuilder(
          future: tagRepo.findByProject(widget.projectId),
          builder: (context, tagSnapshot) {
            if (!tagSnapshot.hasData || tagSnapshot.data!.isEmpty) {
              return const SizedBox.shrink();
            }

            final tags = tagSnapshot.data!;

            return Container(
              height: 48,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _filterTag == null,
                    onSelected: (selected) {
                      setState(() => _filterTag = null);
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 8),
                  ...tags.map((tag) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text('${tag.name} (${tag.usageCount})'),
                        selected: _filterTag == tag.name,
                        onSelected: (selected) {
                          setState(() {
                            _filterTag = selected ? tag.name : null;
                          });
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),

        // URL input
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _urlController,
                  focusNode: widget.urlFocusNode,
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: const InputDecoration(
                    hintText: 'Paste URL...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onSubmitted: (_) => _addLink(),
                ),
              ),
              const SizedBox(width: 8),
              if (_isIngesting)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: _addLink,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  splashRadius: 20,
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
            ],
          ),
        ),

        // Artifacts list
        Expanded(
          child: FutureBuilder<List<Artifact>>(
            future: _filterTag == null
                ? artifactRepo.findByProject(widget.projectId)
                : artifactRepo.findByTag(widget.projectId, _filterTag!),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final artifacts = snapshot.data!;

              if (artifacts.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      _filterTag == null
                          ? 'No artifacts'
                          : 'No artifacts with tag',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                );
              }

              return ListView.separated(
                itemCount: artifacts.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final artifact = artifacts[index];
                  final isSelected = widget.selectedArtifact?.id == artifact.id;

                  return ListTile(
                    dense: true,
                    selected: isSelected,
                    leading: _getArtifactIcon(artifact),
                    title: Text(
                      artifact.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: artifact.tags.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              artifact.tags.join(', '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(fontSize: 11),
                            ),
                          )
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!artifact.isFetched &&
                            (artifact.type == ArtifactType.rawLink ||
                                artifact.type == ArtifactType.webPage))
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        IconButton(
                          icon: const Icon(Icons.more_vert, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _showArtifactOptions(artifact),
                        ),
                      ],
                    ),
                    onTap: () => widget.onArtifactSelected(artifact),
                    onLongPress: () => _showArtifactOptions(artifact),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
