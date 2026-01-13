import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/domain/entities/tag.dart';

void main() {
  group('Tag', () {
    test('creates with normalized name', () {
      final tag = Tag(projectId: 1, name: '  Machine Learning  ');
      expect(tag.name, 'machine learning');
      expect(tag.usageCount, 0);
    });

    test('throws on empty name', () {
      expect(() => Tag(projectId: 1, name: ''), throwsA(isA<ArgumentError>()));
    });

    test('throws on name exceeding 50 characters', () {
      expect(
        () => Tag(projectId: 1, name: 'a' * 51),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('incrementUsage increases count', () {
      final tag = Tag(projectId: 1, name: 'test');
      tag.incrementUsage();
      tag.incrementUsage();
      expect(tag.usageCount, 2);
    });

    test('decrementUsage decreases count', () {
      final tag = Tag(projectId: 1, name: 'test', usageCount: 3);
      tag.decrementUsage();
      expect(tag.usageCount, 2);
    });

    test('decrementUsage does not go below zero', () {
      final tag = Tag(projectId: 1, name: 'test', usageCount: 0);
      tag.decrementUsage();
      expect(tag.usageCount, 0);
    });
  });
}
