import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen/application/providers.dart';
import 'package:lumen/domain/entities/project.dart';

class ProjectDetailScreen extends ConsumerWidget {
  final int projectId;

  const ProjectDetailScreen({required this.projectId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(projectServiceProvider);

    return FutureBuilder<Project?>(
      future: service.getProject(projectId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final project = snapshot.data;
        if (project == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Project not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(project.name),
            actions: [
              IconButton(
                icon: Icon(
                  project.isArchived ? Icons.unarchive : Icons.archive,
                ),
                onPressed: () async {
                  if (project.isArchived) {
                    await service.unarchiveProject(projectId);
                  } else {
                    await service.archiveProject(projectId);
                  }
                  ref.invalidate(projectsProvider);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
          body: Center(
            child: Text(
              'Project artifacts will appear here',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
          ),
        );
      },
    );
  }
}
