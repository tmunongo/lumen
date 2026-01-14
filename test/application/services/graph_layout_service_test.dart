import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/application/services/graph_layout_service.dart';

void main() {
  group('GraphLayoutService', () {
    final service = GraphLayoutService();

    test('calculates layout for center node only', () {
      final layout = service.calculateRadialLayout(
        centerId: 1,
        neighborIds: [],
        size: const Size(200, 200),
      );

      expect(layout.length, 1);
      final center = layout[1]!;
      expect(center.isCenter, true);
      expect(center.position, const Offset(100, 100));
    });

    test('calculates layout for center and neighbors', () {
      final layout = service.calculateRadialLayout(
        centerId: 1,
        neighborIds: [2, 3, 4, 5],
        size: const Size(200, 200),
      );

      expect(layout.length, 5); // 1 center + 4 neighbors
      
      final center = layout[1]!;
      expect(center.isCenter, true);
      expect(center.position, const Offset(100, 100));

      final neighbors = layout.entries.where((e) => !e.value.isCenter).toList();
      expect(neighbors.length, 4);
      
      // Verify neighbors are equidistant from center (approximately)
      // Radius = min(200, 200) / 3 = 66.66
      const expectedRadius = 200.0 / 3;
      
      for (final neighbor in neighbors) {
        final dist = (neighbor.value.position - center.position).distance;
        expect(dist, closeTo(expectedRadius, 0.001));
      }
    });
  });
}
