import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen/application/providers.dart';
import 'package:lumen/domain/entities/artifact.dart';
import 'package:lumen/domain/entities/artifact_link.dart';
import 'package:lumen/presentation/screens/reader_screen.dart';
import 'package:lumen/presentation/theme/reader_theme.dart';
import 'package:lumen/presentation/widgets/inline_graph_widget.dart';

class ConnectionsPanel extends ConsumerWidget {
  final Artifact artifact;

  const ConnectionsPanel({super.key, required this.artifact});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linkService = ref.watch(linkServiceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? ReaderTheme.darkSurface : ReaderTheme.lightSurface,
      width: 400, // Drawer width
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? ReaderTheme.darkBorder
                      : ReaderTheme.lightBorder,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.hub,
                  color: isDark
                      ? ReaderTheme.darkTextSecondary
                      : ReaderTheme.lightTextSecondary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Connections',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Close',
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: FutureBuilder<List<List<dynamic>>>(
              future: Future.wait([
                linkService.getOutgoingLinksWithArtifacts(artifact.id),
                linkService.getIncomingLinksWithArtifacts(artifact.id),
              ]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: Text('No connections found'));
                }

                final outgoing =
                    snapshot.data![0]
                        as List<({ArtifactLink link, Artifact artifact})>;
                final incoming =
                    snapshot.data![1]
                        as List<({ArtifactLink link, Artifact artifact})>;
                final allLinks = [...outgoing, ...incoming];

                if (allLinks.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.hub_outlined,
                            size: 48,
                            color: isDark
                                ? ReaderTheme.darkTextSecondary.withValues(
                                    alpha: 0.5,
                                  )
                                : ReaderTheme.lightTextSecondary.withValues(
                                    alpha: 0.5,
                                  ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No connections yet',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: isDark
                                      ? ReaderTheme.darkTextSecondary
                                      : ReaderTheme.lightTextSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      InlineGraphWidget(
                        centerArtifact: artifact,
                        connectedArtifacts: allLinks,
                        height: 300,
                        onArtifactTap: (tappedArtifact) {
                          // Close drawer and navigate
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ReaderScreen(artifact: tappedArtifact),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      // List view of connections for accessibility/details
                      ...allLinks.map((linkData) {
                        return ListTile(
                          leading: const Icon(Icons.article_outlined, size: 20),
                          title: Text(
                            linkData.artifact.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            linkData.link.sourceArtifactId == artifact.id
                                ? 'Outgoing'
                                : 'Incoming',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          dense: true,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ReaderScreen(artifact: linkData.artifact),
                              ),
                            );
                          },
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
