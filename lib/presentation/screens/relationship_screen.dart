import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen/application/providers.dart';
import 'package:lumen/application/services/relationship_service.dart';
import 'package:lumen/domain/entities/artifact.dart';
import 'package:lumen/domain/entities/artifact_link.dart';
import 'package:lumen/domain/models/artifact_relationship.dart';

class RelationshipsScreen extends ConsumerStatefulWidget {
  final int projectId;
  final Artifact? initialArtifact;

  const RelationshipsScreen({
    required this.projectId,
    this.initialArtifact,
    super.key,
  });

  @override
  ConsumerState<RelationshipsScreen> createState() =>
      _RelationshipsScreenState();
}

class _RelationshipsScreenState extends ConsumerState<RelationshipsScreen> {
  Artifact? _selectedArtifact;
  bool _showNetworkView = false;

  @override
  void initState() {
    super.initState();
    _selectedArtifact = widget.initialArtifact;
  }

  @override
  Widget build(BuildContext context) {
    final artifactRepo = ref.watch(artifactRepositoryProvider);
    final relationshipService = ref.watch(relationshipServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relationships'),
        actions: [
          IconButton(
            icon: Icon(_showNetworkView ? Icons.list : Icons.hub),
            tooltip: _showNetworkView ? 'List View' : 'Network View',
            onPressed: () {
              setState(() => _showNetworkView = !_showNetworkView);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Artifact>>(
        future: artifactRepo.findByProject(widget.projectId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final artifacts = snapshot.data!;

          if (artifacts.isEmpty) {
            return const Center(child: Text('No artifacts in this project'));
          }

          if (_selectedArtifact == null) {
            return _ArtifactSelector(
              artifacts: artifacts,
              onSelect: (artifact) {
                setState(() => _selectedArtifact = artifact);
              },
            );
          }

          if (_showNetworkView) {
            return _NetworkView(
              anchor: _selectedArtifact!,
              artifacts: artifacts,
              relationshipService: relationshipService,
              onArtifactTap: (artifact) {
                setState(() => _selectedArtifact = artifact);
              },
              onBack: () {
                setState(() => _selectedArtifact = null);
              },
            );
          }

          return _RelationshipView(
            anchor: _selectedArtifact!,
            artifacts: artifacts,
            relationshipService: relationshipService,
            onArtifactTap: (artifact) {
              setState(() => _selectedArtifact = artifact);
            },
            onBack: () {
              setState(() => _selectedArtifact = null);
            },
          );
        },
      ),
    );
  }
}

class _ArtifactSelector extends StatelessWidget {
  final List<Artifact> artifacts;
  final Function(Artifact) onSelect;

  const _ArtifactSelector({required this.artifacts, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Select an artifact to explore its relationships',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: artifacts.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final artifact = artifacts[index];
              return ListTile(
                leading: _getIcon(artifact),
                title: Text(artifact.title),
                subtitle: artifact.tags.isNotEmpty
                    ? Text('Tags: ${artifact.tags.join(", ")}')
                    : null,
                onTap: () => onSelect(artifact),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _getIcon(Artifact artifact) {
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

class _RelationshipView extends ConsumerStatefulWidget {
  final Artifact anchor;
  final List<Artifact> artifacts;
  final RelationshipService relationshipService;
  final Function(Artifact) onArtifactTap;
  final VoidCallback onBack;

  const _RelationshipView({
    required this.anchor,
    required this.artifacts,
    required this.relationshipService,
    required this.onArtifactTap,
    required this.onBack,
  });

  @override
  ConsumerState<_RelationshipView> createState() => _RelationshipViewState();
}

class _RelationshipViewState extends ConsumerState<_RelationshipView> {
  late Artifact _currentAnchor;

  @override
  void initState() {
    super.initState();
    _currentAnchor = widget.anchor;
  }

  @override
  void didUpdateWidget(_RelationshipView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.anchor.id != widget.anchor.id) {
      _currentAnchor = widget.anchor;
    }
  }

  Future<void> _addTagToArtifact(String tag) async {
    try {
      final artifactService = ref.read(artifactServiceProvider);
      final artifactRepo = ref.read(artifactRepositoryProvider);
      
      // Add the tag to the artifact
      await artifactService.addTagsToArtifact(_currentAnchor, [tag]);
      
      // Refresh the artifact to get updated tags
      final updatedArtifact = await artifactRepo.findById(_currentAnchor.id);
      if (updatedArtifact != null) {
        setState(() {
          _currentAnchor = updatedArtifact;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added tag "$tag" to ${_currentAnchor.title}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add tag: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cluster = widget.relationshipService.findRelatedArtifacts(
      _currentAnchor,
      widget.artifacts,
    );
    final suggestions = widget.relationshipService.suggestTags(
      _currentAnchor,
      widget.artifacts,
    );
    final linkService = ref.watch(linkServiceProvider);

    return Column(
      children: [
        // Anchor artifact card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: widget.onBack,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _currentAnchor.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_currentAnchor.tags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: _currentAnchor.tags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              const SizedBox(height: 8),
              Text(
                '${cluster.totalRelated} related artifacts',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),

        // Suggested tags
        if (suggestions.isNotEmpty)
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Suggested tags',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: suggestions.map((tag) {
                    return ActionChip(
                      label: Text(tag),
                      avatar: const Icon(Icons.add, size: 16),
                      onPressed: () => _addTagToArtifact(tag),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

        // Related artifacts list (with explicit links)
        Expanded(
          child: FutureBuilder<List<List<dynamic>>>(
            future: Future.wait([
              linkService.getOutgoingLinksWithArtifacts(_currentAnchor.id),
              linkService.getIncomingLinksWithArtifacts(_currentAnchor.id),
            ]),
            builder: (context, linkSnapshot) {
              final outgoingLinks = linkSnapshot.data?[0] as List<({ArtifactLink link, Artifact artifact})>? ?? [];
              final backlinks = linkSnapshot.data?[1] as List<({ArtifactLink link, Artifact artifact})>? ?? [];
              
              final hasExplicitLinks = outgoingLinks.isNotEmpty || backlinks.isNotEmpty;
              final hasTagRelations = cluster.totalRelated > 0;
              
              if (!hasExplicitLinks && !hasTagRelations) {
                return Center(
                  child: Text(
                    'No related artifacts found',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                );
              }

              return ListView(
                children: [
                  // Explicit outgoing links
                  if (outgoingLinks.isNotEmpty) ...[
                    _ExplicitLinkSection(
                      title: 'Linked To',
                      icon: Icons.arrow_forward,
                      links: outgoingLinks,
                      onTap: widget.onArtifactTap,
                      onRemove: (link) => _removeLink(link.sourceArtifactId, link.targetArtifactId),
                    ),
                  ],
                  
                  // Backlinks (incoming)
                  if (backlinks.isNotEmpty) ...[
                    _ExplicitLinkSection(
                      title: 'Backlinks',
                      icon: Icons.arrow_back,
                      links: backlinks,
                      onTap: widget.onArtifactTap,
                      isBacklink: true,
                    ),
                  ],
                  
                  // Tag-based relationships
                  if (cluster.strongRelationships.isNotEmpty) ...[
                    _RelationshipSection(
                      title: 'Strong Connections (by tags)',
                      relationships: cluster.strongRelationships,
                      onTap: widget.onArtifactTap,
                    ),
                  ],
                  if (cluster.mediumRelationships.isNotEmpty) ...[
                    _RelationshipSection(
                      title: 'Medium Connections (by tags)',
                      relationships: cluster.mediumRelationships,
                      onTap: widget.onArtifactTap,
                    ),
                  ],
                  if (cluster.weakRelationships.isNotEmpty) ...[
                    _RelationshipSection(
                      title: 'Weak Connections (by tags)',
                      relationships: cluster.weakRelationships,
                      onTap: widget.onArtifactTap,
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _removeLink(int sourceId, int targetId) async {
    try {
      final linkService = ref.read(linkServiceProvider);
      await linkService.removeLink(sourceId, targetId);
      setState(() {}); // Trigger rebuild
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link removed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove link: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

/// Widget for displaying explicit artifact links (outgoing or backlinks)
class _ExplicitLinkSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<({ArtifactLink link, Artifact artifact})> links;
  final Function(Artifact) onTap;
  final Function(ArtifactLink)? onRemove;
  final bool isBacklink;

  const _ExplicitLinkSection({
    required this.title,
    required this.icon,
    required this.links,
    required this.onTap,
    this.onRemove,
    this.isBacklink = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${links.length}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...links.map((pair) {
          final artifact = pair.artifact;
          final link = pair.link;
          return ListTile(
            leading: _getIcon(artifact),
            title: Text(artifact.title),
            subtitle: Row(
              children: [
                Icon(
                  _getLinkTypeIcon(link.type),
                  size: 14,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  link.typeLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (artifact.tags.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text('•', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      artifact.tags.join(', '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ],
            ),
            trailing: onRemove != null && !isBacklink
                ? IconButton(
                    icon: const Icon(Icons.link_off, size: 20),
                    tooltip: 'Remove link',
                    onPressed: () => onRemove!(link),
                  )
                : isBacklink
                    ? const Tooltip(
                        message: 'Linked from this artifact',
                        child: Icon(Icons.subdirectory_arrow_left, size: 20),
                      )
                    : null,
            onTap: () => onTap(artifact),
          );
        }),
        const Divider(height: 1),
      ],
    );
  }

  Widget _getIcon(Artifact artifact) {
    IconData iconData;
    switch (artifact.type) {
      case ArtifactType.webPage:
        iconData = Icons.article;
      case ArtifactType.rawLink:
        iconData = Icons.link;
      case ArtifactType.note:
        iconData = Icons.note;
      case ArtifactType.quote:
        iconData = Icons.format_quote;
      case ArtifactType.image:
        iconData = Icons.image;
    }
    return Icon(iconData);
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
}

class _RelationshipSection extends StatelessWidget {
  final String title;
  final List<ArtifactRelationship> relationships;
  final Function(Artifact) onTap;

  const _RelationshipSection({
    required this.title,
    required this.relationships,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        ...relationships.map((rel) {
          return ListTile(
            leading: _getIcon(rel.target),
            title: Text(rel.target.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Shared: ${rel.sharedTags.join(", ")}'),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: rel.strength,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                ),
              ],
            ),
            trailing: Text(
              '${(rel.strength * 100).round()}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            onTap: () => onTap(rel.target),
          );
        }),
        const Divider(height: 1),
      ],
    );
  }

  Widget _getIcon(Artifact artifact) {
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

class _NetworkView extends StatelessWidget {
  final Artifact anchor;
  final List<Artifact> artifacts;
  final RelationshipService relationshipService;
  final Function(Artifact) onArtifactTap;
  final VoidCallback onBack;

  const _NetworkView({
    required this.anchor,
    required this.artifacts,
    required this.relationshipService,
    required this.onArtifactTap,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final network = relationshipService.findConnectedNetwork(anchor, artifacts);
    final bridges = relationshipService
        .findBridgeArtifacts(artifacts)
        .where((a) => network.contains(a))
        .toList();

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connected Network',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '${network.length} artifacts in this cluster',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Bridge artifacts section
        if (bridges.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.hub, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Bridge Artifacts',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'These artifacts connect different topic areas',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

        // Network list
        Expanded(
          child: ListView.separated(
            itemCount: network.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final artifact = network[index];
              final isBridge = bridges.contains(artifact);
              final isAnchor = artifact.id == anchor.id;

              return ListTile(
                leading: Stack(
                  children: [
                    _getIcon(artifact),
                    if (isBridge)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                title: Text(
                  artifact.title,
                  style: isAnchor
                      ? TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                ),
                subtitle: artifact.tags.isNotEmpty
                    ? Text('Tags: ${artifact.tags.join(", ")}')
                    : null,
                trailing: isAnchor ? const Icon(Icons.star) : null,
                onTap: () => onArtifactTap(artifact),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _getIcon(Artifact artifact) {
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
