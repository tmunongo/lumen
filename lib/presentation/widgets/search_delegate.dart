import 'package:flutter/material.dart';
import 'package:lumen/domain/entities/artifact.dart';

class ArtifactSearchDelegate extends SearchDelegate<Artifact?> {
  final List<Artifact> artifacts;
  final Function(Artifact) onSelected;

  ArtifactSearchDelegate({required this.artifacts, required this.onSelected});

  @override
  String get searchFieldLabel => 'Search artifacts...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Search by title, tags, or content',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    final results = _search(query.toLowerCase());

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final artifact = results[index];
        return ListTile(
          leading: _getIcon(artifact),
          title: _buildHighlightedText(artifact.title, query),
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
                    children: artifact.tags
                        .where((tag) {
                          return tag.contains(query.toLowerCase());
                        })
                        .take(3)
                        .map((tag) {
                          return Chip(
                            label: _buildHighlightedText(tag, query),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                          );
                        })
                        .toList(),
                  ),
                ),
            ],
          ),
          onTap: () {
            close(context, artifact);
            onSelected(artifact);
          },
        );
      },
    );
  }

  List<Artifact> _search(String query) {
    return artifacts.where((artifact) {
      // Search in title
      if (artifact.title.toLowerCase().contains(query)) {
        return true;
      }

      // Search in tags
      if (artifact.tags.any((tag) => tag.contains(query))) {
        return true;
      }

      // Search in content (limited)
      if (artifact.content != null) {
        final contentPreview = artifact.content!.toLowerCase();
        if (contentPreview.contains(query)) {
          return true;
        }
      }

      return false;
    }).toList();
  }

  Widget _buildHighlightedText(String text, String query) {
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);

    if (index == -1) {
      return Text(text);
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black87),
        children: [
          TextSpan(text: text.substring(0, index)),
          TextSpan(
            text: text.substring(index, index + query.length),
            style: const TextStyle(
              backgroundColor: Colors.yellow,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: text.substring(index + query.length)),
        ],
      ),
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
