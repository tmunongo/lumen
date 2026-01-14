import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen/application/providers.dart';
import 'package:lumen/presentation/screens/project_detail_screen.dart';
import 'package:lumen/presentation/utils/keyboard_shortcuts.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();
  String _sortBy = 'modified';

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
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

  void _focusNewProject() {
    _nameFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);

    return ShortcutScope(
      shortcuts: {KeyboardShortcuts.newProject: _focusNewProject},
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lumen Space'),
          elevation: 0,
        ),
        body: Row(
          children: [
            // Sidebar
            Container(
              width: 260,
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
                  // New project input and sort menu
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          decoration: InputDecoration(
                            hintText: 'New project name',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: _createProject,
                              tooltip: 'Create project (⌘N)',
                            ),
                          ),
                          onSubmitted: (_) => _createProject(),
                        ),
                        const SizedBox(height: 12),
                        // Sort/Filter menu
                        Row(
                          children: [
                            Icon(
                              Icons.sort,
                              size: 18,
                              color: Theme.of(context).hintColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: PopupMenuButton<String>(
                                initialValue: _sortBy,
                                onSelected: (value) {
                                  setState(() => _sortBy = value);
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'modified',
                                    child: Text('Sort by Modified'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'created',
                                    child: Text('Sort by Created'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'name',
                                    child: Text('Sort by Name'),
                                  ),
                                ],
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Theme.of(context).dividerColor,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _sortBy == 'modified'
                                            ? 'Modified'
                                            : _sortBy == 'created'
                                                ? 'Created'
                                                : 'Name',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      Icon(
                                        Icons.arrow_drop_down,
                                        size: 20,
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Projects list
                  Expanded(
                    child: projectsAsync.when(
                      data: (projects) {
                        if (projects.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.folder_open,
                                    size: 64,
                                    color: Theme.of(context).hintColor,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No projects yet',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Theme.of(context).hintColor,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Create your first project above',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context).hintColor,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // Sort projects
                        final sortedProjects = [...projects];
                        switch (_sortBy) {
                          case 'name':
                            sortedProjects.sort(
                              (a, b) => a.name.compareTo(b.name),
                            );
                          case 'created':
                            sortedProjects.sort(
                              (a, b) => b.createdAt!.compareTo(a.createdAt!),
                            );
                          case 'modified':
                          default:
                            sortedProjects.sort(
                              (a, b) => b.modifiedAt!.compareTo(a.modifiedAt!),
                            );
                        }

                        return ListView.builder(
                          itemCount: sortedProjects.length,
                          itemBuilder: (context, index) {
                            final project = sortedProjects[index];
                            return ListTile(
                              leading: Icon(
                                project.isArchived
                                    ? Icons.archive
                                    : Icons.folder,
                                color: project.isArchived
                                    ? Theme.of(context).disabledColor
                                    : null,
                              ),
                              title: Text(
                                project.name,
                                style: project.isArchived
                                    ? TextStyle(
                                        color: Theme.of(context).disabledColor,
                                        decoration: TextDecoration.lineThrough,
                                      )
                                    : null,
                              ),
                              subtitle: Text(
                                'Modified ${_formatDate(project.modifiedAt!)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
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
                      error: (error, stack) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading projects',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                error.toString(),
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main content area
            Expanded(child: _WelcomePanel()),
          ],
        ),
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

class _WelcomePanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_stories,
                size: 120,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 32),
              Text(
                'Lumen Space',
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'A local-first tool for deep research and structured thinking',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              _ShortcutHint(
                icon: Icons.add,
                label: 'New Project',
                shortcut: '⌘N',
              ),
              const SizedBox(height: 12),
              _ShortcutHint(
                icon: Icons.search,
                label: 'Search',
                shortcut: '⌘F',
              ),
              const SizedBox(height: 12),
              _ShortcutHint(
                icon: Icons.hub,
                label: 'View Relationships',
                shortcut: '⌘R',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShortcutHint extends StatelessWidget {
  final IconData icon;
  final String label;
  final String shortcut;

  const _ShortcutHint({
    required this.icon,
    required this.label,
    required this.shortcut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Text(
              shortcut,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}
