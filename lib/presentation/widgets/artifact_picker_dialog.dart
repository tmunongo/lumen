import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen/application/providers.dart';
import 'package:lumen/domain/entities/artifact.dart';
import 'package:lumen/domain/entities/artifact_link.dart';

/// Result of the artifact picker dialog
class LinkPickerResult {
  final Artifact artifact;
  final LinkType type;

  LinkPickerResult({required this.artifact, required this.type});
}

/// Dialog for selecting an artifact to link to with relationship type
class ArtifactPickerDialog extends ConsumerStatefulWidget {
  final int projectId;
  final int? excludeArtifactId;

  const ArtifactPickerDialog({
    required this.projectId,
    this.excludeArtifactId,
    super.key,
  });

  static Future<LinkPickerResult?> show(
    BuildContext context, {
    required int projectId,
    int? excludeArtifactId,
  }) {
    return showDialog<LinkPickerResult>(
      context: context,
      builder: (context) => ArtifactPickerDialog(
        projectId: projectId,
        excludeArtifactId: excludeArtifactId,
      ),
    );
  }

  @override
  ConsumerState<ArtifactPickerDialog> createState() =>
      _ArtifactPickerDialogState();
}

class _ArtifactPickerDialogState extends ConsumerState<ArtifactPickerDialog> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  LinkType _selectedType = LinkType.related;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _getArtifactIcon(ArtifactType type) {
    switch (type) {
      case ArtifactType.webPage:
        return Icons.article;
      case ArtifactType.rawLink:
        return Icons.link;
      case ArtifactType.note:
        return Icons.note;
      case ArtifactType.quote:
        return Icons.format_quote;
      case ArtifactType.image:
        return Icons.image;
      case ArtifactType.markdown:
        return Icons.edit_document;
    }
  }

  IconData _getLinkTypeIcon(LinkType type) {
    switch (type) {
      case LinkType.related:
        return Icons.link;
      case LinkType.supports:
        return Icons.thumb_up_outlined;
      case LinkType.contradicts:
        return Icons.thumb_down_outlined;
      case LinkType.background:
        return Icons.menu_book_outlined;
      case LinkType.quotes:
        return Icons.format_quote;
      case LinkType.dependsOn:
        return Icons.account_tree_outlined;
    }
  }

  String _getLinkTypeLabel(LinkType type) {
    switch (type) {
      case LinkType.related:
        return 'Related';
      case LinkType.supports:
        return 'Supports';
      case LinkType.contradicts:
        return 'Contradicts';
      case LinkType.background:
        return 'Background';
      case LinkType.quotes:
        return 'Quotes';
      case LinkType.dependsOn:
        return 'Depends On';
    }
  }

  @override
  Widget build(BuildContext context) {
    final artifactRepo = ref.watch(artifactRepositoryProvider);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.link),
                      const SizedBox(width: 8),
                      Text(
                        'Link to Artifact',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Link type selector
                  Text(
                    'Relationship Type',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: LinkType.values.map((type) {
                        final isSelected = type == _selectedType;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            avatar: Icon(
                              _getLinkTypeIcon(type),
                              size: 18,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : null,
                            ),
                            label: Text(_getLinkTypeLabel(type)),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() => _selectedType = type);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search field
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search artifacts...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value.toLowerCase());
                    },
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Artifact list
            Expanded(
              child: FutureBuilder<List<Artifact>>(
                future: artifactRepo.findByProject(widget.projectId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var artifacts = snapshot.data!;

                  // Exclude the source artifact
                  if (widget.excludeArtifactId != null) {
                    artifacts = artifacts
                        .where((a) => a.id != widget.excludeArtifactId)
                        .toList();
                  }

                  // Apply search filter
                  if (_searchQuery.isNotEmpty) {
                    artifacts = artifacts.where((a) {
                      return a.title.toLowerCase().contains(_searchQuery) ||
                          a.tags.any((tag) => tag.contains(_searchQuery));
                    }).toList();
                  }

                  if (artifacts.isEmpty) {
                    return Center(
                      child: Text(
                        _searchQuery.isEmpty
                            ? 'No other artifacts in this project'
                            : 'No artifacts match your search',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                      return ListTile(
                        leading: Icon(_getArtifactIcon(artifact.type)),
                        title: Text(
                          artifact.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: artifact.tags.isNotEmpty
                            ? Text(
                                artifact.tags.join(', '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                        onTap: () => Navigator.pop(
                          context,
                          LinkPickerResult(
                            artifact: artifact,
                            type: _selectedType,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
