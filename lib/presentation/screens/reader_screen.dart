import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen/application/providers.dart';
import 'package:lumen/application/services/highlight_service.dart';
import 'package:lumen/domain/entities/artifact.dart';
import 'package:lumen/presentation/theme/reader_theme.dart';
import 'package:lumen/presentation/widgets/connections_panel.dart';
import 'package:lumen/presentation/widgets/reader_content.dart';
import 'package:lumen/presentation/widgets/reader_toolbar.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  final Artifact artifact;
  final bool showBackButton;
  final VoidCallback? onBack;

  const ReaderScreen({
    required this.artifact,
    this.showBackButton = true,
    this.onBack,
    super.key,
  });

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showToolbar = true;
  double _scrollProgress = 0.0;
  SelectedContent? _currentSelection;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    setState(() {
      _scrollProgress = maxScroll > 0 ? currentScroll / maxScroll : 0.0;
    });
  }

  void _toggleToolbar() {
    setState(() {
      _showToolbar = !_showToolbar;
    });
  }

  // ... (imports need check, but this is replace)

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final highlightService = ref.watch(highlightServiceProvider);

    return Theme(
      data: isDark
          ? ReaderTheme.darkReaderTheme()
          : ReaderTheme.lightReaderTheme(),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: Scaffold(
          body: SelectionArea(
            onSelectionChanged: (selection) {
              _currentSelection = selection;
            },
            contextMenuBuilder: (context, editableTextState) {
              return AdaptiveTextSelectionToolbar.buttonItems(
                anchors: editableTextState.contextMenuAnchors,
                buttonItems: [
                  ...editableTextState.contextMenuButtonItems,
                  ContextMenuButtonItem(
                    onPressed: () {
                      final text = _currentSelection?.plainText;
                      if (text != null && text.isNotEmpty) {
                        highlightService
                            .addHighlight(
                              artifactId: widget.artifact.id,
                              selectedText: text,
                            )
                            .then((_) {
                              editableTextState.hideToolbar();
                              setState(() {}); // Refresh to show highlight
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Highlight added'),
                                  ),
                                );
                              }
                            });
                      }
                    },
                    label: 'Highlight',
                  ),
                ],
              );
            },
            child: Stack(
              children: [
                // Reading progress indicator
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    value: _scrollProgress,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation(
                      isDark ? ReaderTheme.darkAccent : ReaderTheme.lightAccent,
                    ),
                    minHeight: 2,
                  ),
                ),

                // Main content
                CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    // Minimal app bar with back button support
                    SliverAppBar(
                      floating: true,
                      snap: true,
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      leading: widget.showBackButton
                          ? IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed:
                                  widget.onBack ?? () => Navigator.pop(context),
                            )
                          : null,
                      actions: [
                        Builder(
                          builder: (context) {
                            return IconButton(
                              icon: const Icon(Icons.hub),
                              onPressed: () {
                                Scaffold.of(context).openEndDrawer();
                              },
                              tooltip: 'Connections',
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            _showToolbar
                                ? Icons.expand_more
                                : Icons.expand_less,
                          ),
                          onPressed: _toggleToolbar,
                        ),
                      ],
                    ),

                    // Article content
                    SliverToBoxAdapter(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 720),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 32,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Article title
                                Text(
                                  widget.artifact.title,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.displayLarge,
                                ),

                                const SizedBox(height: 16),

                                // Metadata
                                if (widget.artifact.sourceUrl != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      Uri.parse(
                                        widget.artifact.sourceUrl!,
                                      ).host,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: isDark
                                                ? ReaderTheme.darkTextSecondary
                                                : ReaderTheme
                                                      .lightTextSecondary,
                                          ),
                                    ),
                                  ),

                                // Reading time and date
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: isDark
                                          ? ReaderTheme.darkTextSecondary
                                          : ReaderTheme.lightTextSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDate(widget.artifact.createdAt!),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: isDark
                                                ? ReaderTheme.darkTextSecondary
                                                : ReaderTheme
                                                      .lightTextSecondary,
                                          ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 32),

                                Divider(
                                  color: isDark
                                      ? ReaderTheme.darkBorder
                                      : ReaderTheme.lightBorder,
                                ),

                                const SizedBox(height: 32),

                                // Content with Highlights
                                FutureBuilder(
                                  future: highlightService
                                      .getHighlightsForArtifact(
                                        widget.artifact.id,
                                      ),
                                  builder: (context, snapshot) {
                                    final highlights = snapshot.data ?? [];

                                    if (widget.artifact.type ==
                                        ArtifactType.quote) {
                                      return _QuoteContent(
                                        artifact: widget.artifact,
                                      );
                                    } else if (widget.artifact.type ==
                                        ArtifactType.note) {
                                      return _NoteContent(
                                        artifact: widget.artifact,
                                      );
                                    } else if (widget.artifact.type ==
                                        ArtifactType.image) {
                                      return _ImageContent(
                                        artifact: widget.artifact,
                                      );
                                    } else if (widget.artifact.content !=
                                        null) {
                                      // Inject highlights
                                      final contentWithHighlights =
                                          highlightService.injectHighlights(
                                            widget.artifact.content!,
                                            highlights,
                                          );

                                      return ReaderContent(
                                        html: contentWithHighlights,
                                        baseUrl: widget.artifact.sourceUrl,
                                        onHighlightTap: (id) =>
                                            _showHighlightOptions(
                                              context,
                                              id,
                                              highlightService,
                                            ),
                                      );
                                    } else {
                                      return Text(
                                        'No content available',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: isDark
                                                  ? ReaderTheme
                                                        .darkTextSecondary
                                                  : ReaderTheme
                                                        .lightTextSecondary,
                                            ),
                                      );
                                    }
                                  },
                                ),

                                const SizedBox(height: 64),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Toolbar overlay
                if (_showToolbar)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: ReaderToolbar(artifact: widget.artifact),
                  ),
              ],
            ),
          ),
          endDrawer: ConnectionsPanel(artifact: widget.artifact),
        ),
      ),
    );
  }

  Future<void> _showHighlightOptions(
    BuildContext context,
    int highlightId,
    HighlightService service,
  ) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Highlight'),
                textColor: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  service.removeHighlight(highlightId).then((_) {
                    if (mounted) {
                      setState(() {}); // Refresh content
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Highlight removed')),
                      );
                    }
                  });
                },
              ),
              // We can add "Add Note" here later
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _QuoteContent extends StatelessWidget {
  final Artifact artifact;

  const _QuoteContent({required this.artifact});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? ReaderTheme.darkSurface : ReaderTheme.lightSurface,
        border: Border(
          left: BorderSide(
            color: isDark ? ReaderTheme.darkAccent : ReaderTheme.lightAccent,
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.format_quote,
            size: 32,
            color: isDark
                ? ReaderTheme.darkTextSecondary
                : ReaderTheme.lightTextSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            artifact.content ?? '',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 16),
          Text(
            '— ${artifact.attribution}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? ReaderTheme.darkTextSecondary
                  : ReaderTheme.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteContent extends StatelessWidget {
  final Artifact artifact;

  const _NoteContent({required this.artifact});

  @override
  Widget build(BuildContext context) {
    return Text(
      artifact.content ?? '',
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}

class _ImageContent extends StatelessWidget {
  final Artifact artifact;

  const _ImageContent({required this.artifact});

  @override
  Widget build(BuildContext context) {
    if (artifact.localAssetPath == null) {
      return const Center(child: Text('Image file not found'));
    }

    return Center(
      child: InteractiveViewer(
        maxScale: 4.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(artifact.localAssetPath!),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
