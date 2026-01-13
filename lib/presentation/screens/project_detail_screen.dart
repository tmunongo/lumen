import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen/application/providers.dart';
import 'package:lumen/domain/entities/artifact.dart';
import 'package:lumen/domain/entities/project.dart';
import 'package:lumen/presentation/screens/reader_screen.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final int projectId;

  const ProjectDetailScreen({
    required this.projectId,
    super.key,
  });

  @override
  ConsumerState<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  final _urlController = TextEditingController();
  bool _isIngesting = false;

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

      // Create raw link artifact
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

      // Start ingestion in background
      setState(() => _isIngesting = true);
      final result = await ingestionService.ingest(artifact);
      setState(() => _isIngesting = false);

      if (mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Content fetched successfully')),
          );
          setState(() {}); // Refresh the list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${result.errorMessage}')),
          );
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isIngesting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectService = ref.watch(projectServiceProvider);
    final artifactRepo = ref.watch(artifactRepositoryProvider);

    return FutureBuilder<Project?>(
      future: projectService.getProject(widget.projectId),
      builder: (context, projectSnapshot) {
        if (!projectSnapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final project = projectSnapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text(project.name),
            elevation: 0,
          ),
          body: Column(
            children: [
              // Add link input
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
                        decoration: const InputDecoration(
                          hintText: 'Paste URL to add...',
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
                  future: artifactRepo.findByProject(widget.projectId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final artifacts = snapshot.data!;

                    if (artifacts.isEmpty) {
                      return Center(
                        child: Text(
                          'No artifacts yet.\nAdd a link to get started.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).hintColor,
                              ),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: artifacts.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final artifact = artifacts[index];
                        return ListTile(
                          leading: _getArtifactIcon(artifact),
                          title: Text(artifact.title),
                          subtitle: artifact.sourceUrl != null
                              ? Text(
                                  Uri.parse(artifact.sourceUrl!).host,
                                  style: Theme.of(context).textTheme.bodySmall,
                                )
                              : null,
                          trailing: !artifact.isFetched
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : null,
                          onTap: artifact.isFetched
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ReaderScreen(artifact: artifact),
                                    ),
                                  );
                                }
                              : null,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
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
