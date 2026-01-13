import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen/application/providers.dart';
import 'package:lumen/presentation/screens/project_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createProject() async {
    if (_nameController.text.trim().isEmpty) return;

    try {
      final service = ref.read(projectServiceProvider);
      await service.createProject(_nameController.text.trim());
      _nameController.clear();
      ref.invalidate(projectsProvider);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Project created')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Lumen Space'), elevation: 0),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 280,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'New project name',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _createProject,
                      ),
                    ),
                    onSubmitted: (_) => _createProject(),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: projectsAsync.when(
                    data: (projects) {
                      if (projects.isEmpty) {
                        return const Center(child: Text('No projects yet'));
                      }
                      return ListView.builder(
                        itemCount: projects.length,
                        itemBuilder: (context, index) {
                          final project = projects[index];
                          return ListTile(
                            title: Text(project.name),
                            subtitle: Text(
                              'Modified ${_formatDate(project.modifiedAt!)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            trailing: project.isArchived
                                ? const Icon(Icons.archive, size: 16)
                                : null,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ProjectDetailScreen(
                                    projectId: project.id,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) =>
                        Center(child: Text('Error: $error')),
                  ),
                ),
              ],
            ),
          ),
          // Main content area
          Expanded(
            child: Center(
              child: Text(
                'Select a project to begin',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'today';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return '${date.month}/${date.day}/${date.year}';
  }
}
