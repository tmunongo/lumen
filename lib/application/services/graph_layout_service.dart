import 'dart:math';
import 'package:flutter/material.dart';

/// Models a node in the graph for layout purposes
class GraphNode {
  final int id;
  final Offset position;
  final double radius;
  final bool isCenter;

  GraphNode({
    required this.id,
    required this.position,
    this.radius = 20.0,
    this.isCenter = false,
  });
}

/// Service responsible for calculating positions of nodes in the graph
class GraphLayoutService {
  /// Calculate a simple radial layout for a central node and its neighbors
  Map<int, GraphNode> calculateRadialLayout({
    required int centerId,
    required List<int> neighborIds,
    required Size size,
    double centerRadius = 30.0,
    double nodeRadius = 20.0,
  }) {
    final nodes = <int, GraphNode>{};
    final center = Offset(size.width / 2, size.height / 2);

    // Place center node
    nodes[centerId] = GraphNode(
      id: centerId,
      position: center,
      radius: centerRadius,
      isCenter: true,
    );

    if (neighborIds.isEmpty) return nodes;

    // Place neighbors in a circle
    // Use a fixed distance or dynamic based on available space
    final orbitRadius = min(size.width, size.height) / 3;
    final angleStep = (2 * pi) / neighborIds.length;

    // Start from -pi/2 (12 o'clock)
    var currentAngle = -pi / 2;

    for (final neighborId in neighborIds) {
      final x = center.dx + orbitRadius * cos(currentAngle);
      final y = center.dy + orbitRadius * sin(currentAngle);

      nodes[neighborId] = GraphNode(
        id: neighborId,
        position: Offset(x, y),
        radius: nodeRadius,
      );

      currentAngle += angleStep;
    }

    return nodes;
  }
}
