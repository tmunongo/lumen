import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen/application/providers.dart';
import 'package:lumen/domain/entities/artifact.dart';
import 'package:lumen/domain/entities/markdown_document.dart';
import 'package:lumen/domain/entities/project.dart';
import 'package:lumen/presentation/screens/markdown_editor_screen.dart';
import 'package:lumen/presentation/screens/reader_screen.dart';
import 'package:lumen/presentation/screens/relationship_screen.dart';
import 'package:lumen/presentation/utils/keyboard_shortcuts.dart';
import 'package:lumen/presentation/widgets/drag_drop_area.dart';
import 'package:lumen/presentation/widgets/note_editor.dart';
import 'package:lumen/presentation/widgets/project_sidebar.dart';
import 'package:lumen/presentation/widgets/quote_editor.dart';
import 'package:lumen/presentation/widgets/search_delegate.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final int projectId;

  const ProjectDetailScreen({required this.projectId, super.key});

  @override
  ConsumerState<ProjectDetailScreen> createState() =>
      _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  final _urlFocusNode = FocusNode();

  @override
  void dispose() {
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
      await _addLink(url);
    }
  }

  Future<void> _addLink(String url) async {
    if (url.trim().isEmpty) return;

    try {
      final artifactRepo = ref.read(artifactRepositoryProvider);
      final ingestionService = ref.read(ingestionServiceProvider);

      final artifact = Artifact(
        projectId: widget.projectId,
        type: ArtifactType.rawLink,
        title: url.trim(),
        sourceUrl: url.trim(),
      );

      await artifactRepo.create(artifact);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link added, fetching content...')),
        );
      }

      final result = await ingestionService.ingest(artifact);

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

  Future<void> _createMarkdown() async {
    final titleController = TextEditingController(text: 'Untitled Document');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Markdown Document'),
        content: TextField(
          controller: titleController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Document Title',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => Navigator.pop(context, true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (confirmed == true && titleController.text.trim().isNotEmpty) {
      try {
        final markdownService = ref.read(markdownServiceProvider);
        final document = await markdownService.createDocument(
          projectId: widget.projectId,
          title: titleController.text.trim(),
        );

        setState(() {
          _selectedMarkdownDocument = document;
          _selectedArtifact = null;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating document: $e')),
          );
        }
      }
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
              leading: const Icon(Icons.edit_document),
              title: const Text('New Markdown'),
              subtitle: const Text('Create a new markdown document'),
              onTap: () {
                Navigator.pop(context);
                _createMarkdown();
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Add Link'),
              onTap: () {
                Navigator.pop(context);
                _urlFocusNode.requestFocus();
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

  Artifact? _selectedArtifact;
  MarkdownDocument? _selectedMarkdownDocument;

  @override
  Widget build(BuildContext context) {
    final projectService = ref.watch(projectServiceProvider);

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
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(1),
                  child: Container(
                    color: Theme.of(context).dividerColor,
                    height: 1,
                  ),
                ),
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
              body: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sidebar
                  SizedBox(
                    width: 280,
                    child: ProjectSidebar(
                      projectId: widget.projectId,
                      selectedArtifact: _selectedArtifact,
                      onArtifactSelected: (artifact) {
                        setState(() {
                          _selectedArtifact = artifact;
                          _selectedMarkdownDocument = null;
                        });
                      },
                      selectedMarkdownDocument: _selectedMarkdownDocument,
                      onMarkdownSelected: (document) {
                        setState(() {
                          _selectedMarkdownDocument = document;
                          _selectedArtifact = null;
                        });
                      },
                      urlFocusNode: _urlFocusNode,
                    ),
                  ),

                  VerticalDivider(
                    width: 1,
                    color: Theme.of(context).dividerColor,
                  ),

                  // Main Content Area
                  Expanded(
                    child: _selectedArtifact != null
                        ? ReaderScreen(
                            key: ValueKey(_selectedArtifact!.id),
                            artifact: _selectedArtifact!,
                            showBackButton: true,
                            onBack: () =>
                                setState(() => _selectedArtifact = null),
                          )
                        : _selectedMarkdownDocument != null
                        ? MarkdownEditorScreen(
                            key: ValueKey(_selectedMarkdownDocument!.id),
                            document: _selectedMarkdownDocument!,
                            onBack: () => setState(
                              () => _selectedMarkdownDocument = null,
                            ),
                          )
                        : _buildEmptyState(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.dashboard,
            size: 64,
            color: Theme.of(context).hintColor.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Select an artifact to view content',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }
}
