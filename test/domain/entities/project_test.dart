import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/domain/entities/project.dart';

void main() {
  group('Project', () {
    test('creates with valid name', () {
      final project = Project(name: 'AI Research');
      expect(project.name, 'AI Research');
      expect(project.isArchived, false);
      expect(project.createdAt, isNotNull);
      expect(project.modifiedAt, isNotNull);
    });

    test('throws on empty name', () {
      expect(() => Project(name: ''), throwsA(isA<ArgumentError>()));
      expect(() => Project(name: '   '), throwsA(isA<ArgumentError>()));
    });

    test('throws on name exceeding 200 characters', () {
      expect(() => Project(name: 'a' * 201), throwsA(isA<ArgumentError>()));
    });

    test('rename updates name and modifiedAt', () {
      final project = Project(name: 'Original');
      final originalModified = project.modifiedAt;

      // Small delay to ensure timestamp difference
      Future.delayed(Duration(milliseconds: 10));

      project.rename('Updated');
      expect(project.name, 'Updated');
      expect(project.modifiedAt!.isAfter(originalModified!), true);
    });

    test('rename validates new name', () {
      final project = Project(name: 'Valid');
      expect(() => project.rename(''), throwsA(isA<ArgumentError>()));
    });

    test('archive sets flag and touches modifiedAt', () {
      final project = Project(name: 'Test');
      project.archive();
      expect(project.isArchived, true);
    });

    test('unarchive clears flag', () {
      final project = Project(name: 'Test')..archive();
      project.unarchive();
      expect(project.isArchived, false);
    });
  });
}
