import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen/application/providers.dart';
import 'package:lumen/domain/entities/artifact.dart';
import 'package:lumen/domain/entities/project.dart';
import 'package:lumen/presentation/screens/reader_screen.dart';
import 'package:lumen/presentation/screens/relationship_screen.dart';
import 'package:lumen/presentation/utils/keyboard_shortcuts.dart';
import 'package:lumen/presentation/widgets/drag_drop_area.dart';
import 'package:lumen/presentation/widgets/note_editor.dart';
import 'package:lumen/presentation/widgets/quote_editor.dart';
import 'package:lumen/presentation/widgets/search_delegate.dart';
import 'package:lumen/presentation/widgets/tag_editor.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final int projectId;

  const ProjectDetailScreen({required this.projectId, super.key});

  @override
  ConsumerState<ProjectDetailScreen> createState() =>
      _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  final _urlController = TextEditingController();
  bool _isIngesting = false;
  String? _filterTag;

  final _urlFocusNode = FocusNode();

  @override
  void dispose() {
    _urlController.dispose();
    _urlFocusNode.dispose();
    super.dispose();
  }

  void _showSearch(BuildContext context) async {
    final artifactRepo = ref.read(artifactRepositoryProvider);
    final artifacts = await artifactRepo.findByProject(widget.projectId);

    if (!mounted) return;

    showSearch(
      context: context,
      delegate: ArtifactSearchDelegate(
        artifacts: artifacts,
        onSelected: (artifact) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ReaderScreen(artifact: artifact)),
          );
        },
      ),
    );
  }

  void _openRelationships(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RelationshipsScreen(projectId: widget.projectId),
      ),
    );
  }

  Future<void> _handleDroppedFiles(List<File> files) async {
    for (final file in files) {
      final extension = file.path.split('.').last.toLowerCase();

      if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
        await _addImage(file);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unsupported file type: $extension')),
          );
        }
      }
    }
  }

  Future<void> _handleDroppedUrls(List<String> urls) async {
    for (final url in urls) {
      _urlController.text = url;
      await _addLink();
    }
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
          setState(() {});
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

  Future<void> _createNote() async {
    await showDialog(
      context: context,
      builder: (context) => NoteEditor(
        onSave: (title, content) async {
          final service = ref.read(artifactServiceProvider);
          await service.createNote(
            projectId: widget.projectId,
            title: title,
            content: content,
          );
          setState(() {});
        },
      ),
    );
  }

  Future<void> _createQuote() async {
    await showDialog(
      context: context,
      builder: (context) => QuoteEditor(
        onSave: (title, content, attribution, sourceUrl) async {
          final service = ref.read(artifactServiceProvider);
          await service.createQuote(
            projectId: widget.projectId,
            title: title,
            content: content,
            attribution: attribution,
            sourceUrl: sourceUrl,
          );
          setState(() {});
        },
      ),
    );
  }

  Future<void> _addImage(File imageFile) async {
    final titleController = TextEditingController(
      text: 'Image ${DateTime.now().millisecondsSinceEpoch}',
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Image'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Title',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final service = ref.read(artifactServiceProvider);
      await service.createImageFromFile(
        projectId: widget.projectId,
        title: titleController.text.trim(),
        imageFile: imageFile,
      );
      setState(() {});
    }

    titleController.dispose();
  }

  void _showAddMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Add Link'),
              onTap: () {
                Navigator.pop(context);
                // Focus on URL input
              },
            ),
            ListTile(
              leading: const Icon(Icons.note),
              title: const Text('Create Note'),
              onTap: () {
                Navigator.pop(context);
                _createNote();
              },
            ),
            ListTile(
              leading: const Icon(Icons.format_quote),
              title: const Text('Create Quote'),
              onTap: () {
                Navigator.pop(context);
                _createQuote();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Add Image'),
              onTap: () async {
                Navigator.pop(context);
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.image,
                );
                if (result != null && result.files.single.path != null) {
                  await _addImage(File(result.files.single.path!));
                }
              },
            ),
          ],
        ),
      ),
    );
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
          setState(() {});
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
          setState(() {});
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
          setState(() {});
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
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectService = ref.watch(projectServiceProvider);
    final artifactRepo = ref.watch(artifactRepositoryProvider);
    final tagRepo = ref.watch(tagRepositoryProvider);

    return FutureBuilder<Project?>(
      future: projectService.getProject(widget.projectId),
      builder: (context, projectSnapshot) {
        if (!projectSnapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final project = projectSnapshot.data!;

        return ShortcutScope(
          shortcuts: {
            KeyboardShortcuts.newNote: _createNote,
            KeyboardShortcuts.search: () => _showSearch(context),
            KeyboardShortcuts.openRelationships: () =>
                _openRelationships(context),
            KeyboardShortcuts.focusUrlInput: () => _urlFocusNode.requestFocus(),
          },
          child: DragDropArea(
            onFilesDropped: _handleDroppedFiles,
            onUrlsDropped: _handleDroppedUrls,
            child: Scaffold(
              appBar: AppBar(
                title: Text(project.name),
                elevation: 0,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.hub),
                    tooltip: 'View Relationships',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              RelationshipsScreen(projectId: widget.projectId),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _showAddMenu,
                  ),
                ],
              ),
              body: Column(
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
                        height: 50,
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
                            ),
                            const SizedBox(width: 8),
                            ...tags.map((tag) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(
                                    '${tag.name} (${tag.usageCount})',
                                  ),
                                  selected: _filterTag == tag.name,
                                  onSelected: (selected) {
                                    setState(() {
                                      _filterTag = selected ? tag.name : null;
                                    });
                                  },
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
                    padding: const EdgeInsets.all(16),
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
                            focusNode: _urlFocusNode,
                            decoration: const InputDecoration(
                              hintText: 'Paste URL to add... (⌘L)',
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _addLink(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_isIngesting)
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        else
                          IconButton.filled(
                            icon: const Icon(Icons.add),
                            onPressed: _addLink,
                          ),
                      ],
                    ),
                  ),

                  // Artifacts list
                  Expanded(
                    child: FutureBuilder<List<Artifact>>(
                      future: _filterTag == null
                          ? artifactRepo.findByProject(widget.projectId)
                          : artifactRepo.findByTag(
                              widget.projectId,
                              _filterTag!,
                            ),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final artifacts = snapshot.data!;

                        if (artifacts.isEmpty) {
                          return Center(
                            child: Text(
                              _filterTag == null
                                  ? 'No artifacts yet.\nAdd content to get started.'
                                  : 'No artifacts with tag "$_filterTag".',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(context).hintColor,
                                  ),
                            ),
                          );
                        }

                        return ListView.separated(
                          itemCount: artifacts.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final artifact = artifacts[index];
                            return _ArtifactListTile(
                              artifact: artifact,
                              onTap: () {
                                if (artifact.type == ArtifactType.image) {
                                  _showImageViewer(artifact);
                                } else if (artifact.isFetched ||
                                    artifact.type == ArtifactType.note ||
                                    artifact.type == ArtifactType.quote) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ReaderScreen(artifact: artifact),
                                    ),
                                  );
                                }
                              },
                              onLongPress: () => _showArtifactOptions(artifact),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showImageViewer(Artifact artifact) {
    if (artifact.localAssetPath == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.file(File(artifact.localAssetPath!)),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(
                title: Text(artifact.title),
                backgroundColor: Colors.black.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtifactListTile extends StatelessWidget {
  final Artifact artifact;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ArtifactListTile({
    required this.artifact,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _getArtifactIcon(artifact),
      title: Text(artifact.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (artifact.sourceUrl != null)
            Text(
              Uri.parse(artifact.sourceUrl!).host,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (artifact.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(
                spacing: 4,
                children: artifact.tags.take(3).map((tag) {
                  return Chip(
                    label: Text(tag),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    labelStyle: Theme.of(context).textTheme.bodySmall,
                  );
                }).toList(),
              ),
            ),
        ],
      ),
      trailing:
          !artifact.isFetched &&
              (artifact.type == ArtifactType.rawLink ||
                  artifact.type == ArtifactType.webPage)
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      onTap: onTap,
      onLongPress: onLongPress,
    );
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
    return Icon(icon);
  }
}
