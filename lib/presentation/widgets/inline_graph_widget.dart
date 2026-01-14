import 'package:flutter/material.dart';
import 'package:lumen/application/services/graph_layout_service.dart';
import 'package:lumen/domain/entities/artifact.dart';
import 'package:lumen/domain/entities/artifact_link.dart';

class InlineGraphNode {
  final Artifact artifact;
  final LinkType? linkType;
  final bool isCenter;

  InlineGraphNode({
    required this.artifact,
    this.linkType,
    this.isCenter = false,
  });
}

class InlineGraphWidget extends StatefulWidget {
  final Artifact centerArtifact;
  final List<({ArtifactLink link, Artifact artifact})> connectedArtifacts;
  final Function(Artifact) onArtifactTap;
  final double height;

  const InlineGraphWidget({
    required this.centerArtifact,
    required this.connectedArtifacts,
    required this.onArtifactTap,
    this.height = 250,
    super.key,
  });

  @override
  State<InlineGraphWidget> createState() => _InlineGraphWidgetState();
}

class _InlineGraphWidgetState extends State<InlineGraphWidget>
    with SingleTickerProviderStateMixin {
  late GraphLayoutService _layoutService;
  Map<int, GraphNode>? _layout;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _layoutService = GraphLayoutService();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, widget.height);
          
          // Calculate layout if not already done or size changed
          // In a real app we might want to memoize this better
          final neighborIds = widget.connectedArtifacts
              .map((e) => e.artifact.id)
              .toList();
          
          _layout = _layoutService.calculateRadialLayout(
            centerId: widget.centerArtifact.id,
            neighborIds: neighborIds,
            size: size,
            centerRadius: 30,
            nodeRadius: 22,
          );

          return GestureDetector(
            onTapUp: (details) => _handleTap(details, _layout!),
            child: CustomPaint(
              painter: GraphPainter(
                layout: _layout!,
                centerArtifact: widget.centerArtifact,
                connectedArtifacts: widget.connectedArtifacts,
                theme: Theme.of(context),
                animationValue: _scaleAnimation,
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleTap(TapUpDetails details, Map<int, GraphNode> layout) {
    final tapPosition = details.localPosition;
    
    // Check if we hit any node
    for (final node in layout.values) {
      final distance = (node.position - tapPosition).distance;
      if (distance <= node.radius + 10) { // Add some padding for easier taps
        if (node.id == widget.centerArtifact.id) {
          // Tapped center, maybe do nothing or show details?
        } else {
          // Find the artifact
          final connected = widget.connectedArtifacts.firstWhere(
            (e) => e.artifact.id == node.id,
            orElse: () => throw Exception('Artifact not found'),
          );
          widget.onArtifactTap(connected.artifact);
        }
        return;
      }
    }
  }
}

class GraphPainter extends CustomPainter {
  final Map<int, GraphNode> layout;
  final Artifact centerArtifact;
  final List<({ArtifactLink link, Artifact artifact})> connectedArtifacts;
  final ThemeData theme;
  final Animation<double> animationValue;

  GraphPainter({
    required this.layout,
    required this.centerArtifact,
    required this.connectedArtifacts,
    required this.theme,
    required this.animationValue,
  }) : super(repaint: animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final centerNode = layout[centerArtifact.id]!;
    final scale = animationValue.value;

    // Draw edges
    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final connected in connectedArtifacts) {
      final node = layout[connected.artifact.id];
      if (node != null) {
        edgePaint.color = _getLinkColor(connected.link.type).withValues(alpha: 0.5);
        
        // Draw line from center to node, animated length could be cool but scaling the whole graph is simpler
        final p1 = centerNode.position;
        final p2 = Offset.lerp(p1, node.position, scale)!;
        
        canvas.drawLine(p1, p2, edgePaint);
      }
    }

    // Draw nodes
    for (final entry in layout.entries) {
      final node = entry.value;
      if (node.isCenter) {
        _drawNode(canvas, node, centerArtifact, null, scale); // Center always 1.0 or separate animation?
      } else {
        // Find artifacts
        final connected = connectedArtifacts.firstWhere((e) => e.artifact.id == node.id);
        _drawNode(canvas, node, connected.artifact, connected.link.type, scale);
      }
    }
  }

  void _drawNode(
    Canvas canvas, 
    GraphNode node, 
    Artifact artifact, 
    LinkType? type, 
    double scale
  ) {
    // Determine colors
    final color = type != null 
        ? _getLinkColor(type) 
        : theme.colorScheme.primary;
    
    final bgPaint = Paint()
      ..color = theme.colorScheme.surface
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = node.isCenter ? 3.0 : 2.0;

    final position = node.isCenter 
        ? node.position 
        : Offset.lerp(layout[centerArtifact.id]!.position, node.position, scale)!;

    // Draw circle background & border
    canvas.drawCircle(position, node.radius, bgPaint);
    canvas.drawCircle(position, node.radius, borderPaint);

    // Draw Icon
    final icon = _getArtifactIcon(artifact.type);
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: node.radius * 1.2,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas, 
      position - Offset(textPainter.width / 2, textPainter.height / 2),
    );

    // Draw Title (only for satellites)
    if (!node.isCenter) {
      final titlePainter = TextPainter(
        text: TextSpan(
          text: artifact.title,
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 10,
            color: theme.colorScheme.onSurface,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '...',
      );
      titlePainter.layout(maxWidth: 80);
      titlePainter.paint(
        canvas,
        position + Offset(-titlePainter.width / 2, node.radius + 4),
      );
    }
  }

  Color _getLinkColor(LinkType type) {
    switch (type) {
      case LinkType.related:
        return Colors.grey;
      case LinkType.supports:
        return Colors.green;
      case LinkType.contradicts:
        return Colors.red;
      case LinkType.background:
        return Colors.blue;
      case LinkType.quotes:
        return Colors.purple;
      case LinkType.dependsOn:
        return Colors.orange;
    }
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
    }
  }

  @override
  bool shouldRepaint(covariant GraphPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.layout != layout;
  }
}
