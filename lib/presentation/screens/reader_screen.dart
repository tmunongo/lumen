import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen/domain/entities/artifact.dart';
import 'package:lumen/presentation/theme/reader_theme.dart';
import 'package:lumen/presentation/widgets/reader_content.dart';
import 'package:lumen/presentation/widgets/reader_toolbar.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  final Artifact artifact;

  const ReaderScreen({required this.artifact, super.key});

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showToolbar = true;
  double _scrollProgress = 0.0;

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Theme(
      data: isDark
          ? ReaderTheme.darkReaderTheme()
          : ReaderTheme.lightReaderTheme(),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: Scaffold(
          body: Stack(
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
                  // Minimal app bar
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    actions: [
                      IconButton(
                        icon: Icon(
                          _showToolbar ? Icons.expand_more : Icons.expand_less,
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
                                style: Theme.of(context).textTheme.displayLarge,
                              ),

                              const SizedBox(height: 16),

                              // Metadata
                              if (widget.artifact.sourceUrl != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    Uri.parse(widget.artifact.sourceUrl!).host,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: isDark
                                              ? ReaderTheme.darkTextSecondary
                                              : ReaderTheme.lightTextSecondary,
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
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: isDark
                                              ? ReaderTheme.darkTextSecondary
                                              : ReaderTheme.lightTextSecondary,
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

                              // Content
                              if (widget.artifact.content != null)
                                ReaderContent(
                                  html: widget.artifact.content!,
                                  baseUrl: widget.artifact.sourceUrl,
                                )
                              else
                                Text(
                                  'No content available',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: isDark
                                            ? ReaderTheme.darkTextSecondary
                                            : ReaderTheme.lightTextSecondary,
                                      ),
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
      ),
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
